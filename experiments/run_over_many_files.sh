#!/bin/bash

#for ID in 003 004 007 008 010 011 014 016
#ls /Datasets/Goldrick/Jeremy/Twister_Recordings/wavs/ | cut -d- -f 1 | sort -u | while read ID ; do
#ls /Datasets/Goldrick/Jeremy/Twister_Recordings/wavs/002-* | cut -d- -f 1 | sort -u | while read ID ; do
for ID in 019 ; do
    echo Working on participant $ID
	LOG="logs/Twister_Recordings.$ID.log"
	mv $LOG $LOG.bak
	find /Datasets/Goldrick/Jeremy/Twister_Recordings/wavs.cropped  -name "$ID*.wav" | while read file
	do
		echo "----- $file -----"
		scripts/analyze_wav.sh $file | tee -a $LOG
	done
done
