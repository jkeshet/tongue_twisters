#!/bin/bash

for C in 100.0 200.0 300.0 500.0 1000.0 #0.01 0.1 1.0 10.0 100.0
do
	for sigma in 8.0 15.0 20.0 15.0 #-1.01 0.1 1.0 4.3589 6.0 10.0
	do
        training_cmd="scripts/q2_vad_train_classifier.sh -b 0.8 -c $C -k rbf3 -s $sigma -p 5"
        #echo $training_cmd
        eval "$training_cmd > training.tmp"
        training_score=`grep Final training.tmp | cut -d' ' -f 3`
        test_score=`grep total_frame_error training.tmp | cut -d' ' -f 3`
        echo "C= $C sigma= $sigma training= ${training_score} test= ${test_score}"
    done
done
