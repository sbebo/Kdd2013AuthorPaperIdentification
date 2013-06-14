import data_io
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.cross_validation import KFold
from collections import defaultdict
import csv

def main():
    print("Getting features for deleted papers from the database")
    #features_deleted = data_io.get_features_db("TrainDeleted")
    features_deleted = data_io.get_precomputed_features("DeletedFeatures")
    print("Getting features for confirmed papers from the database")
    #features_conf = data_io.get_features_db("TrainConfirmed")
    features_conf = data_io.get_precomputed_features("ConfirmedFeatures")
    print("Getting features for deleted papers from the database")
    #valid_features_deleted = data_io.get_features_db("ValidDeleted")
    valid_features_deleted = data_io.get_precomputed_features("ValidDeletedFeatures")
    print("Getting features for confirmed papers from the database")
    #valid_features_conf = data_io.get_features_db("ValidConfirmed")
    valid_features_conf = data_io.get_precomputed_features("ValidConfirmedFeatures")

    features = [x[2:] for x in features_deleted + features_conf] #+ valid_features_deleted + valid_features_conf
    target = [0 for x in range(len(features_deleted))] + [1 for x in range(len(features_conf))] 
          #+ [0 for x in range(len(valid_features_deleted))] + [1 for x in range(len(valid_features_conf))]

    print("Training the Classifier")
    RF = RandomForestClassifier(n_estimators=50, 
                                       verbose=2,
                                        n_jobs=1,
                                        min_samples_split=10,
                                        compute_importances=True,
                                        random_state=1)
    
    GBM = GradientBoostingClassifier(n_estimators=100, 
                                        verbose=2,
                                        min_samples_split=10,
                                        random_state=1)
    classifier = RF
    classifier.fit(features, target)

    # Validation
    author_paper_ids = [x[:2] for x in valid_features_conf+valid_features_deleted]
    features = [x[2:] for x in valid_features_conf+valid_features_deleted]

    print("Making predictions")
    predictions = classifier.predict_proba(features)[:,1]
    predictions = list(predictions)

    author_predictions = defaultdict(list)
    paper_predictions = {}

    for (a_id, p_id), pred in zip(author_paper_ids, predictions):
        author_predictions[str(a_id)].append((pred,str(p_id)))

    for author_id in sorted(author_predictions):
        paper_ids_sorted = sorted(author_predictions[author_id], reverse=True)
        paper_predictions[author_id] = [x[1] for x in paper_ids_sorted]
   
    predicted = paper_predictions.items()
    predicted.sort()
    #Now I have sorted predictions for each author_id
    #Need to get the ground truth for the validation set:

    valid_confirmed_data = [row for row in csv.reader(open("ValidSolution.csv"))] #TrainConfirmed.csv
    valid_confirmed_papers = [(row[0],row[1].split()) for row in valid_confirmed_data[1:]]
    valid_confirmed_papers.sort()

    print predicted[0]
    print valid_confirmed_papers[0]
   
    import ml_metrics as metrics
    print metrics.mapk([row[1] for row in valid_confirmed_papers], [row[1] for row in predicted],10000)

if __name__=="__main__":
    main()
