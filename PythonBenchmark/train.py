import data_io
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier

def main():
    print("Getting features for deleted papers from the database")
    features_deleted = data_io.get_features_db("TrainDeleted")
    #features_deleted = data_io.get_precomputed_features("DeletedFeatures")

    print("Getting features for confirmed papers from the database")
    features_conf = data_io.get_features_db("TrainConfirmed")
    #features_conf = data_io.get_precomputed_features("ConfirmedFeatures")

    features = [x[2:] for x in features_deleted + features_conf]
    target = [0 for x in range(len(features_deleted))] + [1 for x in range(len(features_conf))]

    print("Training the Classifier")
    #classifier = RandomForestClassifier(n_estimators=100, 
    #                                    verbose=2,
    #                                    n_jobs=1,
    #                                    min_samples_split=10,
    #                                    compute_importances=True,
    #                                    random_state=1)
    classifier = GradientBoostingClassifier(n_estimators=100, 
                                        verbose=2,
                                        min_samples_split=10,
                                        random_state=1)
    classifier.fit(features, target)
    print("Saving the classifier")
    data_io.save_model(classifier)
    print "Feature importance", classifier.feature_importances_ 
    
if __name__=="__main__":
    main()
