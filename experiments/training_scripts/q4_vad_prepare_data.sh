
if [ 1 = 1 ] ; then

	echo "** Extract MFCC features **"
	find /Datasets/Goldrick/Jeremy/split_wavs_long/Yossi_split-long.vad_training -name "*.wav" > config/vad_files.wav
	find /Datasets/Goldrick/Jeremy/split_wavs_long/Yossi_split-long.vad_training_extra -name "*.wav" >> config/vad_files.wav
	sed "s/wav$/htk/" config/vad_files.wav > config/vad_files.htk
	paste config/vad_files.wav config/vad_files.htk > config/vad_files.htk_scp
	packages/htk/HCopy -C config/vad_htk.config -S config/vad_files.htk_scp
	training_scripts/helpers/features_stats.pl config/vad_files.htk > config/vad_mfcc.stats
fi

if [ 1 = 1 ] ; then 

	echo "** Generate frame labels from TextGrids **"
	rm -fr config/vad_files.labels
	sed "s/wav$/TextGrid/" config/vad_files.wav | while read infile ; do
		outfile=`echo $infile | sed 's/TextGrid$/labels/'`
		#echo $infile "-->" $outfile
		python training_scripts/helpers/textgrid2labels.py $infile $outfile
		# remove first line and last line of the labels files (beacus the MFCC features delta)
		sed -e '1d' -e '$ d' $outfile > $outfile.new && mv $outfile.new $outfile		
		echo $outfile >> config/vad_files.labels
	done

fi


if [ 1 = 0 ] ; then 

	echo "** Check number of frames **"
	cat config/vad_files.htk | while read htk_file ; do
		labels_file=`echo $htk_file | sed 's/htk$/labels/'`
		echo $htk_file $labels_file
		num_frames_1=`HList -r $htk_file | wc -l | awk '{print $1}'`
		num_frames_2=`wc -l $labels_file | awk '{print $1}'`
		echo $num_frames_1 $num_frames_2
	done

fi


if [ 1 = 1 ] ; then

	echo "** split training / dev **"
	paste config/vad_files.htk config/vad_files.labels > config/vad_files.comb
	numfiles=`wc -l config/vad_files.comb | awk '{print $1}'`
	numdev=$(( $numfiles/4 ))
	numtraining=$(( $numfiles - $numdev ))
	echo "total files=" $numfiles " num training=" $numtraining " num dev=" $numdev
	training_scripts/helpers/random_file_lines.pl config/vad_files.comb | nl > config/vad_files.comb.rs
	head -n $numtraining config/vad_files.comb.rs > config/vad_files.comb.rs.training
	tail -n $numdev config/vad_files.comb.rs > config/vad_files.comb.rs.dev
	awk '{print $2}' config/vad_files.comb.rs.training > config/vad_files.training.htk
	awk '{print $3}' config/vad_files.comb.rs.training > config/vad_files.training.labels
	awk '{print $2}' config/vad_files.comb.rs.dev > config/vad_files.dev.htk
	awk '{print $3}' config/vad_files.comb.rs.dev > config/vad_files.dev.labels
fi
