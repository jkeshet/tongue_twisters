#!/bin/bash

C=1
B=0
sigma=2.6
pad=5
epochs=1
kernel=rbf2


kernel_file=primal_$kernel.sigma_$sigma
#kernel_file=primal_poly2

# experience name
# was ver2 before
model=$MODELS/phoeneme_frame_based.pa1.C_$C.B_$B.sigma_$SIGMA.pad_$PAD.epochs_$EPOCHS.model
exp_name=vad.pa1.C_$C.B_$B.sigma_$SIGMA.pad_$pad.epochs_$epochs.extra
echo $exp_name

# train data
input_list=config/vad_files.training.htk
target_list=config/vad_files.training.labels
rs_list=config/vad_training_files.random_shuffle

# phoneme symbols
phone_set=config/vad.phoneset

# model
model=models/$exp_name
log_file=logs/$exp_name

# create random shuffle of the training data
packages/forced_alignment/bin/RandomShuffleDb -n $pad $input_list $target_list $rs_list

# training
packages/forced_alignment/bin/PhonemeFrameBasedTrain \
-n $pad \
-kernel_expansion $kernel \
-sigma $sigma \
-epochs $epochs \
-C $C -B $B \
-mfcc_stats config/vad_mfcc.stats \
$input_list $target_list $rs_list $phone_set $model 

# testing
input_list=config/vad_files.dev.htk
target_list=config/vad_files.dev.labels
scores_list=config/vad_files.dev.scores
rm -fr $scores_list
cat $input_list | while read infile ; do
  outfile=`echo $infile | sed 's/htk$/scores/'`
  echo $outfile >> $scores_list
done

packages/forced_alignment/bin/PhonemeFrameBasedDecode \
-n $pad \
-kernel_expansion $kernel  \
-sigma $sigma \
-averaging \
-mfcc_stats config/vad_mfcc.stats \
-scores $scores_list \
$input_list $target_list $phone_set $model 


cat $scores_list | while read scores_file ; do
    tg_file=`echo $scores_file | sed 's/scores$/pred.TextGrid/'`
    wav_file=`echo $scores_file | sed 's/scores$/wav/'`
    python training_scripts/helpers/scores2textgrid.py --frame_rate 0.01 --post_smoothing $scores_file $tg_file
    #praat $wav_file $tg_file
done
