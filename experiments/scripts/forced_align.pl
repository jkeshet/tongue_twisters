#!/usr/bin/perl -w

use lib "scripts";
use List::Util qw[min max];
use TextGrid;
use File::Basename;

unless ($#ARGV+1 == 3) {
	print "Usage: $0 <wavfile> <phonemes> <output_textgrid>\n";
	print "     Given input TIMIT WAV file and list of phonemes, this scripts\n"; 
	print "     prints a list of phoneme start-times.\n";
	exit;
}

# binaries
$hcopy_bin="packages/htk/Hcopy";
$htk_ceps_dist_bin="packages/forced_alignment/bin/htk_ceps_dist";
$phoneme_frame_based_decoder_bin="packages/forced_alignment/bin/PhonemeFrameBasedDecode";
$forced_alignment_decoder_bin="packages/forced_alignment/bin/ForcedAlignmentDecode";

# data and temp directory
$data_directory = "data";


# check binaries existance
unless (-e $hcopy_bin) {
	print STDERR "Error: unable to find Hcopy binary\n";
	exit;
}
unless (-e $htk_ceps_dist_bin) {
	print STDERR "Error: unable to find htk_ceps_dist binary\n";
	exit;
}
unless (-e $phoneme_frame_based_decoder_bin) {
	print STDERR "Error: unable to find PhonemeFrameBasedDecode binary\n";
	exit;
}
unless (-e $forced_alignment_decoder_bin) {
	print STDERR "Error: unable to find ForcedAlignmentDecode binary\n";
	exit;
}


# frame-base phoneme classifier parameters
$SIGMA="4.3589";
$C="1";
$B="0.8";
$EPOCHS="1";
$phoneme_frame_based_model="models/pa_phoeneme_frame_based.C_$C.B_$B.sigma_$SIGMA.epochs_$EPOCHS.model";
# pa_phoeneme_frame_based.C_1.B_0.8.sigma_4.3589.model
unless (-e $phoneme_frame_based_model) {
	print STDERR "Error: unable to find phoneme classifier model: $phoneme_frame_based_model\n";
	exit;
}

# forced-aligned classifier parameters\
$beta1="0.01";
$beta2="1.0";
$beta3="1.0";
$min_sqrt_gamma="1.0";
$loss="tau_insensitive_loss";
$eps=1.1;
$forced_alignment_model="models/forced_alignment.beta1_$beta1.beta2_$beta2.beta3_$beta3.gamma_$min_sqrt_gamma.eps_$eps.$loss.model";
#forced_alignment.beta1_0.01.beta2_1.0.beta3_1.0.gamma_1.0.eps_1.1.tau_insensitive_loss.model
unless (-e $forced_alignment_model) {
	print STDERR "Error: unable to find forced-alignment model: $forced_alignment_model\n";
	exit;
}


$basename = basename($ARGV[0],".wav");
system("mkdir -p $data_directory/$basename");

$mfc_filename = "$data_directory/$basename/$basename.mfc";
$dist_filename = "$data_directory/$basename/$basename.dist";
$scores_filename = "$data_directory/$basename/$basename.scores";

$mfc_filelist = "$data_directory/$basename/$basename.mfc_list";
$cmd="echo $mfc_filename > $mfc_filelist";
system($cmd);
$dist_filelist = "$data_directory/$basename/$basename.dist_list";
$cmd="echo $dist_filename > $dist_filelist";
system($cmd);
$scores_filelist = "$data_directory/$basename/$basename.scores_list";
$cmd="echo $scores_filename > $scores_filelist";
system($cmd);

# # convert file to 16kHz
# $wav16filename = "$data_directory/$basename/$basename.wav";
# $cmd = "sox $ARGV[0] -c 1 -r 16000 $wav16filename";
# #print "$cmd\n";
# system($cmd);
$wav16filename = $ARGV[0];

# first extract features
$cmd="$hcopy_bin -C config/wav_htk.config $wav16filename $mfc_filename";
#print "$cmd\n";
system($cmd);
$cmd="$htk_ceps_dist_bin $mfc_filename config/timit_mfcc.stats $dist_filename";
#print "$cmd\n";
system($cmd);
$cmd="$phoneme_frame_based_decoder_bin -n 1 -kernel_expansion rbf3 -sigma $SIGMA -mfcc_stats config/timit_mfcc.stats -averaging -scores $scores_filelist $mfc_filelist null config/phonemes_39 $phoneme_frame_based_model > $data_directory/$basename/$basename.phoneme_classifier_log";
#print "$cmd\n";
system($cmd);

$pred_align_filelist="$data_directory/$basename/$basename.pred_align_list";
#$pred_align_filename="$data_directory/$basename/$basename.pred_align";
$cmd="echo $ARGV[2] > $pred_align_filelist";
system($cmd);

$phoneme_filelist="$data_directory/$basename/$basename.phoneme_filelist";
$cmd="cat $ARGV[1] | sed -e 's/\*//g' > $data_directory/$basename/$basename.phonemes";
#print "$cmd\n";
system($cmd);
$cmd="echo $data_directory/$basename/$basename.phonemes > $phoneme_filelist";
#print "$cmd\n";
system($cmd);
$cmd="$forced_alignment_decoder_bin -beta1 $beta1 -beta2 $beta2 -beta3 $beta3 -output_textgrid $pred_align_filelist $scores_filelist $dist_filelist $phoneme_filelist null config/phonemes_39 config/phonemes_39.stats $forced_alignment_model > $data_directory/$basename/$basename.forced_alignment_log";
#print "$cmd\n";
system($cmd);

# -------------------------------------------------------------------------------------------------------- #

# read the text read and add back the * signs to the relevat phonemes

@phonemes_sequence = ();
open(INPUT,"$ARGV[1]") or die "Can't open $ARGV[1]: $!\n";
while (<INPUT>) {
	chomp;
	@phonemes_sequence = split;
}
close(INPUT);


# read the whole input text grid
open(INPUT,"$ARGV[2]") or die "Can't open $ARGV[2]: $!\n";
@tg_content = <INPUT>;
close(INPUT);

# extract textgrid
my (@xmin_phonemes, @xmax_phonemes, @text_phonemes);
$xmax_global = TextGrid::extract_tier(\@tg_content, "Forced Alignment", \@xmin_phonemes, \@xmax_phonemes, \@text_phonemes);
TextGrid::write_tier($ARGV[2], "Forced Alignment", $xmax_global, \@xmin_phonemes, \@xmax_phonemes, \@phonemes_sequence);




