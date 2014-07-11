#!/bin/bash

if [ $# -eq 0 ]; then
    echo "No arguments provided. Argument should be a list of participant numbers"
    exit 1
fi

#ls /Datasets/Goldrick/Jeremy/Twister_Recordings/wavs/ | cut -d- -f 1 | sort -u | while read ID ; do
for ID in $@ ; do
	echo Working on participant $ID
	LOG="logs/Twister_Recordings.$ID.log"
	mv $LOG $LOG.bak
	find /Datasets/Goldrick/Jeremy/Twister_Recordings/wavs.cropped  -name "$ID*.wav" | while read file
	do
		echo "----- $file -----"
		scripts/analyze_wav.sh $file | tee -a $LOG
	done
done
