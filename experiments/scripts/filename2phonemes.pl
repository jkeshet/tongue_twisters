#!/usr/bin/perl -w

use File::Basename;

unless ($#ARGV+1 >= 2) {
    print "Usage: $0 [-debug] filename filename-phoneme-map \n";
    exit;
}

my @other_plosives = qw(B D G K P T);
my @start_plosives = qw(*B *D *G *K *P *T);
my @nasals_and_liquids = qw(NG N M L R);


# parse command line
if ($ARGV[0] eq "-debug")
{
	$debug = 1;
	$filename = $ARGV[1];
	$map_file = $ARGV[2];
}
else {
	$debug = 0;
	$filename = $ARGV[0];
	$map_file = $ARGV[1];
}

%map = ();
open(MAPFILE, $map_file) or die "Can't open $map_file:$!\n";
while (<MAPFILE>) {
	chomp;
	$_ =~ s/\s+$//;
	($stimid,$phoneme_string)=split(/,/,$_,2);
	#print "-->$stimid<-->$phoneme_string<--\n" if ($debug);
	$map{$stimid} = ",".$phoneme_string;
}
close(MAPFILE);


$pfilename = basename($filename,".wav");

# remove the "-short.wav" at the end of the file
$pfilename =~ s/\.wav//;
$pfilename =~ s/-short//;
## remove the "001-" at the begining of the file
#$pfilename =~ s/001-//;
# remove the first 4 characters at the beginning (subjID '001-'')
$pfilename = substr($pfilename,4,length($pfilename));
# remove the last character at the end (0 or 1)
$pfilename = substr($pfilename,0,length($pfilename)-1);


if (exists($map{$pfilename})) {
	$pstring = $map{$pfilename};
	print STDERR "/$pstring/\n" if ($debug);
	# remove .
	$pstring =~ s/\./ /g;
	# replace , with " *"
	$pstring =~ s/,/ \*/g;	
	#$pstring =~ s/,/ /g;	
	# remove white space at the beginnig
	$pstring =~ s/^\s+//;

	print STDERR "/$pstring/\n" if ($debug);

	# add closure to some plosives
	$new_pstring = '';
	@phonemes = split(/\s/,$pstring);
	for ($i=0; $i < scalar(@phonemes); $i++) {
		if ($i == 0) {
			$new_pstring .= "sil $phonemes[$i] ";
		}
		elsif (grep {$_ eq $phonemes[$i]} @start_plosives)  {
			$new_pstring .= "sil $phonemes[$i] ";
		}
		elsif ( (grep {$_ eq $phonemes[$i]} @other_plosives) && !(grep {$_ eq $phonemes[$i-1]} @nasals_and_liquids) ) {
			$new_pstring .= "sil $phonemes[$i] ";
		}
		else {
			$new_pstring .= "$phonemes[$i] ";
		}
		
	}

	$pstring = $new_pstring;

	# $pstring =~ s/\*B/sil *b/g;
	# $pstring =~ s/\*D/sil *d/g;
	# $pstring =~ s/\*G/sil *g/g;
	# $pstring =~ s/\*K/sil *k/g;
	# $pstring =~ s/\*P/sil *p/g;
	# $pstring =~ s/\*T/sil *t/g;
	# $pstring =~ s/B/sil b/g;
	# $pstring =~ s/D/sil d/g;
	# $pstring =~ s/G/sil g/g;
	# $pstring =~ s/K/sil k/g;
	# $pstring =~ s/P/sil p/g;
	# $pstring =~ s/T/sil t/g;

	print STDERR "/$pstring/\n" if ($debug);

	# convert phoneme to lowercase
	$pstring = lc($pstring);

	print STDERR "/$pstring/\n" if ($debug);

	# multiply by 3 and add /sil/ at the end
	print "$pstring $pstring $pstring sil\n";
}
else {
	print STDERR "Error: unable to find phoneme mapping to $filename (shortened to $pfilename) in $map_file\n";
}



sub trim($) {
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

#10-3-2012; Altered $pfilename processing section to remove any subjID (first 4 chars).