#!/bin/bash

MODELS=models
BIN=packages/forced_alignment/bin

# phoneme frame-based classifier parameters
SIGMA=4.3589
C=1
B=0.8
PAD=5
EPOCHS=3

input_list=config/timit_train.mfc
target_list=config/timit_train.labels
rs_list=config/timit_train.random_shuffle
model=$MODELS/phoeneme_frame_based.pa1.C_$C.B_$B.sigma_$SIGMA.pad_$PAD.epochs_$EPOCHS.model

# train passive-aggressive phoneme frame-based classifier 
mkdir -p $MODELS


# create random shuffle of the training data
if [[ 1 = 1 ]] ; then

$BIN/RandomShuffleDb -n $PAD $input_list $target_list $rs_list

fi

if [[ 1 = 1 ]] ; then

$BIN/PhonemeFrameBasedTrain \
	-C $C \
	-B $B \
	-n $PAD \
	-kernel_expansion rbf3 \
	-sigma $SIGMA \
	-mfcc_stats config/timit_mfcc.stats \
	-omap config/timit61.phonemap \
	$input_list \
	$target_list \
	$rs_list \
	config/phonemes_39 \
	$model 

fi

# decode the rest of the training files 
if [[ 1 = 1 ]] ; then

$BIN/PhonemeFrameBasedDecode \
	-n $PAD \
	-kernel_expansion rbf3 \
	-sigma $SIGMA \
	-averaging \
	-mfcc_stats config/timit_mfcc.stats \
	-scores config/timit_train_frame_based_classifier_1500_rest.scores \
	config/timit_train_frame_based_classifier_1500_rest.mfc \
	config/timit_train_frame_based_classifier_1500_rest.labels \
	config/phonemes_39 \
	$model

fi

if [[ 1 = 1 ]] ; then

# decode the all the test files
$BIN/PhonemeFrameBasedDecode \
	-n $PAD \
	-kernel_expansion rbf3 \
	-sigma $SIGMA \
	-averaging \
	-mfcc_stats config/timit_mfcc.stats \
	-scores config/timit_test_core.scores \
	config/timit_test_core.mfc \
	config/timit_test_core.labels \
	config/phonemes_39 \
	$model

fi


if [[ 1 = 1 ]] ; then 

# decode the all the test files
$BIN/PhonemeFrameBasedDecode \
	-n $PAD \
	-kernel_expansion rbf3 \
	-sigma $SIGMA \
	-averaging \
	-mfcc_stats config/timit_mfcc.stats \
	-scores config/timit_test.scores \
	config/timit_test.mfc \
	config/timit_test.labels \
	config/phonemes_39 \
	$model

fi
