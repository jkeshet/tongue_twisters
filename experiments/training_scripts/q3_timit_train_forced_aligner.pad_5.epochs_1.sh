#!/bin/bash -fe

MODELS=models
BIN=packages/forced_alignment/bin

# phoneme classifier parameters
PAD=5
EPOCHS=1

# phoneme aligner parameters
beta1=0.01
beta2=1.0
beta3=1.0
min_sqrt_gamma=1.0
#eps=$1
loss=tau_insensitive_loss
eps=1.1
##loss=alignment_loss
#eps=3

if [ "$eps" = 0 ] ; then
	exp_name=forced_alignment.beta1_$beta1.beta2_$beta2.beta3_$beta3.gamma_$min_sqrt_gamma.pa.$loss.pad_$PAD.epochs_$EPOCHS
else
	exp_name=forced_alignment.beta1_$beta1.beta2_$beta2.beta3_$beta3.gamma_$min_sqrt_gamma.eps_$eps.$loss.pad_$PAD.epochs_$EPOCHS
fi

# small dataset
##train_set=timit_train_forced_alignment_150
##val_set=timit_train_val_forced_alignment_100

# large dataset
train_set=timit_train_forced_alignment_1796
val_set=timit_train_val_forced_alignment_400
test_set=timit_test_core

for SET in $train_set $val_set $test_set ; do
	sed "s/labels$/pad_$PAD.epochs_$EPOCHS.scores/" config/$SET.labels > config/$SET.pad_$PAD.epochs_$EPOCHS.scores
	sed "s/labels$/dist/" config/$SET.labels > config/$SET.dist
	sed "s/labels$/phonemes/" config/$SET.labels > config/$SET.phonemes
	sed "s/labels$/start_times/" config/$SET.labels > config/$SET.start_times
done

echo "Training forced-alignment: $exp_name" #> logs/$exp_name.log
#echo "Log into: logs/$exp_name.log"

if [[ 1 = 1 ]] ; then

$BIN/ForcedAlignmentTrain \
-eps $eps \
-loss $loss \
-remove_silence \
-beta1 $beta1 \
-beta2 $beta2 \
-beta3 $beta3 \
-min_gamma $min_sqrt_gamma \
-val_scores_filelist config/$val_set.pad_$PAD.epochs_$EPOCHS.scores \
-val_dists_filelist config/$val_set.dist \
-val_phonemes_filelist config/$val_set.phonemes \
-val_start_times_filelist config/$val_set.start_times \
config/$train_set.pad_$PAD.epochs_$EPOCHS.scores \
config/$train_set.dist \
config/$train_set.phonemes \
config/$train_set.start_times \
config/phonemes_39 \
config/phonemes_39.stats \
$MODELS/$exp_name.model #>> logs/$exp_name.log

fi

if [[ 1 = 1 ]] ; then

echo "Decoding forced-alignment: $exp_name" #| tee >> logs/$exp_name.log
$BIN/ForcedAlignmentDecode \
-loss $loss \
-remove_silence \
-beta1 $beta1 \
-beta2 $beta2 \
-beta3 $beta3 \
config/$val_set.pad_$PAD.epochs_$EPOCHS.scores \
config/$val_set.dist \
config/$val_set.phonemes \
config/$val_set.start_times \
config/phonemes_39 \
config/phonemes_39.stats \
$MODELS/$exp_name.model #>> logs/$exp_name.log

fi

if [[ 1 = 1 ]] ; then

echo "Decoding forced-alignment: $exp_name" #>> logs/$exp_name.log
$BIN/ForcedAlignmentDecode \
-loss $loss \
-remove_silence \
-beta1 $beta1 \
-beta2 $beta2 \
-beta3 $beta3 \
config/$test_set.pad_$PAD.epochs_$EPOCHS.scores \
config/$test_set.dist \
config/$test_set.phonemes \
config/$test_set.start_times \
config/phonemes_39 \
config/phonemes_39.stats \
$MODELS/$exp_name.model #>> logs/$exp_name.log

fi


