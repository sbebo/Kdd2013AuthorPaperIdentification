import data_io, csv, numpy
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn import cross_validation, preprocessing, svm, neighbors, linear_model
from collections import defaultdict
import ml_metrics as metrics

def main():
    print("Getting features for deleted papers from the database")
    #features_deleted = data_io.get_features_db("TrainDeleted")
    features_deleted = data_io.get_precomputed_features("DeletedFeaturester")
    print("Getting features for confirmed papers from the database")
    #features_conf = data_io.get_features_db("TrainConfirmed")
    features_conf = data_io.get_precomputed_features("ConfirmedFeaturester")
    print("Getting features for deleted papers from the database")
    #valid_features_deleted = data_io.get_features_db("ValidDeleted")
    valid_features_deleted = data_io.get_precomputed_features("DeletedValidFeaturester")
    print("Getting features for confirmed papers from the database")
    #valid_features_conf = data_io.get_features_db("ValidConfirmed")
    valid_features_conf = data_io.get_precomputed_features("ConfirmedValidFeaturester")

    all_features = [x for x in features_deleted + features_conf + valid_features_deleted + valid_features_conf]
    all_target = [0 for x in range(len(features_deleted))] + [1 for x in range(len(features_conf))] \
          + [0 for x in range(len(valid_features_deleted))] + [1 for x in range(len(valid_features_conf))]

    print "Load ground truth"
    valid_confirmed_data = [row for row in csv.reader(open("ValidSolution.csv"))]
    valid_confirmed_papers = [(row[0],row[1].split()) for row in valid_confirmed_data[1:]]
    valid_confirmed_papers.sort()
    train_confirmed_data = [row for row in csv.reader(open("Train.csv"))]
    train_confirmed_papers = [(row[0],row[1].split()) for row in train_confirmed_data[1:]]
    train_confirmed_papers.sort()
    ground_truth = valid_confirmed_papers + train_confirmed_papers
    authors = [row[0] for row in ground_truth]
    
    scaling = False 
    mp = []
    for k in xrange(10): 
        # Now split authors anyway you like.
        print "Split data"
        authors_train, authors_test = cross_validation.train_test_split(authors,test_size=0.1, random_state=k)
    
        print "Build training set"
        train_indices = [i for (i,x) in enumerate(all_features) if str(x[0]) in authors_train]
        test_indices = [i for (i,x) in enumerate(all_features) if str(x[0]) in authors_test]
        train_features = [map(float,all_features[i][2:]) for i in train_indices]
        print len(train_features)
        print train_features[0]
        if scaling:
            scaler = preprocessing.StandardScaler().fit(train_features)
            train_features = scaler.transform(train_features)
        train_targets  = [all_target[i] for i in train_indices]
        print len(train_targets)
    
        print "Build test set"
        author_paper_ids = [all_features[i][:2] for i in test_indices]
        test_features = [map(float,all_features[i][2:]) for i in test_indices]
        if scaling:
            test_features = scaler.transform(test_features)
        test_targets  = [all_target[i] for i in test_indices]
        test_ground_truth = [row for row in ground_truth if row[0] in authors_test]
        test_ground_truth.sort()
    
        print("Training the Classifier")
        RF = RandomForestClassifier(n_estimators=100, verbose=1, n_jobs=10, min_samples_split=10, compute_importances=True, random_state=1)
        SVM = svm.SVC(cache_size=1000, verbose=True)
        knn = neighbors.KNeighborsClassifier()
        GBM = GradientBoostingClassifier(n_estimators=100, verbose=1, min_samples_split=10, random_state=1)
        log = linear_model.LogisticRegression(random_state=1)
        classifier = log 
        classifier.fit(train_features, train_targets)
        if classifier == RF or classifier == GBM:
            print "Feature importance", classifier.feature_importances_

        print("Making predictions")
        predictions = classifier.predict_proba(test_features)[:,1]
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
    
        print [x[0] for x in predicted[:5]]
        print [x[0] for x in test_ground_truth[:5]]
        mp.append(metrics.mapk([row[1] for row in test_ground_truth], [row[1] for row in predicted],10000))
        print mp[k]
    
    print numpy.mean(mp)
    print numpy.std(mp)
    
if __name__=="__main__":
    main()
