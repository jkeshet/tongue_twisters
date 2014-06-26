#!/usr/bin/perl -w

unless ($#ARGV+1 == 1 || $#ARGV+1 == 3) {
	print "Usgae: $0 [-n num_files] <HTK file list>\n";
	exit;
}

if ($ARGV[0] eq "-n") {
	$num_files = $ARGV[1];
	$file_list = $ARGV[2];
}
else {
	$file_list = $ARGV[0];
}

# check the number of features
open(FILELIST,"$file_list") or die "Error: unable to open $file_list $!\n";
$first_file = <FILELIST>;
chomp $first_file;
open(PHNFILE, "HList -r $first_file |") or die "Cannot open file $first_file: $!\n";
$first_line = <PHNFILE>;
chomp $first_line;
@features = split(/ /,$first_line);
close(PHNFILE);
close(FILELIST);
$num_features = scalar(@features);

# define array that stores the average length of each phoneme
$n = 0;
for ($i = 0; $i < $num_features; $i++) {
	$average[$i] = 0;
	$std[$i] = 0;
}

# Run over the file list
open(FILELIST,"$file_list") or die "Error: unable to open $file_list $!\n";
while (<FILELIST>) {
	chomp;
	open(PHNFILE, "HList -r $_ |") or die "Cannot open file $_: $!\n";
	while (<PHNFILE>) {
		chomp;
		@features = split;
		$n++;
		for ($i=0; $i < $num_features; $i++) {	    
			$average[$i] = ( ($n-1)*$average[$i] + $features[$i] )/$n;
			$std[$i] = ( ($n-1)*$std[$i] + $features[$i]**2 )/$n;
			# if ($i == 0) {
			# 	print $features[$i]," ", $average[$i], " ", $std[$i],"\n";
			# }
		}
	}
	close(PHNFILE);
	$num_files--;
	last if ($num_files <= 0);
}
close(FILELIST);

print "2 $num_features\n"; # infra textual format
for ($i = 0; $i < $num_features; $i++) {
	print "$average[$i] ";
}
print "\n";

for ($i = 0; $i < $num_features; $i++) {
	$std[$i] = sqrt($std[$i] - $average[$i]**2);
	print "$std[$i] ";
}
print "\n";
