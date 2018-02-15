#Add total chars read from a file to get percentage of latins which MAY be > 0 in some cases.

# DetectCharSet.pl
# This script attempts to determine the likely character encoding of a flat file. 
# See PrintUsage function for more details.
#
# Usage: DetectCharSet.pl <File to check> 
#
# where
#
# <File to check> is the input to verify or repair. The file is only read.
#
# V1.6 Fixed defect in UTF-8 evaluation where last buffer of file was not fully examined for errors of the buffer had at least one error.

my $version = "1.6";


#use feature 'unicode_strings';
use Encode qw(decode encode);
use strict 'vars';
use Class::Struct;
use File::Glob;

# Defined constants for logging messages based on log type
use constant {
	LOG_DEBUG =>  3,	# Debug level log
	LOG_DETAIL => 2,	# Detailed log 
	LOG_NORMAL => 1,	# normal log level
	LOG_BRIEF =>  0,	# Brief log
};

#my @list = Encode->encodings();
#my @list = Encode->encodings(":all");
#print "Available encodings:\n";
#foreach my $e (@list) {
#	print " $e\n";
#}
#die;


#-----------------------------------
# Define Structures for holding each character set stats
#-----------------------------------

# Note that these are arranged in order of most likely to be eliminated
my @encodings = ('UTF-32BE', 'UTF-32LE', 'UTF-16BE', 'UTF-16LE', 'EBCDIC', 'UTF-8', 'ASCII', 'CP1252');

struct ( 'CharSetStats', {
	name => '$',			# Name of char set
	totalChars => '$',		# Total number of chars in file
	goodChars => '$',		# Number of chars that were successfully loaded
	illegalChars => '$',	# Number of illegal chars (or errors or warnings during call to decode)
	subCharCt => '$',		# Number of substitution characters
	latinChars => '$',		# Number of chars that fit in CP1252 char set in file
	asciiChars => '$',		# Number of chars thay fit in ASCII char set in file
	hasBom => '$',			# BOM sequence detected
	utf8LatinIntroChars => '$',	# Number of occurrences of the UTF-8 Extended latin introducer chars (C2 and C3)
	validutf8Chars => '$',		# Number of valid 2 byte UTF8 sequences 
	charsAbove256 => '$',		# number of characters in a Unicode encoding that cannot be stored in our Oracle single byte char set
});

#------------------------------------------------------------------
# Every valid EBCDIC character is non-zero
# For valid chars, if it's also an ASCII latin-1 alpha or digit then it's 2 otherwise 1
#------------------------------------------------------------------

#my @ebcdicGood = (0, 0, 1, 1, 2, 1, );
my @ebcdicGood = (
#   0    1    2    3    4    5    6    7
#   8    9    A    B    C    D    E    F
    0,   0,   0,   0,   0,   2,   0,   0,  #	 8 /* 0x00	*/
    0,   0,   0,   0,   0,   2,   0,   0,  #	16  /* 0x08	*/
    0,   0,   0,   0,   0,   0,   0,   0,  #	24 /* 0x10	*/
    0,   0,   0,   0,   0,   0,   0,   0,  #	32  /* 0x18	*/
    1,   0,   0,   0,   0,   2,   0,   0,  #	40  /* 0x20	*/
    0,   0,   0,   0,   0,   0,   0,   0,  #	48  /* 0x28	*/
    0,   0,   0,   0,   0,   0,   0,   0,  #	56  /* 0x30	*/
    0,   0,   0,   0,   0,   0,   0,   0,  #	64  /* 0x38	*/
    1,   0,   4,   4,   4,   4,   4,   4,  #	72  /* 0x40	*/
    4,   4,   1,   1,   1,   1,   1,   1,  #	80  /* 0x48	*/
    1,   4,   4,   4,   4,   4,   4,   4,  #	88  /* 0x50	*/
    4,   4,   1,   1,   1,   1,   1,   1,  #	96  /* 0x58	*/
    1,   1,   4,   4,   4,   4,   4,   4,  #	104 /* 0x60	*/
    4,   4,   1,   1,   1,   1,   1,   1,  #	112 /* 0x68	*/
    1,   4,   4,   4,   4,   4,   4,   4,  #	120 /* 0x70	*/
    4,   1,   1,   1,   1,   1,   1,   1,  #	128 /* 0x78	*/
    1,   2,   2,   2,   2,   2,   2,   2,  #	136 /* 0x80	*/
    2,   2,   0,   0,   0,   4,   0,   0,  #	144 /* 0x88	*/
    0,   2,   2,   2,   2,   2,   2,   2,  #	152 /* 0x90	*/
    2,   2,   0,   0,   4,   1,   4,   0,  #	160 /* 0x98	*/
    0,   1,   2,   2,   2,   2,   2,   2,  #	168 /* 0xA0	*/
    2,   2,   0,   0,   0,   4,   0,   1,  #	176 /* 0xA8	*/
    1,   4,   4,   0,   4,   0,   0,   0,  #	184 /* 0xB0	*/
    0,   0,   1,   1,   0,   0,   0,   0,  #	192 /* 0xB8	*/
    1,   2,   2,   2,   2,   2,   2,   2,  #	200 /* 0xC0	*/
    2,   2,   1,   4,   4,   4,   4,   4,  #	208 /* 0xC8	*/
    1,   2,   2,   2,   2,   2,   2,   2,  #	216 /* 0xD0	*/
    2,   2,   0,   1,   1,   1,   1,   1,  #	224 /* 0xD8	*/
    1,   0,   2,   2,   2,   2,   2,   2,  #	232 /* 0xE0	*/
    2,   2,   1,   1,   1,   1,   1,   1,  #	240 /* 0xE8	*/
    2,   2,   2,   2,   2,   2,   2,   2,  #	248 /* 0xF0	*/
    2,   2,   0,   4,   4,   4,   4,   4,  #	256 /* 0xF8	*/
);

my %charSetStats;			# Key is char set name, value is struct charSetStats

# Interesting char values
my $charBOM = 0xFEFF;
my $charIllegal = 65553;

# Limits
my $illegalCharThreshold = 200; 	# stop evaluating an encoding if more than tis many errors are found
my $noLatinStopLimit = 220000;		# Stop evaluating an encoding if no ASCII or Latin characters are found in this many bytes.
# Other vars
my $logType = LOG_NORMAL; 	# Default is full log
my $startTime = time;
my $ErrorCt = 0;
my $LineCt = 0;
my $bFlagControlChars = 1;
my $dumpLineCount = 50;
#my $bLogVerbose = 0;
my $infile = '';

# Fetch and parse command line
my $argc = $#ARGV + 1;
&ParseCommandLine($argc, @ARGV);

my @fileList;
push(@fileList, glob($infile));
#print "Filelist: ", join(", ", @fileList), "\n";

foreach $infile (@fileList) {
	$LineCt = 0;
	$ErrorCt = 0;
	#
	# Open files and begin processing
	#
	my $logfile = "$infile.log";
	open (LOG, ">$logfile") || die "Error opening log file $logfile: $!\n";
	#logit(LOG_NORMAL, "Attempting to determine the character encoding of file '$infile'.\n");
	logit(LOG_BRIEF, "File '$infile'.\n");

	# Get file size so we can display percent done
	if (!open (IN, $infile)) {
		#logit(LOG_NORMAL, "Error opening input file $infile\n$!\n");
		logit(LOG_BRIEF, "Error opening input file $infile\n$!\n");
		die "Error opening input file $infile\n$!\n";
	} 
	seek(IN, 0, 2);
	my $fileSize = tell(IN);
	close(IN);
	if ($fileSize == 0) {
		#logit(LOG_NORMAL, "The input file is empty.\n");
		logit(LOG_BRIEF, "     The input file is empty.\n");
#		die "\n";
		close(IN);
		next;
	}


	TryAllEncodings($infile);

	# Now perform analysis on results to decide on encoding
	my %candidates;
	my %eliminated;
	my $candidateCt = 0;
	foreach my $e (@encodings) {
		$candidates{$e} = $e;
		$candidateCt++;
	}

	# Remove candidates with errors
	foreach my $c (@encodings) {
		my $s = $charSetStats{$c};
		if ($s->illegalChars > 0) {
			my $badChars = $s->illegalChars;
			$eliminated{$c} = sprintf "%-10.10s: input file would contain too many illegal code points (> $badChars)to be in this encoding.\n", $c;
			delete $candidates{$c};
			$candidateCt--;
		} else {
			my $percentLatin = $s->latinChars / $s->goodChars * 100;
			if ($s->goodChars == 0 or $percentLatin < 5) {
				$eliminated{$c} = sprintf "%-10.10s: this encoding would result in %2.2f%% of the %d good characters read being Latin-1 characters which is extremely unlikely.\n", $c, $percentLatin, $s->goodChars;
				delete $candidates{$c};
				$candidateCt--;
			}
		}
	}

	# Check of any of the remaining ones have a BOM and if one of them does, remove ones that don't
	my $withBom = 0;
	foreach my $c (keys(%candidates)) {
		my $s = $charSetStats{$c};
		$withBom++ if ($s->hasBom);
	}
	if ($withBom and $candidateCt != $withBom) {
		foreach my $c (@encodings) {
			if (defined $candidates{$c}) {
				my $s = $charSetStats{$c};
				if ($s->hasBom == 0) {
					$eliminated{$c} = sprintf "%-10.10s: existence of a Unicode BOM for another encoding makes this encoding unlikely.\n", $c;
					delete $candidates{$c};
					$candidateCt--;
				}
			}
		}
	}

	# If more than one candidate remains, flag ones that are likely wrong because of the likelihood if it really being UTF-8
	foreach my $c (@encodings) {
		if (defined $candidates{$c}) {
			my $s = $charSetStats{$c};
			if ($s->utf8LatinIntroChars > 0 and ($s->utf8LatinIntroChars == $s->validutf8Chars)) {
	#			$eliminated{$c} = sprintf "%-10.10s: warning: while no illegal characters were found, the existence of %d valid UTF-8 code sequences makes this encoding unlikely.\n", $c, $s->validutf8Chars;
	#			delete $candidates{$c};
	#			$candidateCt--;
			}
		}
	}


	logit(LOG_NORMAL, "\n-----------------------------------------------------------------------\n");
	logit(LOG_NORMAL, "   The most likely encodings after evaluation are (in no particular order):\n");
	foreach my $c (@encodings) {
		if (defined $candidates{$c}) {
			my $buf = sprintf("     %-10.10s", $c);
			my $s = $charSetStats{$c};
			if ($s->utf8LatinIntroChars > 0 and ($s->utf8LatinIntroChars == $s->validutf8Chars)) {
				$buf .= sprintf ": warning: while no illegal characters were found, the existence of %d valid UTF-8 code sequences makes this encoding unlikely.", $s->validutf8Chars;
			}
			if ($s->subCharCt > 0) {
				my $badChars = $s->subCharCt;
				my $charsAbove256 = $s->charsAbove256;
				$buf .= sprintf ": warning input file contains $charsAbove256 characters that cannot be stored in a single byte database and it also contains $badChars Unicode substitution characters (U+FFFD). It may not load successfully.";
			}
			$buf .= "\n";
			#logit(LOG_NORMAL, $buf);
			logit(LOG_BRIEF, $buf);
		}
	}
	if ($candidateCt > 1) {
		logit(LOG_NORMAL, "\n  The input file provided is compatible with all of the above encodings, so an exact encoding cannot be determined.\n");
		logit(LOG_NORMAL, "  A different sample of the input file may have different results.\n");
	} elsif ($candidateCt == 0) {
		logit(LOG_BRIEF, "\n  The input file is not compatible with any of the encodings tried. It may be in some other encoding or it may simply be bad.\n");
		logit(LOG_BRIEF, "  Check with the client on what encoding they think the file is in.\n");
		logit(LOG_BRIEF, "  A different sample of the input file may have different results.\n");
		logit(LOG_BRIEF, "  Also review the reasons below to see why each encoding was eliminated.\n");
	}
	logit(LOG_NORMAL, "-----------------------------------------------------------------------\n");

	logit(LOG_NORMAL, "\nThe following encodings were eliminated for the reasons given:\n");
	foreach my $c (@encodings) {
		if (defined $eliminated{$c}) {
			logit(LOG_NORMAL, sprintf "  %s", $eliminated{$c});
		}
	}

	if ($logType >= LOG_NORMAL) {
		logit(LOG_NORMAL, "\n------------------------------------------------------------------------------------------\n");
		logit (0, " PLEASE READ THE FOLLOWING IMPORTANT NOTES IF YOU ARE STILL HAVING ISSUES LOADING THIS FILE\n");
		logit(LOG_NORMAL, "--------------------------------------------------------------------------------------------\n");
		logit(LOG_NORMAL, "\nSometimes files are just messed up. They can have extraneous problem characters in them that can make them\n");
		logit(LOG_NORMAL, "appear to be in some other encoding or not in the encoding that they actually are in. If you are still having issues loading\n");
		logit(LOG_NORMAL, "the file, you may need to visually inspect it. The following dump may help to identify some issues.\n");
		logit(LOG_NORMAL, "\nIf you still have questions about the encoding or if more than one possible encoding was identified, the following partial dump of the file may help.\n");
		logit(LOG_NORMAL, "This dump shows records that have ASCII control characters (x00-x08, x0B, x0C, x0E-x1F) or \"extended\" characters, those above the ASCII character set (> 0x7F).\n");
		logit(LOG_NORMAL, "This is intended only to help you identify potential issues with the file, regardless of the actual character encoding. A maximum of $dumpLineCount such records will be displayed.\n");
		logit(LOG_NORMAL, "To display more records, use the -c command line option to specify the number you want.\n");
		logit(LOG_NORMAL, "\nNote that occurrences of the two-character sequence starting with C2 or C3 followed by a value in the range 80-BF is a sign that the file is UTF-8. For example, [C3][89].\n");
		logit(LOG_NORMAL, "\nFormat is: line number(# of extended chars, # of control chars): line with identified extended chars [xx] and control chars <xx>\n");
		logit(LOG_NORMAL, "\n-------------------------------------------------------------------------------------------\n");



		# Reg ex to find "illegal" chars
		my $regexCtrl= '[\x00-\x08\x0B\x0C\x0E-\x1F]';	# Finds ASCII control chars (not used)
		my $regex1252 = '[\x80-\xFF]';			# Flag all code points above ASCII

		my $linesDisplayed = 0;
		open (IN, $infile) || die "Error opening input file $infile\n$!\n";
		while (<IN>)
		{
			$LineCt++;
			if ($LineCt % 50000 == 0) {
				my $curPos = tell(IN);
				my $percentDone = int(($curPos / $fileSize) * 100);
				print STDERR sprintf("%d%% done\r", $percentDone);
			}
			my $hasBadChars = 0;	# Line has illegal chars if true
			my $hasCtrlChars = 0;	# Line has control chars if true
			# Does the line have any chars to log ?(Illegal + Control chars if -c given
			$hasBadChars = /${regex1252}/;
			$hasCtrlChars = /${regexCtrl}/ if ($bFlagControlChars);
			if ($hasBadChars || $hasCtrlChars) {
				# If verbose log mode, create the log line with illegal and control chars substituted with hex equivalents
				# We need to do this before the input line ($_) is modified
				my $logLine = '';
				$logLine = $_;
				$logLine =~ s/(${regexCtrl})/sprintf("<%02X>", ord($1))/ge if ($hasCtrlChars);
				$logLine =~ s/(${regex1252})/sprintf("[%02X]", ord($1))/ge if ($hasBadChars);


				# Get counts of illegal and control chars and remove illegal chars
				my $numBadChars = 0;
				my $numCtrlChars = 0;
				if ($hasBadChars) {
					$numBadChars = s/${regex1252}//g;
				}		
				if ($hasCtrlChars) {
					$numCtrlChars = s/(${regexCtrl})/$1/g;	# we just sub back same value to get count
		#			$numCtrlChars = () = /(${regexCtrl})/g;	# tried this but sub was faster
				}		

				if ($bFlagControlChars) {
					logit(LOG_NORMAL, sprintf("%9d(%3d, %3d): ", $LineCt, $numBadChars, $numCtrlChars));
				} else {
					logit(LOG_NORMAL, sprintf("%9d(%3d): ", $LineCt, $numBadChars));
				}
				logit(LOG_NORMAL, $logLine);
				$linesDisplayed++;
				if ($linesDisplayed > $dumpLineCount) {
					logit(LOG_NORMAL, "     -- Maximum of $dumpLineCount records displayed reached. There may be more lines with control or extended characters. Use -c on command line to change. --\n");
					last;
				}
			}
		}
		if ($linesDisplayed == 0) {
			logit(LOG_NORMAL, "   No control or extended characters were found.\n");
		} elsif ($linesDisplayed < $dumpLineCount or eof IN) {
			logit(LOG_NORMAL, "     -- $linesDisplayed lines were found with control or extended chaaracters. All are displayed above. --\n");
		}
		print STDERR "100% done\n";
		

		close(IN);
	}

	logit(LOG_NORMAL, sprintf("\nTotal lines in file:             %11s\n", commify($LineCt)));
	logit(LOG_NORMAL, sprintf(  "File size in bytes:              %11s\n", commify($fileSize)));
	close(LOG);
}

my $endTime = time;
my $runTimeMsg = "\nTotal run time(HH:MM:SS): " . secsToHMS($endTime - $startTime) . "\n";
logit(LOG_NORMAL, $runTimeMsg);
print STDERR $runTimeMsg;
print STDERR "Script execution is completed\n";

#open (IN, $infile) || die "Error opening input file $infile\n$!\n";


#--------------------------------------------------------------------------
#--------------------------------------------------------------------------
sub printHex($) {
	my $values = shift;
	my $buf = '(';
	for (my $i=0; $i < length($values); $i++) {
		$buf .= sprintf("0x%2.2X", ord(substr($values, $i, 1)));
		$buf .= ', ' if ($i < length($values) - 1);
	}
	$buf .= ')';
}

#--------------------------------------------------------------------------
# Log exceeded error threshold message
#--------------------------------------------------------------------------
sub logExceededError() {
	logit(LOG_DETAIL, "  Exceeded error threshold of ", $illegalCharThreshold, " illegal characters or no ASCII or Latin characters found in first ", $noLatinStopLimit, " bytes. Stopping evaluation of this encoding.\n");
}


#--------------------------------------------------------------------------
# This functions supports testing only Unicode 32 bit encodings
#--------------------------------------------------------------------------
sub IsEncodedAsUnicode32($$) {
	my ($filename, $encoding) = @_;
	
	my $errorCt = 0;
	my $charCt = 0;
	my $goodChars = 0;
	my $latinCt = 0;
	my $asciiCt = 0;
	my $subCharCt = 0;
	my $bomCt = 0;
	my $charsAbove256 = 0;
# This encoding allows all bytes to be loaded as-is so later encodings will work as expected.
#	open (IN, "<:encoding($encoding)", $infile) || die "Error opening input file $infile while checking for encoding $encoding\n$!\n";

	# Open the file as binary, read octets and pass to decode function
	open (IN, $filename) || die "Error opening input file $filename while checking for encoding $encoding\n$!\n";
	binmode(IN);
	my $buffer;
	my $ioResult;
	my $totalBytes = 0;
	# Use of eval here allows trapping of decoding errors for illegal characters in the decode() function (if the decoder supports it)
	#print "SIGNALS: ", keys(%SIG), "\n";
	while($ioResult = read(IN, $buffer, 65536, length($buffer))) {
		$totalBytes += $ioResult;
		my $characters = '';
		#print "read one line\n";
		# Decode 4 bytes at a time
		for (my $n=0; $n < $ioResult; $n+=4) {
			my $tmp = substr($buffer, $n, 4);
			my $startErrorCt = $errorCt;
			eval { local $SIG{__WARN__} = sub { $errorCt++ };
				$characters = decode($encoding, $tmp, Encode::FB_QUIET); #::FB_CROAK);
			};
			if ($errorCt != $startErrorCt) {
				logit(LOG_DETAIL, "  Illegal Unicode code point ", sprintf("(U+%8.8X)", ord(substr($characters, 0, 1))), " starting at file offset ", $totalBytes - $ioResult + $n, ". Skipping 4 bytes to resync.\n");
			} else {
				$goodChars++;
				my $c = ord(substr($characters, 0, 1));
				if ($c < 256) {
					$latinCt++;
				}
				if ($c < 128) {
					$asciiCt++;
				}
				if ($c == 0xFEFF) { # Unicode Byte Order Marker
					$bomCt++;
					my $tmp = $totalBytes - $ioResult + $n;
					logit(LOG_NORMAL, sprintf("  warning: Unicode byte order marker U+%4.4X found at or near offset $tmp.\n", $c, $tmp));
				}
			}
			if($errorCt > $illegalCharThreshold or ($latinCt == 0 and $totalBytes > $noLatinStopLimit)) {
				logExceededError();
				last;
			}
		}
		
		last if($errorCt > $illegalCharThreshold or ($latinCt == 0 and $totalBytes > $noLatinStopLimit));
	}
	logit(LOG_DEBUG, "  result=$@\n");
	logit(LOG_DEBUG, "  read error: $!\n") if (!defined $ioResult);
	logit(LOG_DEBUG, "  ioresult=", $ioResult, "\n");
	logit(LOG_DEBUG, "  Len buffer=", length($buffer), "\n");
	close(IN);
	return ($charCt, $goodChars, $errorCt, $subCharCt, $latinCt, $asciiCt, $bomCt, 0, 0, $charsAbove256);
}

#--------------------------------------------------------------------------
# This functions supports testing only Unicode 16 bit encodings
#--------------------------------------------------------------------------
sub IsEncodedAsUnicode16($$) {
	my ($filename, $encoding) = @_;
	
	my $errorCt = 0;
	my $goodChars = 0; 
	my $charCt = 0;
	my $latinCt = 0;
	my $asciiCt = 0;
	my $subCharCt = 0;
	my $bomCt = 0;
	my $charsAbove256 = 0;
	my $isBE = $encoding eq 'UTF-16BE';
	
	# Open the file as binary, read octets and pass to decode function
	open (IN, $filename) || die "Error opening input file $filename while checking for encoding $encoding\n$!\n";
	binmode(IN);
	my $buffer;
	my $ioResult;
	my $totalBytes = 0;
	# Use of eval here allows trapping of decoding errors for illegal characters in the decode() function (if the decoder supports it)
	#print "SIGNALS: ", keys(%SIG), "\n";
	while($ioResult = read(IN, $buffer, 65536, length($buffer))) {
		$totalBytes += $ioResult;
		my $characters = '';
		logit(LOG_DEBUG, "Read a buffer load $ioResult bytes.\n");
		if (eof IN and $ioResult & 1 == 1) {
			$errorCt++;
			$ioResult--;
			logit(LOG_DEBUG, "error: dd byte count in last buffer -- dropping last byte.\n")
		}
		# Decode 2 bytes at a time
		for (my $n=0; $n < $ioResult; $n+=2) {
			my $w1;
			# Get word as LE or BE
			if ($isBE) {
				$w1 = ord(substr($buffer, $n, 1)) << 8 | ord(substr($buffer, $n+1, 1));
			} else {
				$w1 = ord(substr($buffer, $n+1, 1)) << 8 | ord(substr($buffer, $n, 1));
			}
#			if ($totalBytes - $ioResult + $n == 0) {
#				logit(LOG_DETAIL, sprintf ("W1=0x%4.4X\n", $w1));
#			}
			# Now evaluate the value
			if ($w1 == 0xFFFE or $w1 == 0xFFFF) { # these two points are non-chars
				$errorCt++;
				logit(LOG_DETAIL, "  Illegal Unicode code point ", sprintf("(U+%4.4X)", $w1), " starting at file offset ", $totalBytes - $ioResult + $n, ". Skipping 4 bytes to resync.\n");
			}
			elsif ($w1 < 0xD800 or $w1 >0xDFFF) {
				$goodChars++;
				# Is valid one word value, set stats
				if ($w1 < 256) {
					$latinCt++;
				}
				if ($w1 < 128) {
					$asciiCt++;
				}
				if ($w1 == 0xFEFF) { # Unicode Byte Order Marker
					$bomCt++;
					my $tmp = $totalBytes - $ioResult + $n;
					logit(LOG_NORMAL, sprintf("  warning: Unicode byte order marker U+%4.4X found at or near offset $tmp.\n", $w1, $tmp));
				}
			} elsif ($w1 >= 0xD800 and $w1 <= 0xDBFF) {
				# two word value. Need to look at next word
				$n += 2;
				# if there a next word?
				if ($n < $ioResult) {	 # have next word
					my $w2;
					if ($isBE) {
						$w2 = ord(substr($buffer, $n, 1)) << 8 | ord(substr($buffer, $n+1, 1));
					} else {
						$w2 = ord(substr($buffer, $n+1, 1)) << 8 | ord(substr($buffer, $n, 1));
					}
					if ($w2 < 0xDC00 or $w2 > 0xDFFF) {
						$errorCt++;
						logit(LOG_DETAIL, "  Illegal Unicode code point ", sprintf("(U+%4.4X)", $w1), " starting at file offset ", $totalBytes - $ioResult + $n, ". Skipping 4 bytes to resync.\n");
					} else {
						$goodChars++;
					}
				} else {	# No next word
					$errorCt++;
					logit(LOG_DETAIL, "  Illegal Unicode code point ", sprintf("(U+%4.4X)", $w1), " starting at file offset ", $totalBytes - $ioResult + $n, ". Skipping 4 bytes to resync.\n");
				}
			} else {	
				$errorCt++;
				logit(LOG_DETAIL, "  Illegal Unicode code point ", sprintf("(U+%4.4X)", $w1), " starting at file offset ", $totalBytes - $ioResult + $n, ". Skipping 4 bytes to resync.\n");
			}

			if($errorCt > $illegalCharThreshold or ($latinCt == 0 and $totalBytes > $noLatinStopLimit)) {
				logExceededError();
				last;
			}
		}
		$buffer = '';
		logit(LOG_DEBUG, "  ErrorCt=$errorCt, length=", length($buffer), ", latins=$latinCt, ioResult=$ioResult\n");
		last if($errorCt > $illegalCharThreshold or ($latinCt == 0 and $totalBytes > $noLatinStopLimit));
	
	}
	logit(LOG_DEBUG, "  result=$@\n");
	logit(LOG_DEBUG, "  read error: $!\n") if (!defined $ioResult);
	logit(LOG_DEBUG, "  ioresult=", $ioResult, "\n");
	logit(LOG_DEBUG, "  Len buffer=", length($buffer), "\n");
	close(IN);
	return ($charCt, $goodChars, $errorCt, $subCharCt, $latinCt, $asciiCt, $bomCt, 0, 0, $charsAbove256);
}

#--------------------------------------------------------------------------
# This function makes a decision as to whether the provided file is encoded in the provided encoding 
# The first parameter is the file name and the second is a valid Perl encoding name
# Regturns the number of errors (5 is the max)
#--------------------------------------------------------------------------
sub IsEncodedAsUnicode($$) {
	my ($filename, $encoding) = @_;
	
	my $errorCt = 0;
	my $goodChars = 0; 
	my $charCt = 0;
	my $latinCt = 0;
	my $asciiCt = 0;
	my $subCharCt = 0;
	my $bomCt = 0;
	my $charsAbove256 = 0;
# This encoding allows all bytes to be loaded as-is so later encodings will work as expected.
#	open (IN, "<:encoding($encoding)", $infile) || die "Error opening input file $infile while checking for encoding $encoding\n$!\n";

	# Open the file as binary, read octets and pass to decode function
	open (IN, $filename) || die "Error opening input file $filename while checking for encoding $encoding\n$!\n";
	binmode(IN);
	my $buffer;
	my $ioResult;
	my $totalBytes = 0;
	# Use of eval here allows trapping of decoding errors for illegal characters in the decode() function (if the decoder supports it)
	#print "SIGNALS: ", keys(%SIG), "\n";
	eval { local $SIG{__WARN__} = sub { $errorCt++ };
		# repeat while we have some leftover buffer from prior read or the buffer is empty and we've reached EOF
		while(length($buffer) > 0 or $ioResult = read(IN, $buffer, 65536, length($buffer))) {
			my $bufferCopy = $buffer;
			$totalBytes += $ioResult;
			#print "read one line\n";
			my $characters = decode($encoding, $buffer, Encode::FB_QUIET); #::FB_CROAK);
			logit(LOG_DEBUG, "  Decoded chars: ", length($characters), "\n");
			my $bytesLeftover = length($buffer);
			logit(LOG_DEBUG, "  Bytes left in buffer after decoding: ", $bytesLeftover, "\n")  if ($bytesLeftover > 0);
			$charCt += length($characters);
			# Note that $o is used to track where we are in the input buffer for accurate location reporting
			for (my $i=0, my $o=0; $i<length($characters); $i++, $o++) {
				$goodChars++;
				my $c = ord(substr($characters, $i, 1));
				if ($c < 256) {
					$latinCt++;
					if ($c < 128) {
						$asciiCt++;
					} else {
						$o++; # Extra byte for latin chars
					}
				}
				# Do these checks only for UTF-8 so we don't get unneeded messages in log.
				elsif ($encoding eq 'UTF-8') {
					if ($c == 0xFEFF) { # Unicode Byte Order Marker
						$bomCt++;
						my $tmp = $totalBytes - $ioResult + $o;
						logit(LOG_NORMAL, sprintf("  warning: Unicode byte order marker U+%4.4X found at or near offset $tmp.\n", $c, $tmp));
						$o += 2; # two extra bytes for BOM
					} elsif ($c == 0xFFFD) { # Unicode substitution char
						$subCharCt++;
						my $tmp = $totalBytes - $ioResult + $o;
						logit(LOG_NORMAL, sprintf("  warning: Unicode substitution char U+%4.4X (found at or near offset $tmp) cannot be stored in a single byte database.\n", $c, $tmp));
						$o += 2; # two extra bytes for Sub char
					} else { # other Unicode chars that can't be stored in single byte
						my $tmp = $totalBytes - $ioResult + $o;
						$charsAbove256++;
						logit(LOG_NORMAL, sprintf("  warning: Unicode code point U+%4.4X (at or near file offset %d) cannot be stored in a single byte database.\n", $c, $tmp));
						my $c = ord(substr($bufferCopy, $o, 1));
						#logit(LOG_DEBUG, sprintf("%2.2X", $c));
						# This code adjusts the pointer to buffer copy to point to the appropriate byte.
						my $bytesToSkip = 0;
						if ($c >= 0xF0) {
							$bytesToSkip = 3;
						} elsif ($c >= 0xE0) {
							$bytesToSkip = 2;
						} elsif ($c >= 0xC0) {
							$bytesToSkip = 1;
						}
						$o += $bytesToSkip;
					}
				}
			}
			logit(LOG_DEBUG, "Decoded chars (partial): ", printHex(substr($characters, 0, 12)), "\n");
			logit(LOG_DEBUG, "  ErrorCt=$errorCt, length=", length($characters), ", latins=$latinCt, ioResult=$ioResult\n");
			
			# Detect situations where the decoder does not know how to decode and leaves bytes behind
			# Here we rely on the UTF-8 encoding that guarantees these rule. If the byte pattern is X then there are N bytes left in the sequence
			#     Pattern    Bytes left
			#     0xxx xxxx    0    0
			#     110x xxxx  192    1
			#     1110 xxxx  224    2
			#     1111 0xxx  240)   3
			#my $bytesLeftover = length($buffer);
			my $bytesToSkip = 0;
			if ( $bytesLeftover > 0 and $encoding eq 'UTF-8') {
				# Compute # of bytes to skip (maybe)
				my $c = ord(substr($buffer, 0, 1));
				if ($c >= 240) {
					$bytesToSkip = 4;
				} elsif ($c >= 224) {
					$bytesToSkip = 3;
				} elsif ($c >= 192) {
					$bytesToSkip = 2;
				} else {
					$bytesToSkip = 1;
				}
			}
			logit(LOG_DEBUG, "  Bytes leftover = $bytesLeftover\n");
			# If bytesToSkip is greater than zero, then decoder either ran out of bytes to finish the sequence or encountered an invalid sequence.
			# It's invalid if the buffer still has more bytes than bytesToSkip. In this case, we find the first byte that is less than 128 (has no leftover bytes and make that the first char remaining)
			if ($bytesToSkip > 0 and $bytesLeftover > $bytesToSkip) {
				$errorCt++;
				my $i;
				for ($i=0; $i<$bytesLeftover;) {
					if (ord(substr($buffer, $i, 1)) >= 128) {
						$i++;
					} else {
						last;
					}
				}
				logit(LOG_DEBUG, "  Moving buffer down from position $i\n");
				my $badBytes = substr($buffer, 0, $bytesToSkip);
				$buffer = substr($buffer, $i);
				logit(LOG_DETAIL, "  Illegal code sequence ", printHex($badBytes), " starting at file offset ", $totalBytes - $bytesLeftover, ". Skipping $i bytes to resync.\n");
				logit(LOG_DEBUG, "  Buffer resync: new length is ", length($buffer), ", new first char is ", sprintf("0x%2.2X", ord(substr($buffer, 0, 1))), "\n");
			}
			if($errorCt > $illegalCharThreshold or ($latinCt == 0 and $totalBytes > $noLatinStopLimit)) {
				logExceededError();
				last;
			}
		}
	};
	logit(LOG_DEBUG, "  result=$@\n");
	logit(LOG_DEBUG, "  read error: $!\n") if (!defined $ioResult);
	logit(LOG_DEBUG, "  ioresult=", $ioResult, "\n");
	logit(LOG_DEBUG, "  Len buffer=", length($buffer), "\n");
	close(IN);
	return ($charCt, $goodChars, $errorCt, $subCharCt, $latinCt, $asciiCt, $bomCt, 0, 0, $charsAbove256);
	
#	my $lineCt = 0;
#	while(<IN> and $errorCt < 200) {
#		my $line = $_;
#		# Decode logs warning for each bad char, so capture bad char count
#		eval { local $SIG{__WARN__} = sub { $errorCt++ };
#			#print "Checking $encoding\n";
#			my $characters = decode($encoding, $line, Encode::FB_CROAK);
#			my $lenIn = length($_);
#			my $lenOut = length($characters);
#			#print "Checked $encoding, before len=$lenIn, after len=$lenOut, errors=$errorCt\n";
#			die "No chars converted\n." if (length $characters == 0);
#		};
#		if ($@) {
#			#print "Error: \n";
#			$errorCt++;
#		}
#	}
#	close(IN);
#	return $errorCt;

}

#--------------------------------------------------------------------------
# This function makes a decision as to whether the provided file is encoded in ASCII
# The first parameter is the file name and the second is a valid Perl encoding name
# Regturns the number of errors (5 is the max)
#--------------------------------------------------------------------------
sub IsEncodedAsASCII($$) {
	my ($filename, $encoding) = @_;
	
	my $errorCt = 0;
	my $goodChars = 0; 
	my $charCt = 0;
	my $asciiCt = 0;

	# Open the file as binary and read octets.
	open (IN, $filename) || die "Error opening input file $filename while checking for encoding $encoding\n$!\n";
	binmode(IN);
	my $buffer;
	my $ioResult;
	my $totalBytes = 0;
	while($ioResult = read(IN, $buffer, 65536)) {
		$totalBytes += $ioResult;
		#print "read one line\n";
		$charCt += length($buffer);
		for (my $i=0; $i < length($buffer); $i++) {
			my $c = ord(substr($buffer, $i, 1));
			if ($c >= 128) {
				$errorCt++;
				logit(LOG_DETAIL, "  Illegal byte value ", printHex(substr($buffer, $i, 1)), " at file offset ", $totalBytes - $ioResult + $i, ". Skipping 1 byte.\n");
			} else {
				$goodChars++;
			}
		}
		#print LOG "  ErrorCt=$errorCt, length=", length($buffer), ", ioResult=$ioResult\n";
		if ($errorCt > $illegalCharThreshold and $totalBytes > $noLatinStopLimit) {
			logExceededError();
			last;
		}
	}

	#print LOG "  result=$@\n";
	#print LOG "  read error: $!\n" if (!defined $ioResult);
	#print LOG "  ioresult=", $ioResult, "\n";
	#print LOG "  Len buffer=", length($buffer), "\n";
	close(IN);
	return ($charCt, $goodChars, $errorCt, 0, $asciiCt, $asciiCt, 0, 0, 0, 0);
}

#--------------------------------------------------------------------------
# This function makes a decision as to whether the provided file is encoded in CP1252
# The first parameter is the file name and the second is a valid Perl encoding name
# Regturns the number of errors (5 is the max)
#--------------------------------------------------------------------------
sub IsEncodedAsCP1252($$) {
	my ($filename, $encoding) = @_;
	
	my $errorCt = 0;
	my $goodChars = 0; 
	my $charCt = 0;
	my $asciiCt = 0;
	my $utf8Ct = 0;
	my $utf8Intro = 0;	# True if a char value is C2 or C3 (it's used in UTF-8 for 2-byte sequence encodings or code points above 127.)

	# Open the file as binary and read octets.
	open (IN, $filename) || die "Error opening input file $filename while checking for encoding $encoding\n$!\n";
	binmode(IN);
	my $buffer;
	my $ioResult;
	my $totalBytes = 0;
	my $offset = 0;
	while($ioResult = read(IN, $buffer, 65536, $offset)) {
		$totalBytes += $ioResult;
		#print "read one line\n";
		$charCt += length($buffer);
		$offset = 0;
		for (my $i=0; $i < length($buffer); $i++) {
			my $c = ord(substr($buffer, $i, 1));
			$asciiCt++ if ($c < 128);
			# Check for illegal code points
			if ($c == 0x81 or $c == 0x8D or $c == 0x8F or $c == 0x90 or $c == 0x9D or $c == 0x81) {
				$errorCt++;
				logit(LOG_DETAIL, "  Illegal byte value ", printHex(substr($buffer, $i, 1)), " at file offset ", $totalBytes - $ioResult + $i, ". Skipping 1 byte.\n");
			# Sometimes it's a bit tricky to tell if a file is CP1252 or Unicode. Here we check for Unicode sequences just to count them
			} else {  # is a valid char
				$goodChars++;
				if ($c == 0xC2 or $c == 0xC3) {
					if ($i+1 < length($buffer)) {
						$utf8Intro++;
						my $c2 = ord(substr($buffer, $i+1, 1));
						$utf8Ct++ if ($c2 >= 0x80 and $c2 <= 0xBF);
					} else {
						$buffer = $c;
						$offset = 1;
					}
				}
			}
		}
		#print LOG "  ErrorCt=$errorCt, length=", length($buffer), ", ioResult=$ioResult\n";
		if ($errorCt > $illegalCharThreshold and $totalBytes > $noLatinStopLimit) {
			logExceededError();
			last;
		}
	}

	#print LOG "  result=$@\n";
	#print LOG "  read error: $!\n" if (!defined $ioResult);
	#print LOG "  ioresult=", $ioResult, "\n";
	#print LOG "  Len buffer=", length($buffer), "\n";
	close(IN);
	return ($charCt, $goodChars, $errorCt, 0, $charCt-$errorCt, $asciiCt, 0, $utf8Intro, $utf8Ct, 0);
}


my @ebcdicReal = 
(
#   0    1    2    3    4    5    6    7
#   8    9    A    B    C    D    E    F
   ' ', '.', '.', '.', 'x', '\t','x', 'x', #	8 /* 0x00	*/
   'x', 'x', 'x', 'x', 'x', '\n','.', '.', #	16 /* 0x08	*/
   '.', '.', '.', '.', 'x', 'x', '.', 'x', #	24 /* 0x10	*/
   '.', '.', 'x', 'x', '.', '.', '.', '.', #	32  /* 0x18	*/
   'x', 'x', 'x', 'x', 'x', '\n','.', '.', #	40  /* 0x20	*/
   'x', 'x', 'x', 'x', 'x', '.', '.', '.', #	48  /* 0x28	*/
   'x', 'x', '.', 'x', 'x', 'x', 'x', '.', #	56  /* 0x30	*/
   'x', 'x', 'x', 'x', '.', '.', 'x', '.', #	64  /* 0x38	*/
   ' ', 'x', 'x', 'x', 'x', 'x', 'x', 'x', #	72  /* 0x40	*/
   'x', 'x', 'x', '.', '<', '(', '+', 'x', #	80  /* 0x48	*/
   '&', 'x', 'x', 'x', 'x', 'x', 'x', 'x', #	88  /* 0x50	*/
   'x', 'x', 'x', '$', '*', ')', ';', 'x', #	96  /* 0x58	*/
   '-', '/', 'x', 'x', 'x', 'x', 'x', 'x', #	104 /* 0x60	*/
   'x', 'x', 'x', ',', '%', '_', '>', '?', #	112 /* 0x68	*/
   'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', #	120 /* 0x70	*/
   'x', '`', ':', '#', '@', '\'','=', '"', #	128 /* 0x78	*/
   'x', 'a', 'b', 'c', 'd', 'e', 'f', 'g', #	136 /* 0x80	*/
   'h', 'i', 'x', 'x', 'x', 'x', 'x', 'x', #	144 /* 0x88	*/
   'x', 'j', 'k', 'l', 'm', 'n', 'o', 'p', #	152 /* 0x90	*/
   'q', 'r', 'x', 'x', 'x', 'x', 'x', 'x', #	160 /* 0x98	*/
   'x', '~', 's', 't', 'u', 'v', 'w', 'x', #	168 /* 0xA0	*/
   'y', 'z', 'x', 'x', 'x', 'x', 'x', 'x', #	176 /* 0xA8	*/
   'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', #	184 /* 0xB0	*/
   'x', 'x', 'x', 'x', 'x', 'x', 'x', 'x', #	192 /* 0xB8	*/
   '{', 'A', 'B', 'C', 'D', 'E', 'F', 'G', #	200 /* 0xC0	*/
   'H', 'I', 'x', 'x', 'x', 'x', 'x', 'x', #	208 /* 0xC8	*/
   '}', 'J', 'K', 'L', 'M', 'N', 'O', 'P', #	216 /* 0xD0	*/
   'Q', 'R', 'x', 'x', 'x', 'x', 'x', 'x', #	224 /* 0xD8	*/
   '\\','x', 'S', 'T', 'U', 'V', 'W', 'X', #	232 /* 0xE0	*/
   'Y', 'Z', 'x', 'x', 'x', 'x', 'x', 'x', #	240 /* 0xE8	*/
   '0', '1', '2', '3', '4', '5', '6', '7', #	248 /* 0xF0	*/
   '8', '9', 'x', 'x', 'x', 'x', 'x', 'x',  #	256 /* 0xF8	*/
);
#--------------------------------------------------------------------------
# This function makes a decision as to whether the provided file is encoded in ASCII
# The first parameter is the file name and the second is a valid Perl encoding name
# Regturns the number of errors (5 is the max)
#--------------------------------------------------------------------------
sub IsEncodedAsEBCDIC($$) {
	my ($filename, $encoding) = @_;
	
	my $errorCt = 0;
	my $goodChars = 0; 
	my $charCt = 0;
	my $asciiCt = 0;
	my $latin1Ct = 0;

	my $ebcSize = @ebcdicGood;
	#print LOG "EBCDIC: $ebcSize: ", join(",", @ebcdicGood), "\n";
	# Open the file as binary and read octets.
	open (IN, $filename) || die "Error opening input file $filename while checking for encoding $encoding\n$!\n";
	binmode(IN);
	my $buffer;
	my $ioResult;
	my $totalBytes = 0;
	while($ioResult = read(IN, $buffer, 65536)) {
		$totalBytes += $ioResult;
		#print "read one line\n";
		$charCt += length($buffer);
		for (my $i=0; $i < length($buffer); $i++) {
			my $c = ord(substr($buffer, $i, 1));
			#print LOG "$c,";
			if ($ebcdicGood[$c] == 0) {
				$errorCt++ 
			} else {
				$goodChars++;
			}
			$asciiCt++ if ($ebcdicGood[$c] == 2);
			$latin1Ct++ if ($ebcdicGood[$c] >= 2);
		}
		#print LOG "  ErrorCt=$errorCt, length=", length($buffer), ", ioResult=$ioResult\n";
		if ($errorCt > $illegalCharThreshold and $totalBytes > $noLatinStopLimit) {
			logExceededError();
			last;
		}
	}

	#print LOG "  result=$@\n";
	#print LOG "  read error: $!\n" if (!defined $ioResult);
	#print LOG "  ioresult=", $ioResult, "\n";
	#print LOG "  Len buffer=", length($buffer), "\n";
	close(IN);
	return ($charCt, $goodChars, $errorCt, 0, $latin1Ct, $asciiCt, 0, 0, 0, 0);
}

#--------------------------------------------------------------------------
# Try all encoding defined here. 
#--------------------------------------------------------------------------
sub TryAllEncodings($) {
	my $infile = shift;
	
	foreach my $encoding (@encodings) {
		my $e = new CharSetStats;
		$e->name($encoding);
		$e->totalChars(0);
		$e->illegalChars(0);
		$e->subCharCt(0);
		$e->latinChars(0);
		$e->asciiChars(0);
		$e->hasBom(0);
		$e->utf8LatinIntroChars(0);
		$e->validutf8Chars(0);
		$e->charsAbove256(0);
		$charSetStats{$encoding} = $e;

		my @stats;
		logit(LOG_NORMAL, "Evaluating encoding: $encoding\n");
		if ($encoding eq "UTF-32BE" or $encoding eq "UTF-32LE") {
			@stats = IsEncodedAsUnicode32($infile, $encoding);
		} elsif ($encoding eq "UTF-16BE" or $encoding eq "UTF-16LE") {
			@stats = IsEncodedAsUnicode16($infile, $encoding);
		} elsif (substr($encoding, 0, 4) eq "UTF-") {
			@stats = IsEncodedAsUnicode($infile, $encoding);
		} elsif ($encoding eq 'ASCII') {
			@stats = IsEncodedAsASCII($infile, $encoding);
		} elsif ($encoding eq 'CP1252') {
			@stats = IsEncodedAsCP1252($infile, $encoding);
		} elsif ($encoding eq 'EBCDIC') {
			@stats = IsEncodedAsEBCDIC($infile, $encoding);
		} else {
			print LOG "Error: don't know how to handle encoding named $encoding\n";
		}
#		my @stats = IsEncodedAs($infile, $encoding);
		#print LOG "Back from IsEncodedAs: $@\n";
		$e->totalChars($stats[0]);
		$e->goodChars($stats[1]);
		$e->illegalChars($stats[2]);
		$e->subCharCt($stats[3]);
		$e->latinChars($stats[4]);
		$e->asciiChars($stats[5]);
		$e->hasBom($stats[6]);
		$e->utf8LatinIntroChars($stats[6]);
		$e->validutf8Chars($stats[8]);
		$e->charsAbove256($stats[9]);

		logit(LOG_DEBUG, "$encoding=T=$stats[0], G=$stats[1], E=$stats[2], S=$stats[3], L=$stats[4], A=$stats[5], BOM=$stats[6], UTF8LatinIntroChars=$stats[7], ValidUTF8Chars=$stats[8], CharsAbove256=$stats[9]\n");
	}
}

#--------------------------------------------------------------------------
# Convert seconds to HH:MM:SS
#--------------------------------------------------------------------------
sub secsToHMS($) {
	my $secs = shift;
	my $SECS_PER_HOUR = 3600;
	my $hours = int($secs / $SECS_PER_HOUR);
	$secs -= $SECS_PER_HOUR * $hours;
	my $mins = int($secs / 60);
	$secs -= $mins * 60;
	return sprintf("%02d:%02d:%02d", $hours, $mins, $secs);
}

#--------------------------------------------------------------------------
# Commify a number 
#--------------------------------------------------------------------------
sub commify ($) {
	# commify a number. Perl Cookbook, 2.17, p. 64
	my $text = reverse $_[0];
	$text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
	return scalar reverse $text;
}

#--------------------------------------------------------------------------
# logit - logs a line to $LOG and maybe also to STDOUT
#--------------------------------------------------------------------------
sub logit($$) # filehandle, line
{
    my ($msgType, @line) = @_;

    if ($msgType <= $logType) {
		print LOG @line;
		print STDOUT @line;
	}
}


#--------------------------------------------------------------------------
#--------------------------------------------------------------------------
sub getOptionValue($) {
    my $refI = shift;
	die "getOptionVal must be called with a reference to a scalar." if (!ref $refI);
	#print "GO=$ARGV[$$refI]\n";
    my $optionVal = substr($ARGV[$$refI], 2);
    #print "OptionVal(e): $optionVal\n";
    if ($optionVal eq '') {
        $$refI++;
        $optionVal = $ARGV[$$refI];
    }

    #print "OptionVal(x): $optionVal\n";
    return $optionVal;
}

#--------------------------------------------------------------------------
# ParseCommandLine
#--------------------------------------------------------------------------
sub ParseCommandLine #(argc, argv)
{
	my($argc) = shift(@_);
	my($bGotFile, $ParmCt, $OptionCt) = (0, 0, 0, 0);

	for (my $i=0; $i<$argc; $i++)
	{
        my $firstChar = substr($ARGV[$i], 0, 1);
        if ($firstChar eq "-" || $firstChar eq "/")
        {
			# Parm is an option switch
            my $secondChar = substr($ARGV[$i], 1, 1);
            my $optionVal = substr($ARGV[$i], 2);

			$OptionCt++;
            my $secondChar = substr($ARGV[$i], 1, 1);
			#print "Second char: $secondChar\n";
			if ($secondChar eq 'l' or $secondChar eq 'L') {
				$logType = getOptionValue(\$i);
				#print "log type $logType\n";
				if ($logType eq 'b' or $logType eq 'B') {
					$logType = LOG_BRIEF;
				} elsif ($logType eq 'n' or $logType eq 'N') {
					$logType = LOG_NORMAL;
				} elsif ($logType eq 'd' or $logType eq 'D') {
					$logType = LOG_DETAIL;
				} elsif ($logType eq 'g' or $logType eq 'G') {
					$logType = LOG_DEBUG;
				} else { #if (length $logType != 1 or index("bBnNdDgG", $logType) == -1) {
					Errout("Invalid log type given in -l option. Log type must be b, n, or d.\n")
				}
				#print "log type $logType\n";
			} elsif ($secondChar eq 'c' or $secondChar eq 'C') {
				$dumpLineCount = getOptionValue(\$i);
			}
			else {
				Errout("Invalid option given on command line ($ARGV[$i])");				
			}
		}
		
		# Otherwise it's the file name
		else
		{
			$ParmCt++;
			if ($ParmCt == 1)
			{
				$infile = $ARGV[$i];
				$bGotFile = 1;
			}
		}
	}

	&PrintUsage if (!$bGotFile || $ErrorCt);
}


#--------------------------------------------------------------------------
# Errout - print an error to STDOUT
#--------------------------------------------------------------------------
sub Errout #(ErrMsg)
{
	my ($ErrMsg) = shift(@_);

	$ErrorCt++;
	logit(LOG_NORMAL, "Error ($.): $ErrMsg.\n");
}

#--------------------------------------------------------------------------
# PrintUsage
#--------------------------------------------------------------------------
sub PrintUsage
{
	die(
		"\nDetectCharSet (v$version) - attempts to identify the character encoding of a text file.\n" .
		"\n" .
		"Usage: DetectCharSet.pl <File To Check> [options]\n" .
		"where\n" .
		"  <File to Check> is the name of the file to check. The file is not modified.\n" .
		"\n" .
		"and where [options] is one fo the following:\n" .
		"  -l[bnd] : adjusts the log level to increasingly higher levels as follows:\n" .
		"            b : brief - only the filename, the possible encodings, and any\n" .
		"                 warnings are in the output.\n" .
		"            n : normal (the default) - a brief summary of errors and why some\n" .
		"                encodings were eliminated are in the output.\n" .
		"            d : detailed - Messages detailing where errors were found are in the\n" .
		"                output.\n" .
		"            g : debug - includes debug level output (mainly for fixing script)\n" .
		"  -c <line count> : sets the maximum number of lines written in the file dump.\n" .
		"     The default is 50.\n" .
		"Processing.\n" .
		"For each character set to evaluate, the file is opened, read as octets, and\n" .
		"the octets are decoded in the character set being evaluated. The file is read\n". 
		"to the end or until " . $illegalCharThreshold . " character decoding errors occur. The\n" .
		"characters are also analyzed to create statistics about certain character classes\n" .
		"in order to provide better results when no decoding errors occur. After all\n" .
		"encodings are tried, each encoding is evaluated and the results are displayed\n" .
		"along with reasoning. In general, certain encodings are eliminated and any ones\n" .
		"reamining are possible encodings for the file (there may be more than one).n" .
		"\n" .
		"After all encodings have been tried, the script also writes any lines to the log\n" .
		"that contain any byte values higher than 0x7F. This helps to identify potential\n" .
		"issues with visual inspection.\n" .
		"\n" 
	);	
}