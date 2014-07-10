#!/bin/bash

EXPECTED_ARGS=1
ERROR_BAD_ARGS=65

if [ $# -lt $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` [--debug] {input WAV filename}"
  exit ERROR_BAD_ARGS
fi

if [ $1 = "--debug" ] ; then
	echo "Debug mode."
	debug="--debug"
	wavfile="$2"
else	
	# first argument is WAV filename
	debug=""
	wavfile="$1"
fi

if [ ! -e "$wavfile" ] ;then
	echo "Error: cannot find WAV file $wavfile"
	exit
fi

# define filenames
basename=`basename $wavfile ".wav"`
wav16file="data/$basename.wav"
tgfile="data/$basename.TextGrid"
phonemesfile="data/$basename.phonemes"
bestalignmentfile="data/$basename.best_alignment"

# make dir data, if does not exist
mkdir -p data
cp $wavfile data/

# converts WAV to 16kHz
sampling_rate=`packages/sox/soxi $wavfile | grep "Sample Rate" | awk '{print \$4}'`
if [ "$sampling_rate" != "16000" ] ; then 
	if [ $debug ] ; then
		echo -e "\n** calling sox since rate is not 16kHz"
		echo "packages/sox/sox $wavfile -c 1 -r 16000 $wav16file"
	fi
	packages/sox/sox $wavfile -c 1 -r 16000 $wav16file
else
	wav16file="$wavfile"
fi

/bin/rm -fr $bestalignmentfile
for i in `seq 7 16`;
do
    # find the template transciption
    if [ $debug ] ; then
        echo -e "\n** python scripts/filename2phonemes.py --begin $i --end $i $debug $basename > $phonemesfile"
    fi
    python scripts/filename2phonemes.py --begin $i --end $i $debug $basename > $phonemesfile

    # forced align the trascription against the WAV file
    if [ $debug ] ; then
        echo -e "\n** python scripts/forced_align.py $wav16file $phonemesfile $tgfile"
    fi
    python scripts/forced_align.py $debug $wav16file $phonemesfile $tgfile

    # located processing windows based on the forced alignement
    if [ $debug ] ; then
        echo -e "\n** python scripts/locate_processing_windows.py $tgfile"
    fi
    python scripts/locate_processing_windows.py $debug $tgfile

    if [ $debug ] ; then
        echo -e "\n** python scripts/alignment_confidence.py $tgfile"
    fi
    echo $i, `python scripts/alignment_confidence.py $tgfile` >> $bestalignmentfile

done

best_i=`cat $bestalignmentfile | sort -n -k2 | head -1 | cut -f1 -d,`
echo "Info: the best alignment found for ${best_i} patterns." >&2

# find the template transciption
if [ $debug ] ; then
    echo -e "\n** python scripts/filename2phonemes.py --begin ${best_i} --end ${best_i} $debug $basename >
    $phonemesfile"
fi
python scripts/filename2phonemes.py --begin ${best_i} --end ${best_i} $debug $basename > $phonemesfile

# forced align the trascription against the WAV file
if [ $debug ] ; then
    echo -e "\n** python scripts/forced_align.py $wav16file $phonemesfile $tgfile"
fi
python scripts/forced_align.py $debug $wav16file $phonemesfile $tgfile

# located processing windows based on the forced alignement
if [ $debug ] ; then
    echo -e "\n** python scripts/locate_processing_windows.py $tgfile"
fi
python scripts/locate_processing_windows.py $debug $tgfile

# predict location of VOT based on the forced aligned stop consonants
if [ $debug ] ; then
	echo -e "\n** python scripts/predict_vot.py $wav16file $tgfile "
fi
python scripts/predict_vot.py $debug $wav16file $tgfile > data/$basename/$basename.vot

# generates a log file
echo -n "$basename, "
grep confidence data/$basename/$basename.forced_alignment_log | awk '{ printf "%f, ", $2 }' 
echo -n `python scripts/alignment_confidence.py $tgfile`", "
cat data/$basename/$basename.vot
if [ ! $debug ] ; then
	rm -fr data/$basename/ data/$basename.phonemes
fi
