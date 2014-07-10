#!/bin/bash

ls /Datasets/Goldrick/Jeremy/Twister_Recordings/wavs/ | cut -d- -f 1 | sort -u | while read ID ; do
#for ID in 019 ; do
    if [ $ID != "019" ] 
    	then
	    echo Working on participant $ID
		LOG="logs/Twister_Recordings.$ID.log"
		mv $LOG $LOG.bak
		find /Datasets/Goldrick/Jeremy/Twister_Recordings/wavs.cropped  -name "$ID*.wav" | while read file
		do
			echo "----- $file -----"
			scripts/analyze_wav.develop.sh $file | tee -a $LOG
		done
	fi
done
