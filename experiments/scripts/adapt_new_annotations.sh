#!/bin/bash

export DYLD_LIBRARY_PATH=../code/audiofile-0.3.4/libaudiofile/.libs


if [ 1 = 1 ] ; then 

echo "** Convert files to 16Khz **"
find /Datasets/Goldrick/Jeremy/new_labels_19nov2012/original_wavs -name "*.wav" > config/jeremy_vot_labels_19nov2012.original_wavs
cat config/jeremy_vot_labels_19nov2012.original_wavs | while read infile ; do
	echo $infile 
	soxi $infile | grep "Sample Rate"
	outfile=`echo $infile | sed 's:original_wavs\/::'`
	 sox $infile -c 1 -r 16000 $outfile
done

fi


if [ 1 = 1 ] ; then 

scripts/preprocess_textgrids.pl -only_pos config/jeremy_vot_labels_19nov2012.wav_list config/jeremy_vot_labels_19nov2012.tg_list config/jeremy_vot_labels_19nov2012.input_fe

fi

if [ 1 = 1 ] ; then 

sed -e 's#/Datasets/Goldrick/Jeremy/Comparison_VOTs#data/adaptation#' -e 's/.wav//' config/jeremy_vot_labels_19nov2012.input_fe | awk '{printf ("%s.%s.txt\n", $1, $4)}' > config/jeremy_vot_labels_19nov2012.feature_filelist

fi

if [ 1 = 1 ] ; then 

../bin/VotFrontEnd config/jeremy_vot_labels_19nov2012.input_fe config/jeremy_vot_labels_19nov2012.feature_filelist config/jeremy_vot_labels_19nov2012.labels

fi

if [ 1 = 1 ] ; then 

	../bin/InitialVotTrain -load_classifier ../models/nattalia_both_pos_fold2.classifier -pos_only -vot_loss -epochs 1 -loss_eps 4 config/jeremy_vot_labels_19nov2012.feature_filelist config/jeremy_vot_labels_19nov2012.labels ../models/nattalia_both_pos_fold2.classifier2

	#../bin/InitialVotTrain -load_classifier ../models/nattalia_both_pos_fold2.classifier -pos_only -vot_loss -epochs 1 -loss_eps 4 \
	#	../experiments_nattalia/config/nattalia_both_pos_fold2_train_features.txt \
	#	../experiments_nattalia/config/nattalia_both_pos_fold2_train_labels.txt \
	#	../models/nattalia_both_pos_fold2.classifier2
fi