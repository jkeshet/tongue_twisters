


if [ 1 = 1 ] ; then

	find /Datasets/Goldrick/Jeremy/Twister_Recordings/wavs -name "*.wav" > config/vad_all_files.wav

	echo "** converts WAV to 16kHz **"
	cat config/vad_all_files.wav | while read wav_file ; do
		sampling_rate=`packages/sox/soxi $wav_file | grep "Sample Rate" | awk '{print \$4}'`
		wav16khz_file=`echo $wav_file | sed 's/wavs/wavs.vad_processed/'`
		if [ "$sampling_rate" != "16000" ] ; then 
			packages/sox/sox $wav_file -c 1 -r 16000 $wav16khz_file
		else
			cp $wav_file wav16khz_file
		fi
	done

fi

if [ 1 = 1 ] ; then

	echo "** Extract MFCC features **"
	sed "s/wavs/wavs.vad_processed/" config/vad_all_files.wav > config/vad_all_files.wav_16khz
	sed "s/wav$/htk/" config/vad_all_files.wav_16khz > config/vad_all_files.htk
	paste config/vad_all_files.wav_16khz config/vad_all_files.htk > config/vad_all_files.htk_scp
	packages/htk/HCopy -C config/vad_htk.config -S config/vad_all_files.htk_scp
	#scripts/features_stats.pl config/vad_all_files.htk > config/vad_mfcc.stats
fi

if [ 1 = 1 ] ; then

	echo "** decoding VAD **"

	c=1
	b=0
	s=2.6
	p=5
	e=1
	k=rbf2

	echo "Assuming the following parameters: -c $c -b $b -s $s -p $p -e $e -k $k"
	kernel_file=primal_$k.sigma_$s
	exp_name=vad.pa1.C_$c.B_$b.sigma_$s.pad_$p.epochs_$e.extra
	model=models/$exp_name
	phone_set=config/vad.phoneset
	input_list=config/vad_all_files.htk
	scores_list=config/vad_all_files.scores
	rm -fr $scores_list
	cat $input_list | while read infile ; do
	  outfile=`echo $infile | sed 's/htk$/scores/'`
	  echo $outfile >> $scores_list
	done

	packages/forced_alignment/bin/PhonemeFrameBasedDecode \
	-n $p \
	-kernel_expansion $k  \
	-sigma $s \
	-averaging \
	-mfcc_stats config/vad_mfcc.stats \
	-scores $scores_list \
	$input_list null $phone_set $model 

fi


if [ 1 = 1 ] ; then

	echo "** generate new cropped WAVs **"

	scores_list=config/vad_all_files.scores
	cat $scores_list | while read scores_file ; do
	    echo $scores_file
	    tg_file=`echo $scores_file | sed 's/scores$/pred.TextGrid/'`
	    wav_file=`echo $scores_file | sed 's/scores$/wav/'`
	    wav_file_cropped=`echo $wav_file | sed 's/vad_processed/cropped/'`
	    ep_file=`echo $scores_file | sed 's/scores$/ep/'`
	    # python scripts/scores2textgrid.py --frame_rate 0.01 --post_smoothing $scores_file $tg_file
	    # praat $wav_file $tg_file
	    python training_scripts/helpers/scores2endpoints.py --frame_rate 0.01 --post_smoothing $scores_file $ep_file
	    start_time=`cat $ep_file | cut -f1 -d ' '`
	    end_time=`cat $ep_file | cut -f2 -d ' '`	    
	    python training_scripts/helpers/wav_crop.py $wav_file $wav_file_cropped $start_time $end_time
	done

fi


