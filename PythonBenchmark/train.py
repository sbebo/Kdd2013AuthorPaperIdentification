import data_io
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier

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

    features = [x[2:] for x in features_deleted + features_conf + valid_features_deleted + valid_features_conf]
    target = [0 for x in range(len(features_deleted))] + [1 for x in range(len(features_conf))] \
          + [0 for x in range(len(valid_features_deleted))] + [1 for x in range(len(valid_features_conf))]


    print("Training the Classifier")
    clfRF = RandomForestClassifier(n_estimators=100, 
                                       verbose=2,
                                        n_jobs=10,
                                        min_samples_split=10,
                                        compute_importances=True,
                                        random_state=1)
    
    clfGBM = GradientBoostingClassifier(n_estimators=100, 
                                        verbose=2,
                                        min_samples_split=10,
                                        random_state=1)
    
    classifier = clfRF
    classifier.fit(features, target)

    print("Saving the classifier")
    #data_io.save_model(clfier)
    print "Feature importance", classifier.feature_importances_ 
    
if __name__=="__main__":
    main()
