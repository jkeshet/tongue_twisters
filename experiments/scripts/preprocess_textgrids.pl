#!/usr/bin/perl -w

use lib "scripts";
use List::Util qw[min max];
use TextGrid;


unless ($#ARGV+1 >= 3) {
	print "Usage: $0 [-only_pos] <list of Wavs> <list of Textgrids> <front end output file>\n";
	print "       This utility extracts the vot labels from the given list of TextGrids, from a tier called \n";
	print "       \"vot\". Negative VOTs should be labeled with \"pre\" or \"neg\" included in the segment  \n";
	print "       description. A window of 50 msec before the onset and 2000 msec after the ofeset are marked as  \n";
	print "       processing window.\n\n";
	print "        ---- parameters need to be added: window onset and offset, tier name,  symbol for prevoiceing,\n";
	print "        ---- which VOT should be extracted (neg, pos, voiced, unvoiced).\n";
	exit;
}

#             v.wdStart,v.wdEnd = v.phStart - 0.05, min(v.phEnd+2,v.labEnd)

if ($#ARGV+1 == 4 && $ARGV[0] eq "-only_pos") {
	$only_pos = 1;
	$wav_list_filename = $ARGV[1];
	$tg_list_filename=$ARGV[2];
	$output_filename = $ARGV[3];
}
elsif ($#ARGV+1 == 3) {
	$only_pos = 0;
	$wav_list_filename = $ARGV[0];
	$tg_list_filename=$ARGV[1];
	$output_filename = $ARGV[2];
}
else {
	die "Error in input arguments\n";
}

open(WAV_FILES, "$wav_list_filename") or die "Can't open $wav_list_filename: $!\n";
@wav_files = <WAV_FILES>;
close(WAV_FILES);

open(TG_FILES, "$tg_list_filename") or die "Can't open $tg_list_filename: $!\n";
@tg_files = <TG_FILES>;
close(TG_FILES);

if (scalar(@wav_files) != scalar(@tg_files)) {
	die "The number of files listed in $wav_list_filename should be equal to the number of files listed in $tg_list_filename\n";
}

open(OUTPUT,">$output_filename") or die "Can't open $output_filename for writing: $!\n";

for ($j = 0; $j < scalar(@tg_files); $j++) {

	chomp $tg_files[$j];
	chomp $wav_files[$j];

	# read the whole input text grid
	open(INPUT,"$tg_files[$j]") or die "Can't open $tg_files[$j]: $!\n";
	@tg_content = <INPUT>;
	close(INPUT);

	# extract textgrid
	my (@xmin_vot, @xmax_vot, @text_vot);
	$xmax_global = TextGrid::extract_tier(\@tg_content, "vot", \@xmin_vot, \@xmax_vot, \@text_vot);

	for ($i = 0; $i < scalar(@xmin_vot); $i++) {
		next if ($only_pos && ($text_vot[$i] =~ /pre/i || $text_vot[$i] =~ /neg/i) );
		$xmin_proc_win = $xmin_vot[$i] - 0.05;
		$xmax_proc_win = min($xmax_vot[$i] + 0.5,$xmax_global);
		print  OUTPUT $wav_files[$j]." ".int(16000*$xmin_proc_win)." ".int(16000*$xmax_proc_win)." ".int(16000*$xmin_vot[$i])." ".int(16000*$xmax_vot[$i])."\n";
	}

}

close(OUTPUT);
