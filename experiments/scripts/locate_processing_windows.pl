#!/usr/bin/perl -w

use lib "scripts";
use List::Util qw[min max];
use TextGrid;

#my @plosives = qw(b d g k p t);

unless ($#ARGV+1 >= 1) {
	print "Usage: $0 [-debug] <textgrid>\n";
	print "       This utility adds a tier to the input TextGrid file which contains the processing \n";
	print "       window used by the VOT predictor. This utility assumes that the TextGrid contains \n";
	print "       a tier called \"Forced Alignment\", and locates the processing windows arround \n";
	print "       the phonemes labeles contains a * sign (like /*b/).\n";
	exit;
}

if ($ARGV[0] eq "-debug") {
	$debug = 1;
	$tg_filename=$ARGV[1];
}
else {	
	$debug = 0;
	$tg_filename=$ARGV[0];
}

# read the whole input text grid
open(INPUT,"$tg_filename") or die "Can't open $tg_filename: $!\n";
@tg_content = <INPUT>;
close(INPUT);

# extract textgrid
my (@xmin_phonemes, @xmax_phonemes, @text_phonemes);
$xmax_global = TextGrid::extract_tier(\@tg_content, "Forced Alignment", \@xmin_phonemes, \@xmax_phonemes, \@text_phonemes);
print "xmax_global=$xmax_global\n" if ($debug);

# generate lists
$i = 0; # $i is the running index of the current vot. not every word has a corresponing vot
$k = 0; # $k is the running index of the processing portion
for ($i=0; $i < scalar(@xmin_phonemes); $i++) {

	# consider only plosives, skip rest	
	# if (!grep {$_ eq $text_phonemes[$i]} @plosives) {
	# 	next;
	# }

	if ($text_phonemes[$i] !~ m/\*/) {
		next;
	}

	##$xmin_proc_win[$k] = $xmin_phonemes[$i-1] + 0.5*($xmax_phonemes[$i-1]-$xmin_phonemes[$i-1]);
	$xmin_proc_win[$k] = $xmin_phonemes[$i-1] + 0.2*($xmax_phonemes[$i-1]-$xmin_phonemes[$i-1]);
	$xmax_proc_win[$k] = min($xmax_phonemes[$i]+0.1,$xmax_global);
	$text_proc_win[$k] = $i;

	if ($k >= 1 && $xmin_proc_win[$k] < $xmax_proc_win[$k-1]) {
		$xmax_proc_win[$k-1] = $xmin_proc_win[$k];
		if ($debug) {
			print "fixing-->".$xmin_proc_win[$k-1]." ".$xmax_proc_win[$k-1]." ".$text_proc_win[$k-1]."\n";
		}
	}

	$k++;
}

if ($debug) {
	for ($k=0; $k < scalar(@xmin_proc_win); $k++) {
		print $xmin_proc_win[$k]." ".$xmax_proc_win[$k]." ".($xmax_proc_win[$k]-$xmin_proc_win[$k])." ".$text_proc_win[$k]."\n";
	}
}


TextGrid::add_tier(\@tg_content, "Processing Window", \@xmin_proc_win, \@xmax_proc_win, \@text_proc_win);


open(OUTPUT,">$tg_filename") or die "Can't open $tg_filename for writing: $!\n";
print OUTPUT @tg_content;
close(OUTPUT);
