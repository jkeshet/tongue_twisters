#!/usr/bin/perl -w

use lib "scripts";
use List::Util qw[min max];
use TextGrid;
use File::Basename;

# general variables
$ENV{'DYLD_LIBRARY_PATH'} = '../code/audiofile-0.3.4/libaudiofile/.libs';
$data_directory = "data";


unless ($#ARGV+1 >= 2) {
	print "Usage: $0 [-debug] <wavfile> <textgrid>\n";
	exit;
}

if ($ARGV[0] eq "-debug") {
	$debug = 1;
	$wav_filename=$ARGV[1];
	$tg_filename=$ARGV[2];
}
else {	
	$debug = 0;
	$wav_filename=$ARGV[0];
	$tg_filename=$ARGV[1];
}

$basename = basename($wav_filename,".wav");
$data_prefix="$data_directory/$basename";
$features_prefix="$data_prefix/features/";
system("mkdir -p $data_prefix $features_prefix");
$input_file="$data_prefix/$basename.input";
$labels_file="$data_prefix/$basename.labels";
$preds_file="$data_prefix/$basename.preds";
$final_vot_file="$data_prefix/$basename.vot";
$feature_filelist="$data_prefix/$basename.feature_filelist";

# read the whole input text grid
open(INPUT,"$tg_filename") or die "Can't open $tg_filename: $!\n";
@tg_content = <INPUT>;
close(INPUT);

# extract textgrid
my (@xmin_phonemes, @xmax_phonemes, @text_phonemes);
$xmax_global = TextGrid::extract_tier(\@tg_content, "Forced Alignment", \@xmin_phonemes, \@xmax_phonemes, \@text_phonemes);
$xmax_global = TextGrid::extract_tier(\@tg_content, "Processing Window", \@xmin_proc_win, \@xmax_proc_win, \@text_proc_win);

print "xmax_global=$xmax_global\n" if ($debug);


open(INPUTFILE,">$input_file") or die "Can't open $input_file: $!\n";
open(FEATUREFILELIST,">$feature_filelist") or die "Can't open $feature_filelist: $!\n";
for ($k=0; $k < scalar(@xmin_proc_win); $k++) {
	$i = $text_proc_win[$k];
	print INPUTFILE "$wav_filename ".int($xmin_proc_win[$k]*16000.0)." ".int($xmax_proc_win[$k]*16000.0)." ".int($xmin_phonemes[$i]*16000)." ".int($xmax_phonemes[$i]*16000)."\n"; 
	print FEATUREFILELIST $features_prefix."_".int($xmin_proc_win[$k]*16000.0).".txt\n"; 
}
close(INPUTFILE);
close(FEATUREFILELIST);

if ($debug) {	
	print "../bin/VotFrontEnd $input_file $feature_filelist $labels_file\n" ;
}
system("../bin/VotFrontEnd $input_file $feature_filelist $labels_file >& $data_prefix/$basename.vot_front_end_log");

#$model="../models/nattalia_both_pos_fold2.classifier";
$model="../models/amanda_2000.model";
if ($debug) {	
	print "../bin/InitialVotDecode -pos_only -min_vot_length 5 -max_onset 800 -max_vot_length 500 -output_predictions $preds_file $feature_filelist $labels_file $model\n";
}
system("../bin/InitialVotDecode -pos_only -min_vot_length 5 -max_onset 800 -max_vot_length 500 -output_predictions $preds_file $feature_filelist $labels_file $model > $data_prefix/$basename.vot_predictor_log");

if ($debug) {
    print "python scripts/check_prevoicing.py $feature_filelist $preds_file $preds_file.with_prevoicing\n";
}
system("python scripts/check_prevoicing.py $feature_filelist $preds_file $preds_file.with_prevoicing");

# read the predictions
$j = 0;
$k = 0;
my (@xmin_preds, @xmax_preds, @text_preds, @confidences);
open(PREDSFILE,"$preds_file.with_prevoicing") or die "Can't open $preds_file.with_prevoicing: $!\n";
while (<PREDSFILE>) {
	chomp;
	($confidence,$xmin,$xmax,$prevoicing) = split;

	#if ($confidence > 0 && $xmin != $xmax) {
		if ($xmin < $xmax) { # positive VOT
			$xmin_preds[$j] = $xmin_proc_win[$k] + ($xmin/1000.0);
			$xmax_preds[$j] = $xmin_proc_win[$k] + ($xmax/1000.0);
            if ($prevoicing) {
			    $text_preds[$j] = "prevoiced ".$confidence;
    			$confidences[$j] = -$confidence;
			}
			else {
			    $text_preds[$j] = $confidence;
	    		$confidences[$j] = $confidence;
			}
		}
		else { # negative VOT
			$xmin_preds[$j] = $xmin_proc_win[$k] + ($xmax/1000.0);
			$xmax_preds[$j] = $xmin_proc_win[$k] + ($xmin/1000.0);
			$text_preds[$j] = "neg ".$confidence;
			$confidences[$j] = $confidence;
		}
		if ($debug) {
			print $confidence." ".($xmin/1000.0)." ".($xmax/1000.0)." ".$xmin_proc_win[$k]." --> ".($xmin_proc_win[$k] + ($xmin/1000.0))
			." ".($xmin_proc_win[$k] + ($xmax/1000.0))." [".$confidence." ".$xmin." ".$xmax."] prevoicing="
			.$prevoicing."\n";
		}
		$j++; 
	#}
	$k++;
}
close(PREDSFILE);

# write to final VOT file to output as text
open(FINAL_VOT_FILE,">$final_vot_file") or die "Can't open $final_vot_file for writting: $!\n";
for ($k=0; $k < scalar(@xmin_preds); $k++) {
	$temp_string = sprintf("%.3f, %.4f, ", $confidences[$k],($xmax_preds[$k]-$xmin_preds[$k])); 
	print FINAL_VOT_FILE $temp_string;
}
close(FINAL_VOT_FILE);

# write_textgrid
TextGrid::add_tier(\@tg_content, "Predicted VOT", \@xmin_preds, \@xmax_preds, \@text_preds);


open(OUTPUT,">$tg_filename") or die "Can't open $tg_filename for writing: $!\n";
print OUTPUT @tg_content;
close(OUTPUT);

