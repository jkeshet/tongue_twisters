
# This is perl module TextGrid
# written by Joseph Keshet, Sept 23, 2012.

package TextGrid;

sub extract_tier {

	my $textgrid_content = shift;
	my $desired_tier = shift;
	my $xmin_array = shift;  
	my $xmax_array = shift;
	my $text_array = shift;
	
  	$tier_was_found = 0;
	$xmax_global = 0;
  	$xmax_global_was_set = 0;
	$k = 0;
	while ($k < scalar(@$textgrid_content)) {
    	$_ = ${$textgrid_content}[$k]; $k++; chomp;
    	if ($_ =~ m/xmax/ && !$xmax_global_was_set) {
    		my ($dummy,$xmax) = split(/=/);
			trim($xmax_global);
			$xmax_global = $xmax;
    		$xmax_global_was_set = 1;
    	}
    	if (m/\"IntervalTier\"/) {
      		$line = ${$textgrid_content}[$k]; $k++; chomp $line; ($dummy, $tier_name) = split(/=/,$line);
      		$tier_name = trim($tier_name);
      		$tier_name =~ s/\"//g;
      		if ($tier_name eq $desired_tier) {
        		$tier_was_found = 1;
        		$begin = ${$textgrid_content}[$k]; $k++; chomp $begin;
        		$end = ${$textgrid_content}[$k]; $k++; chomp $end;
        		$num_events = ${$textgrid_content}[$k]; $k++; chomp $num_events; $num_events =~ s/intervals\:|size|=|\s//g;
        		#print "Tier was found: contains $num_events events.\n";
        		$j = 0;
        		for ($i=0; $i < $num_events; $i++) {
          			$intervals = ${$textgrid_content}[$k]; $k++; chomp $intervals;
          			$line = ${$textgrid_content}[$k]; $k++; chomp $line; ($dummy,$xmin) = split(/=/,$line);
          			$line = ${$textgrid_content}[$k]; $k++; chomp $line; ($dummy,$xmax) = split(/=/,$line);
          			$line = ${$textgrid_content}[$k]; $k++; chomp $line; ($dummy,$text) = split(/=/,$line);
          			next if (trim($text) eq "\"\""); #skip all non-events
          			@$xmin_array[$j] = trim($xmin);
          			@$xmax_array[$j] = trim($xmax);
          			@$text_array[$j] = trim($text);
          			@$text_array[$j] =~ s/\"//g;
          			#print "@$xmin_array[$j] @$xmax_array[$j] @$text_array[$j]\n";
          			$j++;
        		}
			}
    	}
  	}
  	if ($tier_was_found == 0) {
    	print "Tier \"$desired_tier\" was not found.\n";
    	return(0);
  	}
	else {
  		return($xmax_global);
  	}
}

sub add_tier {

	my $textgrid_content = shift;
	my $new_tier_name = shift;
	my $xmin_array = shift;  
	my $xmax_array = shift;
	my $text_array = shift;

	my $global_size = 0;
	my $xmax_global = 0;

	$array_size = scalar(@$xmin_array);
	# compute how many intervals needs to be written (the input array may contain gaps)
	$num_intervals = $array_size;
	$num_intervals++ if (@$xmin_array[0] != 0) ;
	for ($i = 1; $i < $array_size; $i++) {
		$num_intervals++ if (@$xmin_array[$i] != @$xmax_array[$i-1]);
	}

	$xmax_global_was_set = 0;
	$size_was_set = 0;
	$k = 0;
	while ($k < scalar(@$textgrid_content)) {
    	$_ = ${$textgrid_content}[$k]; $k++; chomp;
    	if ($_ =~ m/xmax/) {
    		my ($dummy,$xmax) = split(/=/);
			trim($xmax);
			$xmax_global = $xmax;
			$xmax_global_was_set = 1;
    	}
    	if ($_ =~ m/size/) {
    		my ($dummy,$size) = split(/=/);
    		trim($size);
    		$size++;
    		${$textgrid_content}[$k-1] = "size = $size\n";
			$global_size = $size;
			$size_was_set = 1;
    	}
    	last if ($xmax_global_was_set && $size_was_set);
    }

	$num_intervals++ if (@$xmax_array[$array_size-1] != $xmax_global);
	#print "array_size=$array_size\n";

	push(@$textgrid_content, "\titem [".$global_size."]:\n");
	push(@$textgrid_content, "\t\tclass = \"IntervalTier\"\n");
	push(@$textgrid_content, "\t\tname = \"$new_tier_name\"\n");
	push(@$textgrid_content, "\t\txmin = 0\n");
	push(@$textgrid_content, "\t\txmax = $xmax_global\n");
	push(@$textgrid_content, "\t\tintervals: size = $num_intervals\n");
	
	$i = 1; #interval index
	$j = 0; # array index;
	# first fill-the-gap-interval
	if (@$xmin_array[$j] != 0) {
		push(@$textgrid_content, "\t\tintervals [".$i."]:\n");
		push(@$textgrid_content, "\t\t\txmin = 0\n");
		push(@$textgrid_content, "\t\t\txmax = ".@$xmin_array[$j]."\n");
		push(@$textgrid_content, "\t\t\ttext = \"\"\n");
		$i++;
	}
	# first the VOT interval
	push(@$textgrid_content, "\t\tintervals [".$i."]:\n");
	push(@$textgrid_content, "\t\t\txmin = ".@$xmin_array[$j]."\n");
	push(@$textgrid_content, "\t\t\txmax = ".@$xmax_array[$j]."\n");
	push(@$textgrid_content, "\t\t\ttext = \"".@$text_array[$j]."\"\n");
	$i++; $j++;

	while ($j < $array_size) {
		# fill-the-gap-interval
		if (@$xmin_array[$j] != @$xmax_array[$j-1]) {
			push(@$textgrid_content, "\t\tintervals [".$i."]:\n");
			push(@$textgrid_content, "\t\t\txmin = ".@$xmax_array[$j-1]."\n");
			push(@$textgrid_content, "\t\t\txmax = ".@$xmin_array[$j]."\n");
			push(@$textgrid_content, "\t\t\ttext = \"\"\n");
			$i++;
		}
		# the VOT interval
		push(@$textgrid_content, "\t\tintervals [".$i."]:\n");
		push(@$textgrid_content, "\t\t\txmin = ".@$xmin_array[$j]."\n");
		push(@$textgrid_content, "\t\t\txmax = ".@$xmax_array[$j]."\n");
		push(@$textgrid_content, "\t\t\ttext = \"".@$text_array[$j]."\"\n");
		$i++; $j++;
	}

	# last interval
	if (@$xmax_array[$array_size-1] != $xmax_global) {
		push(@$textgrid_content, "\t\tintervals [".$i."]:\n");
		push(@$textgrid_content, "\t\t\txmin = ".@$xmax_array[$array_size-1]."\n");
		push(@$textgrid_content, "\t\t\txmax = ".$xmax_global."\n");
		push(@$textgrid_content, "\t\t\ttext = \"\"\n");
	}

}

sub read_tier {

	my $textgrid_filename = shift;
	my $desired_tier = shift;
	my $xmin_array = shift;  
	my $xmax_array = shift;
	my $text_array = shift;

  	$tier_was_found = 0;
  	$xmax_global_was_set = 0;
  	open(INPUT,"$textgrid_filename") or die "Can't open $textgrid_filename: $!\n";
  	while (<INPUT>) {
    	chomp;
    	if ($_ =~ m/xmax/ && !$xmax_global_was_set) {
    		my ($dummy,$xmax_global) = split(/=/);
			trim($xmax_global);
    		$xmax_global_was_set = 1;
    	}
    	if (m/\"IntervalTier\"/) {
      		$tier_name = <INPUT>; chomp $tier_name; ($dummy, $tier_name) = split(/=/,$line);
      		$tier_name = trim($tier_name);
      		$tier_name =~ s/\"//g;
      		if ($tier_name eq $desired_tier) {
        		$tier_was_found = 1;
        		$begin = <INPUT>; chomp $begin;
        		$end = <INPUT>; chomp $end;
        		$num_events = <INPUT>; chomp $num_events; $num_events =~ s/intervals\:|size|=|\s//g;
        		#print "Tier was found: contains $num_events events.\n";
        		$j = 0;
        		for ($i=0; $i < $num_events; $i++) {
          			$intervals = <INPUT>; chomp $intervals;
          			$line = <INPUT>; chomp $line; ($dummy,$xmin) = split(/=/,$line);
          			$line = <INPUT>; chomp $line; ($dummy,$xmax) = split(/=/,$line);
          			$line = <INPUT>; chomp $line; ($dummy,$text) = split(/=/,$line);
          			next if (trim($text) eq "\"\""); #skip all non-events
          			@$xmin_array[$j] = trim($xmin);
          			@$xmax_array[$j] = trim($xmax);
          			@$text_array[$j] = trim($text);
          			@$text_array[$j] =~ s/\"//g;
          			#print "@$xmin_array[$j] @$xmax_array[$j] @$text_array[$j]\n";
          			$j++;
        		}
			}
    	}
  	}
  	close(INPUT);	
  	if ($tier_was_found == 0) {
    	print "Tier \"$desired_tier\" was not found in $textgrid_filename\n";
  	}

  	return($xmax_global);
}

sub write_tier {

	my $textgrid_filename = shift;
	my $new_tier_name = shift;
	my $xmax_global = shift;
	my $xmin_array = shift;  
	my $xmax_array = shift;
	my $text_array = shift;

	$array_size = scalar(@$xmin_array);
	# compute how many intervals needs to be written (the input array may contain gaps)
	$num_intervals = $array_size;
	$num_intervals++ if (@$xmin_array[0] != 0) ;
	for ($i = 1; $i < $array_size; $i++) {
		$num_intervals++ if (@$xmin_array[$i] != @$xmax_array[$i-1]);
	}
	$num_intervals++ if (@$xmax_array[$array_size-1] != $xmax_global);
	#print "array_size=$array_size\n";

  	open(OUTPUT,">$textgrid_filename") or die "Can't open $textgrid_filename for writing: $!\n";
	print OUTPUT "File type = \"ooTextFile\"\n";
	print OUTPUT "Object class = \"TextGrid\" \n";
	print OUTPUT "\n";
	print OUTPUT "xmin = 0\n";
	print OUTPUT "xmax = $xmax_global\n";
	print OUTPUT "tiers? <exists>\n";
	print OUTPUT "size = 1\n";
	print OUTPUT "item []:\n";
	print OUTPUT "\titem [1]:\n";
	print OUTPUT "\t\tclass = \"IntervalTier\"\n";
	print OUTPUT "\t\tname = \"$new_tier_name\"\n";
	print OUTPUT "\t\txmin = 0\n";
	print OUTPUT "\t\txmax = $xmax_global\n";
	print OUTPUT "\t\tintervals: size = $num_intervals\n";
	
	$i = 1; #interval index
	$j = 0; # array index;
	if (@$xmin_array[$j] != 0) {# first fill-the-gap-interval
		print OUTPUT "\t\t\tintervals [".$i."]:\n";
		print OUTPUT "\t\t\t\txmin = 0\n";
		print OUTPUT "\t\t\t\txmax = ".@$xmin_array[$j]."\n";
		print OUTPUT "\t\t\t\ttext = \"\"\n";
		$i++;
	}
	# first the VOT interval
	print OUTPUT "\t\t\tintervals [".$i."]:\n";
	print OUTPUT "\t\t\t\txmin = ".@$xmin_array[$j]."\n";
	print OUTPUT "\t\t\t\txmax = ".@$xmax_array[$j]."\n";
	print OUTPUT "\t\t\t\ttext = \"".@$text_array[$j]."\"\n";
	$i++; $j++;

	while ($j < $array_size) {
		# fill-the-gap-interval
		if (@$xmin_array[$j] != @$xmax_array[$j-1]) {
			print OUTPUT "\t\t\tintervals [".$i."]:\n";
			print OUTPUT "\t\t\t\txmin = ".@$xmax_array[$j-1]."\n";
			print OUTPUT "\t\t\t\txmax = ".@$xmin_array[$j]."\n";
			print OUTPUT "\t\t\t\ttext = \"\"\n";
			$i++;
		}
		# the VOT interval
		print OUTPUT "\t\t\tintervals [".$i."]:\n";
		print OUTPUT "\t\t\t\txmin = ".@$xmin_array[$j]."\n";
		print OUTPUT "\t\t\t\txmax = ".@$xmax_array[$j]."\n";
		print OUTPUT "\t\t\t\ttext = \"".@$text_array[$j]."\"\n";
		$i++; $j++;
	}

	# last interval
	if (@$xmax_array[$array_size-1] != $xmax_global) {
		print OUTPUT "\t\t\tintervals [".$i."]:\n";
		print OUTPUT "\t\t\t\txmin = ".@$xmax_array[$array_size-1]."\n";
		print OUTPUT "\t\t\t\txmax = ".$xmax_global."\n";
		print OUTPUT "\t\t\t\ttext = \"\"\n";
	}
  	close(OUTPUT);


}

sub trim($) {
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}


1;