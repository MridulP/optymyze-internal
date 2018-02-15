# ReportUserSessionsOZ - Generates a report of user sessions for Optymyze.
#
#  This works by querying the metadata table AC_USER_LOGIN_HISTORY table in the SPM schema.


#use strict 'vars';
use strict;
use DBI;
use DBI qw(:sql_types);
use Class::Struct;
use Time::Piece;
use Time::Seconds;
use Time::Local;
use Date::Manip;
use Date::Calc;

my $version= "1.2";
#----------------------------------------------------
# Change this to be your time zone or one you want to force.
#----------------------------------------------------
#Date_Init("TZ=EST5EDT");


# Require the use of 64-bit Perl
my $b = 0;
for (my $v=1; $v; $v <<=1, $b++) {}
if ($b < 64) {
#	die "Error: Use of this Perl script requires 64-bit Perl.\n"
}


struct ( 'Login', {
	loginId => '$',	# login id
    combos => '%',	# hash of PPID + roles
    });

struct ( 'ParticipantAccess', {
	ppId => '$',	# participant id
    logins => '%',	# logins using this PPID
    });


# Exit Codes
use constant {
	EXIT_ERROR => 1,	# Errors encountered 
	EXIT_OK => 0,		# No errors, report OK
};

# Column display attributes
use constant {
	DSP_NORMAL => 1,
	DSP_ALERT => 2,
	DSP_DIM => 3,
};

# Column link attributes
use constant {
	LNK_NONE => 0,			# No link stuff
	LNK_LINK => 1,			# Use to make a column a link to a target
	LNK_TARGET =>2,			# Use to make a column an target of a link
};

# Constants for report section names
use constant {
	PPID_SECTION_NAME => 'Sessions By Participant ID',
	LOGINID_SECTION_NAME => 'Sessions By Login ID',
	LOGOUT_REASON_COUNTS => 'Counts of session status by reason',
};

# Service monitor login ID. Sessions from this login ID are ignored for some report sections
my $serviceMonitorLoginId = 'svcmonitors';
my $serviceMonitorSessions = 0;

# Get current local time
my @timeData = localtime(time);
my $tmpCurTime = sprintf("%02d-%02d-%02d %02d:%02d:%02d,000", $timeData[5]-100, $timeData[4]+1, $timeData[3], $timeData[2], $timeData[1], $timeData[0]);
my $curDate = sprintf("%04d-%02d-%02d", $timeData[5]-100+2000, $timeData[4]+1, $timeData[3]);
my $curTime = sprintf("%02d:%02d:%02d", $timeData[2], $timeData[1], $timeData[0]);
#print "CT=$tmpCurTime\n";

# These items must be supplied on the command line as inputs

my $dbLogin = '';		# Schema (login) to connect to
my $dbPassword = ''; 	# Password for the schema
my $dbPasswordGiven = 0;	# Set to true if DB password provided on the command line

my $includeUserSessionsSection = 1;
my $customerName;	# Name of customer if -c given on command line
my $server = '';
my $fileName = '';
my $lclStartDate;
my $lclEndDate;
my $schemaName = '';	# Name of schema if provided
my $idleTimeoutGiven = 0;	
my $calculatedIdleTO = 0;
my $idleTimeoutSource = '';

my $html = 1;		# True for HTML format report

# Fetch and parse command line
my $argc = $#ARGV + 1;
my $gotFileName = parseCommandLine($argc, @ARGV);
# If user did not supply an output file name, use the default name.
if (!$gotFileName) {
	my $customerPart = '';
	$customerPart = "for_${customerName}_" if (length($customerName) > 0);
    $fileName = "User_Session_Report_${customerPart}run_on_${curDate}.htm";
} else {
	$fileName =~ s/%D%/$curDate/g;
	$fileName =~ s/%C%/$customerName/g;
}

# Open the output report file and write header
print "Report output will be written to: $fileName\n";
open(OUT, ">$fileName") || die "Error opening report output file $fileName: $!\n";


# Create database connections. Need two for two concurrent queries.
my ($DSN, $dbh);

### Probe DBI for the installed drivers
my @drivers = DBI->available_drivers();
 
die "No drivers found!\n" unless @drivers; # should never happen
 
### Iterate through the drivers and list the data sources for each one
foreach my $driver ( @drivers ) {
 #   print "Driver: $driver\n";
    next if ($driver ne "ODBC");
	my @dataSources = DBI->data_sources( $driver );
    foreach my $dataSource ( @dataSources ) {
#        print "\tData Source is $dataSource\n";
    }
#    print "\n";
}

# The database stores the times in GMT, but user's perspective is local time. In order to ensure
# that we get all the relevant records, we expand the end points outward by the timezone difference in seconds and later drop any records
# that are outside our true local time range. We have to do this because we can't issue a query that automatically
# adjusts to local time properly for all times (at least not in SQL Server).

# Calculate timezone offset in seconds and offset start and end queries by that
my $tzOffsetSecs = UnixDate("2010-12-01-00:00:00 GMT", "%s") - UnixDate("2010-12-01-00:00:00", "%s");
my $offset = sprintf("%+ds", -$tzOffsetSecs);
print "tz offset=$offset\n";
my $queryStartDate = DateCalc($lclStartDate, $offset);
my $queryEndDate = DateCalc($lclEndDate, $offset);

# To ensure better counting when dealing with sessions that started before our reporting window, we look 3 hours before the report period start for data.
#$queryStartDate = DateCalc($queryStartDate, sprintf("%+ds", -60 * 60 * 3));

my $queryStart = substr($queryStartDate, 4, 2) . '/' . substr($queryStartDate, 6, 2) . '/' . substr($queryStartDate, 0, 4) . ' ' . substr($queryStartDate, 8, 2) . ':' .substr($queryStartDate, 11, 2) . ':' . substr($queryStartDate, 14, 2);
my $queryEnd   = substr($queryEndDate,   4, 2) . '/' . substr($queryEndDate,   6, 2) . '/' . substr($queryEndDate,   0, 4) . ' ' . substr($queryEndDate,   8, 2) . ':' .substr($queryEndDate,   11, 2) . ':' . substr($queryEndDate,   14, 2);

# Form the where clause for query based on date options given. 
# Note that we count sessions that either ended during our time range or sessions that started during it.
# TO_CHAR(field, 'YYYY/MM/DD HH24:MI:SS')
# We have these cases for how a session overlaps between our reporting dates:
#                     S          E
#      S--------------|------E   |					# ends in our reporting period
#              S------|----------|----E				# spans our period
#                     |   S------|---------E		# starts in our period
#                     |  S----E  |					# occurs within our period
#       S------E      |          |                  # NO overlap
#                     |          |  S---E           # No overlap
#  (E is NULL OR E >= RS) AND (S < RE) <------ YES!
# (S <= RS AND (E is NULL OR E > RS)) OR (S >= RS AND S < RE) <---- NO

my $whereClause =   "where (aulh_logout_date is null or aulh_logout_date >= to_timestamp('" . $queryStart . "', 'mm/dd/yyyy hh24:mi:ss')) and aulh_login_date < to_timestamp('" . $queryEnd . "', 'mm/dd/yyyy hh24:mi:ss')";
print "Where=$whereClause\n";

#die;
print "Connecting to database with supplied credentials...\n";
# my $dbh = DBI->connect('dbi:Oracle:host=localhost;sid=ORCL;port=1521', 
#               'scott', 'tiger', { RaiseError => 1, AutoCommit => 0 });
$dbh = DBI->connect("DBI:Oracle:host=$server;sid=optymyze", $dbLogin, $dbPassword, { RaiseError => 0, PrintError => 0, AutoCommit => 0 }) or EndProgram(EXIT_ERROR, "\nError opening database:\n$DBI::errstr\n");

#DBI->trace(10);

$dbh->{AutoCommit} = 1;
print "Database connected.\n";

# Queries
# Get login and logout dates of all records
my $query1 = "select to_char(aulh_login_date, 'YYYY/MM/DD HH24:MI:SS'), to_char(aulh_logout_date, 'YYYY/MM/DD HH24:MI:SS'), aulh_logout_reason, login_id, aulh_active_roles from ${schemaName}AC_USER_LOGIN_HISTORY " . $whereClause . " order by aulh_login_date";
print "Q=$query1\n";
my $sthGetRecords =  PrepareSQL($dbh, $query1);
my $sthGetRecordCount =  PrepareSQL($dbh, "select count(*) as count from ${schemaName}AC_USER_LOGIN_HISTORY " . $whereClause);


print "Issuing query to get login history records...\n";
# First get count of records. We do this to preallocate array
$sthGetRecordCount->execute() or EndProgram(EXIT_ERROR, "\nError executing SQL statement to get login times:\n$DBI::errstr\n");
my $rowCt = 0;
while (my @row = $sthGetRecordCount->fetchrow_array()) {
	$rowCt = $row[0];
	last;
}
$sthGetRecordCount->finish();

#print "row ct=$rowCt\n";


# Pre-allocate login/out points array for efficiency
my @inoutTimes;	# Login in and out times (GMT) expressed as seconds since the epoch,  but shift left by 1 and AND'ed with 0|1 to indicate log- in|out/
$#inoutTimes = ($rowCt + 100) * 2;

# Query first to calculate idle timeout if not given on command line
if (!$idleTimeoutGiven) {
	my @sessionTimes;
	$#sessionTimes = $rowCt;
	my $sessionCt = 0;
	
	$calculatedIdleTO = 10000000;
	print "Calculating Idle Timeout Value...\n";
	$sthGetRecords->execute() or EndProgram(EXIT_ERROR, "\nError executing SQL statement to get login times:\n$DBI::errstr\n");
	while (my @row = $sthGetRecords->fetchrow_array()) {
	#my $query1 = "select to_char(aulh_login_date, 'YYYY/MM/DD HH24:MI:SS'), to_char(aulh_logout_date, 'YYYY/MM/DD HH24:MI:SS'), aulh_logout_reason, login_id, aulh_active_roles from AC_USER_LOGIN_HISTORY " . $whereClause . " order by aulh_login_date";
		my $loginDate = $row[0];
		my $logoutDate = $row[1];
		my $logoutReason = $row[2];

		if ($logoutReason eq 'Session expired') {
			my $lclLoginSecs = timegm(int(substr($loginDate, 17, 2)), int(substr($loginDate, 14, 2)), int(substr($loginDate, 11, 2)), int(substr($loginDate, 8, 2)), int(substr($loginDate, 5, 2)) - 1, int(substr($loginDate, 0, 4)) - 1900); 
			my $lclLogoutSecs = timegm(int(substr($logoutDate, 17, 2)), int(substr($logoutDate, 14, 2)), int(substr($logoutDate, 11, 2)), int(substr($logoutDate, 8, 2)), int(substr($logoutDate, 5, 2)) - 1, int(substr($logoutDate, 0, 4)) - 1900); 
			my $len = int (($lclLogoutSecs - $lclLoginSecs) / 60);
			$sessionTimes[$sessionCt++] = $len;
			#$calculatedIdleTO = $len if ($len < $calculatedIdleTO);
			#print "LOR: $loginDate, $logoutDate, $logoutReason, $len\n";
		}

	}
	# Sort session times and find mode
	#print "Session Ct: $sessionCt\n";
	$#sessionTimes = $sessionCt - 1;
	#print "array size=", scalar @sessionTimes, ", $#sessionTimes\n";
	my @sessionTimesSorted = sort SortNumeric @sessionTimes;
	#print "\Org: @sessionTimes\n";
	#print "\Sorted: @sessionTimesSorted\n";
	my $curValue = $sessionTimesSorted[0];
	my $mode = $curValue;
	my $priorRunLen = 0;
	my $curRunLen = 1;
	my $i = 1;
	while ($i < $sessionCt) {
		while ($sessionTimesSorted[$i] == $curValue and $i < $sessionCt) {
			$i++;
			$curRunLen++;
		}
		# end of array or end of run
		if ($curRunLen > $priorRunLen) {
			#print "R: $curValue, $curRunLen\n";
			$mode = $curValue;
			$priorRunLen = $curRunLen;
		}
		$curRunLen = 1;
		$curValue = $sessionTimesSorted[$i];
		$i++;
	}
	$calculatedIdleTO = $mode;
	
	$sthGetRecords->finish;
	if ($calculatedIdleTO == 10000000) {
		$calculatedIdleTO = 0;
		print "Timeout value could not be calculated. Using 0\n";
		
	}
	# set to 15 increment
	$calculatedIdleTO = int($calculatedIdleTO / 15) * 15;
	print "Calculated Idle Timeout value is: $calculatedIdleTO\n";

	$idleTimeoutSource = 'Calculated';
} else {
	$idleTimeoutSource = 'Provided';
}


# Query all logins and attributes
$sthGetRecords->execute() or EndProgram(EXIT_ERROR, "\nError executing SQL statement to get login times:\n$DBI::errstr\n");
print "\n\nQuery completed, $rowCt records returned. Reading records and organizing data for report...\n";

# Convert report times to seconds
my $lclStartSecs = int(UnixDate($lclStartDate, "%s"));
my $lclEndSecs = int(UnixDate($lclEndDate, "%s"));

my $sessionCt = 0;
my $pointCt = 0;
my %loginIds;			# Cross-reference of PPIDs and Roles by LoginID
my %ppIds;				# Cross-reference of loginIDs by PPID
my %logoutReasonCt;			# Logout counts categorized by reason
my %appServerSessionCt;		# Number of sessions by app server name
print "Records processed: 0\r";
while (my @row = $sthGetRecords->fetchrow_array()) {
#my $query1 = "select to_char(aulh_login_date, 'YYYY/MM/DD HH24:MI:SS'), to_char(aulh_logout_date, 'YYYY/MM/DD HH24:MI:SS'), aulh_logout_reason, login_id, aulh_active_roles from AC_USER_LOGIN_HISTORY " . $whereClause . " order by aulh_login_date";
	my $loginDate = $row[0];
	my $logoutDate = $row[1];
	my $logoutReason = $row[2];
	my $loginId = $row[3];
	my $roles = $row[4];
#	my $appServer = $row[3];
#	$appServerSessionCt{$appServer}++;
	
#	print "LOR: $loginDate, $logoutReason\n";
	$logoutReason = 'Active' if (!defined $logoutReason or $logoutReason eq '');
	$logoutReasonCt{$logoutReason}++;
	my $sharedSessions = 0;
	my $authFailed = 0;
	my $sessionCutoff = sprintf("%+ds", 28800); # 10 hours
	my $timeNow = ParseDate("now");	
	#print "cutoff: $sessionCutoff, now: $timeNow\n";
	# Count particular session oddities
	if ($logoutReason eq 'Shared session encountered') {
		$sharedSessions++;
	} elsif ($logoutReason eq 'Authorization failed') {
		$authFailed++;
	} elsif (!defined $logoutReason || $logoutReason eq '') {
		#print "login time: $loginDate: ";
		# $epoch = timegm( $sec, $min, $hour, $mday, $mon, $year )
		my $lclLoginSecs = timegm(int(substr($loginDate, 17, 2)), int(substr($loginDate, 14, 2)), int(substr($loginDate, 11, 2)), int(substr($loginDate, 8, 2)), int(substr($loginDate, 5, 2)) - 1, int(substr($loginDate, 0, 4)) - 1900); 
		#print ", Login secs: $lclLoginSecs";
		if ($lclLoginSecs < $timeNow - $sessionCutoff) {
			#print " rejected\n";
			next;
		} else {
			#print " ok\n";
		}
	}

	# an occasional record has a null logout date, ignore these, since they throw off the concurrent session counting
	next if $logoutDate eq '';

	# Add login and logout times to array of times. Attach the login or logout indicator to value. Values are such that login will sort first if times are same
	# We drop seconds and milliseconds.
	# These times remain in GMT
	# Format is: 2014-01-13 21:28:32.160
	#            0         1         2
	#            01234567890123456789012
	
	my $lclLoginSecs = timegm(int(substr($loginDate, 17, 2)), int(substr($loginDate, 14, 2)), int(substr($loginDate, 11, 2)), int(substr($loginDate, 8, 2)), int(substr($loginDate, 5, 2)) - 1, int(substr($loginDate, 0, 4)) - 1900); 
	my $lclLogoutSecs = timegm(int(substr($logoutDate, 17, 2)), int(substr($logoutDate, 14, 2)), int(substr($logoutDate, 11, 2)), int(substr($logoutDate, 8, 2)), int(substr($logoutDate, 5, 2)) - 1, int(substr($logoutDate, 0, 4)) - 1900); 
	if ($logoutReason eq 'Session expired') {
		if ($lclLogoutSecs - $lclLoginSecs > $calculatedIdleTO * 60) {
			$lclLogoutSecs -= $calculatedIdleTO * 60;
			#print "Adjusted "
		}
	}
	
	# Ignore records not in our selected time range.
	next if ($lclLoginSecs > $lclEndSecs || $lclLogoutSecs < $lclStartSecs);
	
	# Add to times array (unless service monitor account as we ignore these in session counting)
	if ($loginId ne $serviceMonitorLoginId) {
		# See note at definition of my @inoutTimes
		$inoutTimes[$pointCt++] = ($lclLoginSecs << 1); # Login Time
		$inoutTimes[$pointCt++] = ($lclLogoutSecs << 1) + 1;  # Logout Time 
	} else {
		$serviceMonitorSessions++;
	}

#	if ($pointCt < 20) {
#		print "$inoutTimes[$pointCt-2]\n";
#		print "$inoutTimes[$pointCt-1]\n";
#	}

	# Collect login id and attribute combination info
	# Remove and null chars in data
	$roles =~ s/\x00//g;

	# Add to cross-reference of PPIDs and Roles by Login
	my $l;
	if (!defined $loginIds{$loginId}) {
		$l = new Login;
		$l->loginId($loginId);
		$loginIds{$loginId} = $l;
	} else {
		$l = $loginIds{$loginId};
	}

	# Now make a single string of the PPID and roles. Ensure roles are in alphabetical order (not sure if app guarantees this).
	#print "R: $roles\n";
	my @roles = split(",", $roles);
	my @roles = split(",", $roles);
	@roles = sort SortInsensitive @roles;

	my $combo = join("\x1F", @roles);
#	print "Combo: $combo\n";

	if (!defined $l->combos($combo)) {
		$l->combos($combo, 1);
	} else {
		$l->combos($combo, $l->combos($combo) + 1);
	}
	
	$sessionCt++;
	if (($sessionCt % 10000) == 0) {
		print "Records processed: $sessionCt\r";
	}
}
$sthGetRecords->finish;
# Close the database connection
$dbh->disconnect;
print "Number of session records in time range: ", $pointCt/2 + $serviceMonitorSessions, "\n";


#--------------------------------------------------------------------------
# Data has been read. Create various statistics and graphs
#--------------------------------------------------------------------------

$#inoutTimes = $pointCt-1;
# Order times by start time
my @inoutTimesSorted = sort(@inoutTimes);


my $daysCoveredByData;			# Number of days covered by data found
my $earliestDataSample;			# Earliest data sample in local time
my $latestDataSample;			# Latest data sample in local time.
my @occurrancesOfDayOfWeek;		# Number of occurrances of each day of the week in the data found. First value is Sun(=0)
my @occurrancesOfDayOfMonth;	# Number of occurrances of each day of the month in the data found. First value is the 1st.
my @occurrancesOfTimeOfDay;		# Number of occurrances of each time of day bucket in the data found (based on resolution)
my @sessionsStartedByDayOfWeek;		# Session counts by day of week
my @sessionsStartedByTimeOfDay;		# Sessions by time of day (based on display resolution)
my @sessionsStartedByDayOfMonth;	# Sessions by day of the month
my @sessionsActiveByDayOfWeek;		# Session counts by day of week
my @sessionsActiveByTimeOfDay;		# Sessions by time of day (based on display resolution)
my @sessionsActiveByDayOfMonth;		# Sessions by day of the month
my @sessionLengthBuckets;			# Session lengths in buckets of X minutes

($earliestDataSample, $latestDataSample, $daysCoveredByData) = calcDateRangeOfData();
#print "EDD: $earliestDataSample\n";
#print "LDD: $latestDataSample\n";
#print "Delta data days: $daysCoveredByData\n";

my ($resolutionSecs, $resolutionDisplay) = calcDisplayResolution();
my @aggregatedSamples = aggregateToDisplayResolution($resolutionSecs);
calcStatistics($earliestDataSample, $latestDataSample, @aggregatedSamples);

# Print report parts.
my $dateFormat = '%Y-%b-%d %T';
my $lclStartDateFormatted = UnixDate($lclStartDate, $dateFormat); 
my $lclEndDateFormatted = UnixDate($lclEndDate, $dateFormat); 
my $lclEarliestDateFormatted = UnixDate($earliestDataSample, $dateFormat);
my $lclLatestDateFormatted = UnixDate($latestDataSample, $dateFormat);
my $reportName = 'User Session &amp; Concurrency Report';
$reportName .= " for $customerName" if (length($customerName) > 0);

printReportHeader($reportName, $lclStartDateFormatted, $lclEndDateFormatted, $lclEarliestDateFormatted, $lclLatestDateFormatted, commify($pointCt/2), commify($serviceMonitorSessions), commify(scalar keys(%loginIds)), commify(scalar keys(%ppIds)), $idleTimeoutSource, $calculatedIdleTO);
printSessionGraphs(@aggregatedSamples);
printSessionsByLoginID();
printSessionsStatusCounts();
printReportFooter();

close(OUT);

print "Completed sucessfully.\n";
exit 0;

#--------------------------------------------------------------------------
# Calculates and returns a list of three values:
#	- earliest data date
#	- latest data date
#	- difference in days between the two
#--------------------------------------------------------------------------
sub calcDateRangeOfData(@) {
	# Get earliest and latest times (removing login/out part)
	my $earliest = $inoutTimesSorted[0] >> 1;
	my $latest = $inoutTimesSorted[$pointCt-1] >> 1;
	#print "E=$earliest\nL=$latest\n";
	my $earliestDataSample = ParseDateString("epoch $earliest");
	my $latestDataSample = ParseDateString("epoch $latest");
	my $err;
	my $delta = DateCalc($earliestDataSample, $latestDataSample, \$err, 1);
	#print "Delta=$delta\n";
	#print "Error=$err\n";
	my $deltaDays = Delta_Format($delta, 0, '%dt');
	#print "DD=$deltaDays\n";
	$deltaDays = int($deltaDays + 0.999999);
	#print "DD=$deltaDays\n";
#	print "IO[0]: $inoutTimes[0]\n";
#	print "EDD: $earliestDataDate\n";
#	print "LDD: $latestDataDate\n";
#	print "Delta data days: $daysCoveredByData\n";

	# Earliest time can be before the request report time if the session ended within the period
	# but started outside the period. Here we make certain we're not less than the reporting period
	$earliestDataSample = $lclStartDate if ($earliestDataSample lt $lclStartDate);
	
	# Latest time can be after the request report time, so set to report end time if after.
	$latestDataSample = $lclEndDate if ($latestDataSample gt $lclEndDate);
	
	return ($earliestDataSample, $latestDataSample, $deltaDays);
}

#--------------------------------------------------------------------------
#--------------------------------------------------------------------------
sub calcDisplayResolution()
{
	# Calculate the display resolution based on the date range covered. As the range increases, the resolution decreases to
	# keep the aggregate arrays manageable.
	my $resolutionDisplay;
	my $resolutionSecs;
	my $err;
	my $delta = DateCalc($lclStartDate, $lclEndDate, \$err);
	my $deltaDays = Delta_Format($delta, 0, '%dt');
	if ($deltaDays <= 2) {
		$resolutionDisplay = "15 minutes";
		$resolutionSecs = 900; # seconds
	} elsif ($deltaDays <= 8) {
		$resolutionDisplay = "15 minutes";
		$resolutionSecs = 900; # seconds
	} elsif ($deltaDays <= 31) {
		$resolutionDisplay = "30 minutes";
		$resolutionSecs = 1800; # seconds
	} elsif ($deltaDays <= 93) {
		$resolutionDisplay = "1 hour";
		$resolutionSecs = 3600; # seconds
	} else {
		$resolutionDisplay = "4 hours";
		$resolutionSecs = 14400; # seconds
	}
	
	return ($resolutionSecs, $resolutionDisplay);
}

#--------------------------------------------------------------------------
# Take all the login and logout points and aggregate and calculate various statistics.
# The calculated statistics are all given as side effects:
#		- display resolution to aggregate to
#		- array of concurrent user sessions aggregated to display resolution
#		- array of user login counts aggregated to display resolution
#--------------------------------------------------------------------------
sub aggregateToDisplayResolution($) {
	my $resSecs = shift;

	print "Aggregating data to report resolution of $resolutionDisplay...\n";

	$sessionCt = 0;
	my $highMark = 0;
	my $samplesWritten = 0;
	my $sessionsStarted = 0;
	my @graphPoints;
	$#graphPoints = 2000;	# Preallocate array
	my $n = 0;
	
	# Set first bucket range (go back one resolution period
	# Points are sorted in increasing time order with start and end points mixed together.
	my $bucketStartSecs = $lclStartSecs;
	my $bucketEndSecs = $bucketStartSecs + $resSecs;
	print "Bckt start secs: $bucketStartSecs\nBckt end   secs: $bucketEndSecs\n";
	foreach my $p (@inoutTimesSorted) {
		# Determine if login or logout sample and remove indicator
		my $isLogin = ($p & 1) == 0;
		$p >>= 1;

		#		print "$isLogin p=$p, etc=$bucketEndSecs\n" if ($n < 20 || $n >= $pointCt-1);
		if ($p > $bucketEndSecs) {
			while ($p > $bucketEndSecs) {
				# Convert to display time
				my @timeData = localtime($bucketEndSecs);
				my $tl = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $timeData[5]+1900, $timeData[4]+1, $timeData[3], $timeData[2], $timeData[1], $timeData[0]);
				#print "$bucketEndSecs, $tl: $highMark, $sessionsStarted, $samplesWritten\n";
				$graphPoints[$samplesWritten++] = $highMark . '|' . $sessionsStarted . '|' . ($bucketEndSecs);
				$bucketEndSecs += $resSecs;
				last if ($bucketEndSecs > $lclEndSecs);
				$sessionsStarted = 0;
				$highMark = $sessionCt;
			}
		}
		if ($isLogin) {
			#print "I";
			$sessionCt++;
			$sessionsStarted++;
			$highMark = $sessionCt if ($sessionCt > $highMark);
		} else {
			#print "O";
			$sessionCt--;
		}
		$n++;
		last if ($bucketEndSecs >= $lclEndSecs);
	}
	print "\nAggregation completed.\n";
	$#graphPoints = $samplesWritten-1;	# Set actual array size
	
	return @graphPoints;
}

#--------------------------------------------------------------------------
# Calculate statistics
#	Calculates: total sessions by day of week
#				total sessions by day of month
#				total sessions by time of day
#
#--------------------------------------------------------------------------
sub calcStatistics($$@) {
	my $earliest = shift;
	my $latest = shift;
	#my $points = @_;

	my $SECS_PER_DAY = 86400;

	# Set day of month and day or week occurrances arrays
	substr($earliest, 8) = '00:00:00';
	substr($latest, 8) = '00:00:00';
	#print "Earliest: $earliest\n";
	#print "latest:   $latest\n";
	for (my $d=$earliest; $d le $latest; $d = DateCalc($d, "+1d")) {
		#my $year = substr($d, 0, 4);
		#my $month = substr($d, 4, 2);
		#my $timeSecs = UnixDate($d, "%s");
		#my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($timeSecs);
		my $wday = UnixDate($d, "%w");
		$wday = 0 if ($wday == 7);
		my $day = substr($d, 6, 2) + 0;
		$occurrancesOfDayOfMonth[$day-1]++;
		$occurrancesOfDayOfWeek[$wday]++;
		#print "date: $d, day: $day, dow: $wday\n";
	}
	
	#print "DOW occurrances: ", join(',', @occurrancesOfDayOfWeek), "\n";
	# Got through aggregated data points to generate averages, high marks, and occurrances by time of day
	my $totalBuckets = $SECS_PER_DAY / $resolutionSecs; 
	my ($prevYear, $prevMon, $prevMday, $prevBucket) = (-1, -1, -1, -1); 
	foreach my $p (@_) {
		my ($sessionsActive, $sessionsStarted, $bucketEndTimeSecs) = split(/\|/, $p);
		
		# Since the data point is marked by the end time of the bucket, we have an issue with the last bucket
		# which we'd like to occur at 24:00 but is 00:00 of the next day. Here we adjust to the start time of the 
		# bucket, so the stats for buckets by day of month come out correctly.
		$bucketEndTimeSecs -= $resolutionSecs;
		my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($bucketEndTimeSecs); # Note that this value is one sec less than it should be
		my $secs = $hour * 3600 + $min * 60 + $sec;
		my $bucket = int($secs / $resolutionSecs);

		$sessionsStartedByDayOfWeek[$wday] += $sessionsStarted;
		$sessionsActiveByDayOfWeek[$wday] = $sessionsActive if ($sessionsActive > $sessionsActiveByDayOfWeek[$wday]);
		$sessionsStartedByDayOfMonth[$mday-1] += $sessionsStarted;
		$sessionsActiveByDayOfMonth[$mday-1] = $sessionsActive if ($sessionsActive > $sessionsActiveByDayOfMonth[$mday-1]);
		$sessionsStartedByTimeOfDay[$bucket] += $sessionsStarted;
		$sessionsActiveByTimeOfDay[$bucket] = $sessionsActive if ($sessionsActive > $sessionsActiveByTimeOfDay[$bucket]);
#		print "B $year-$mon-$mday $hour:$min:$sec, $bucket=$secs\n";

		# Count occurrances of this time bucket over the all the data
		# if there is a bucket break, increment bucket occurrance count
		if ($bucket != $prevBucket || $mday != $prevMday || $mon != $prevMon || $year != $prevYear) {
			$occurrancesOfTimeOfDay[$prevBucket]++ if ($prevBucket >= 0);
			$prevYear = $year;
			$prevMon = $mon;
			$prevMday = $mday;
			$prevBucket = $bucket;
		}
	}
	$occurrancesOfTimeOfDay[$prevBucket]++ if ($prevBucket >= 0);
}
#--------------------------------------------------------------------------
# Print session summary section
#--------------------------------------------------------------------------
sub printSessionGraphs(@) {
	my @dataPoints = @_;

	printSessionSectionHeader('Users Session Totals and Concurrency', $resolutionDisplay);
	printGraphHeader();
	my $pointsWritten = 0;
	foreach my $p (@dataPoints) {
		#print "p=$p\n";
		#	$graphPoints[$samplesWritten++] = $sessionsActive . '|' . $sessionsStarted . '|' . $bucketEndSecs;
		my ($sessionsActive, $sessionsStarted, $bucketEndTimeSecs) = split(/\|/, $p);
		#Format is: {c:[{v: 'Eat'}, {v: 2}]},
		my @timeData = localtime($bucketEndTimeSecs);
		#my $tl = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $timeData[5]+1900, $timeData[4]+1, $timeData[3], $timeData[2], $timeData[1], $timeData[0]);
		print OUT ',' if ($pointsWritten);
		print OUT "{c:[{v:new Date(", $timeData[5]+1900, ',', $timeData[4], ',', $timeData[3], ',', $timeData[2], ',', $timeData[1], ")},{v:", $sessionsStarted, "},{v:", $sessionsActive, "}]}\n";
		$pointsWritten++;
	}
	
	printGraphFooter('Sessions', 350, 1000);
	# Print day of week graph
	my $str = getDATAItem('DayOfWeekGraphHeader');
	for (my $i=0; $i<7; $i++) {
		my $s = $sessionsStartedByDayOfWeek[$i] + 0;	# Ensure defined and scalar context
		my $a = $sessionsActiveByDayOfWeek[$i] + 0;	# Ensure defined and scalar context
		my $occurs = $occurrancesOfDayOfWeek[$i];
		$occurs = 1 if ($occurs == 0);

		my $avg = int($s / $occurs);
		$str =~ s/%${i}S%/$avg/;
		$str =~ s/%${i}A%/$a/;
		}
	print OUT "<br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>$str\n";
	
	# Print Days of month graph
	my $values = '';
	for (my $i=0; $i<31; $i++) {
		my $col = 0;
		my $s = $sessionsStartedByDayOfMonth[$i] + 0;	# Ensure defined and scalar context
		my $a = $sessionsActiveByDayOfMonth[$i] + 0;	# Ensure defined and scalar context
		my $occurs = $occurrancesOfDayOfMonth[$i];
		$occurs = 1 if ($occurs == 0);
		my $dom = $i + 1;
		$values .= "data.setValue($i, " . $col++ . ", '$dom');\n";
		$values .= "data.setValue($i, " . $col++ . ", " . int($s/$occurs) . ");\n";
		$values .= "data.setValue($i, " . $col++ . ", " . $a . ");\n";
	}
	my $s = getDATAItem('DayOfMonthGraphHeader');
	$s =~ s/%ColumnValues%/$values/;
	print OUT "<p>$s\n";
	
	# Print Time of day graph
	my $values = '';
	my $SECS_PER_DAY = 86400;
	my $pointCt = 0;
	my $bucket = 0;
	for (my $secs=$resolutionSecs; $secs <= $SECS_PER_DAY; $secs += $resolutionSecs) {
		my $col = 0;
		my $hm = secsToHM($secs);
		$values .= "data.setValue($pointCt, " . $col++ . ", '$hm');\n";
		my $s = $sessionsStartedByTimeOfDay[$pointCt] + 0;		# Ensure defined
		my $a = $sessionsActiveByTimeOfDay[$pointCt] + 0;		# Ensure defined
		my $occurs = $occurrancesOfTimeOfDay[$bucket++];
		$occurs = 1 if ($occurs == 0);
		$values .= "data.setValue($pointCt, " . $col++ . ", " . int($s/$occurs) . ");\n";
		$values .= "data.setValue($pointCt, " . $col++ . ", $a);\n";
		$pointCt++;
	}
	$values = "data.addRows($pointCt);\n" . $values;
	my $s = getDATAItem('TimeOfDayGraphHeader');
	$s =~ s/%ColumnValues%/$values/;
	$s =~ s/%RES%/$resolutionDisplay/;
	print OUT "<p>$s\n";
	
	#print "#=$#sessionsByTimeOfDay\n";
	#print join(", ", @sessionsByTimeOfDay), "\n";
 	
	
}

sub SortInsensitive($$) {
	my $a = shift;
	my $b = shift;
	return lc($a) cmp lc($b);
}

#--------------------------------------------------------------------------
# Used to sort an array numerically.
# For some reason the non-functional spec is not working, e.g., @sorted = sort {$a <=> $b } @unsorted
#--------------------------------------------------------------------------
sub SortNumeric($$) {
	my $a = shift;
	my $b = shift;
	return $a <=> $b;
}

#--------------------------------------------------------------------------
# Display session by login ID
#--------------------------------------------------------------------------
sub printSessionsByLoginID() {
#	print OUT "Reporting period specified: &lt;none given&gt;<br>\n";
#	print OUT "Earliest session: $earliestSession<br>\n";
#	print OUT "Latest session: $latestSession<br>\n";
#	print OUT "Session count: $sessionCt<br>\n";
	my $tableName = LOGINID_SECTION_NAME;
	my $tableDesc = "This section shows unique combinations of Roles within each Login ID across all " .
			"included sessions. Login IDs with more than one combination " .
			"are highlighed indicating deeper scrutiny may be needed. A Login ID " .
			"with multiple combinations may represent normal business activity, but also may indicate a data error or security issue.";
	beginTable($tableName, $tableDesc, ("Login ID", "Roles", "# Sessions"));
	

	# Now print login info
	my $rowNum = 0;  ##sort {lc $a cmp lc $b}
	my $totalSessions = 0;
	foreach my $loginId (sort SortInsensitive keys(%loginIds)) { # FOr some reason this version of sort does not work
		my $l = $loginIds{$loginId};
		my $attrLoginId = DSP_NORMAL;
		my $numCombos = (keys(%{$l->combos}));
		$attrLoginId = DSP_ALERT if ($numCombos > 1);
		#print "Combos: $numCombos\n";
		if (1) {
			foreach my $c (sort SortInsensitive (keys(%{$l->combos})))
			{
				my $count = $l->combos($c);
				my (@roles) = split("\x1F", $c);
				my $roles = join(", ", @roles);
				#print "$loginId, $roles: $count\n";

				#print OUT sprintf("%-29s, %s, %s, %s, '%s', %s, r:%s\n", $loginId, $name, $email, $lastLoginTime, $lockedOutEndTime, join(",", @roles));
				startRow($rowNum);
				printCol($rowNum, $loginId, $attrLoginId, LNK_NONE);
				printCol($rowNum, $roles, DSP_NORMAL);
				printCol($rowNum, $count, DSP_NORMAL);
				endRow();
				$rowNum++;
				$attrLoginId = DSP_DIM;
				$loginId = "";
				$totalSessions += $count;
			}
		}
	}
	
	# Add total row at bottom
	startRow($rowNum++);
	printCol($rowNum, 'Total sessions (including automated monitoring sessions):', DSP_NORMAL);
	printCol($rowNum, '', DSP_NORMAL);
	printCol($rowNum, $totalSessions, DSP_NORMAL);
	endRow();
	
	endTable();
	print OUT "None found<br>" if ($rowNum == 0);
}

#--------------------------------------------------------------------------
# Display session status counts by status type
#--------------------------------------------------------------------------
sub printSessionsStatusCounts() {
	my $tableName = LOGOUT_REASON_COUNTS;
	my $tableDesc = "This section shows unique session statuses and counts for each across all " .
			"included sessions.";
	beginTable($tableName, $tableDesc, ("Session Status", "# Sessions"));
	

	# Now print info
	my $rowNum = 0;  ##sort {lc $a cmp lc $b}
	my $totalSessions = 0;
	foreach my $status (sort SortInsensitive keys(%logoutReasonCt)) { 
		my $count = $logoutReasonCt{$status};

		startRow($rowNum);
		printCol($rowNum, $status, DSP_NORMAL, LNK_NONE);
		printCol($rowNum, $count, DSP_NORMAL);
		endRow();
		$rowNum++;
		$totalSessions += $count;
	}
	
	# Add total row at bottom
	startRow($rowNum++);
	printCol($rowNum, 'Total sessions:', DSP_NORMAL);
	printCol($rowNum, $totalSessions, DSP_NORMAL);
	endRow();
	
	endTable();
	print OUT "None found<br>" if ($rowNum == 0);
}

#--------------------------------------------------------------------------
# commify
#--------------------------------------------------------------------------
sub commify ($) {
	# commify a number. Perl Cookbook, 2.17, p. 64
	my $text = reverse $_[0];
	$text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
	return scalar reverse $text;
}
#--------------------------------------------------------------------------
#--------------------------------------------------------------------------
sub secsToHM($) {
	my $secs = shift;
	my $SECS_PER_HOUR = 3600;
	my $hours = int($secs / $SECS_PER_HOUR);
	my $mins = ($secs - ($SECS_PER_HOUR * $hours)) / 60;
	return sprintf("%02d:%02d", $hours, $mins);
}

#--------------------------------------------------------------------------
#--------------------------------------------------------------------------
sub beginTable($$@) {
	my $tableName = shift;
	my $tableDesc = shift;
	my @colNames = @_;
	
	# Output table that forms table section header, title and description
	print OUT "<br><br><table align='left' class='table_data' cellspacing='0' id='$tableName' style='page-break-before:always;'>\n";
	print OUT "<TR class='table_title_row'><TD class='table_title'>$tableName<br><div class='tbig'>$tableDesc</div></TD></TR></table>\n";
	
	# Add true table start code
	print OUT "<table align='left' class='table_data' cellspacing='0'><thead><tr class='tr_head'>";
	
	# Add columns
	foreach my $c (@colNames) {
		print OUT "<th>$c</th>";
	}
	print OUT "</tr></thead><tbody>\n";
	
}

#--------------------------------------------------------------------------
#--------------------------------------------------------------------------
sub endTable() {
	print OUT "</tbody></table><pre><br><br></pre>\n";
}

#--------------------------------------------------------------------------
#--------------------------------------------------------------------------
sub startRow($rowNum) {
	my ($rowNum) = shift;
	my $rowClass;
	if ($rowNum & 1) {
		$rowClass = "b";
	} else {
		$rowClass = "a";
	}

	print OUT "<tr class=\"$rowClass\">";
}

#--------------------------------------------------------------------------
# printCol - adds a column to the HTML table output
# Inputs: 1) row number
#		  2) column text
#		  3) column text attribute, DSP_DIM | DSP_ALERT | DSP_NORMAL (optional, DSP_NORMAL if omitted)
#		  4) column link indicator (LNK_NONE=no link, LNK_LINK=text is link to, LNK_TARGET=text is target of link) (optional, LNK_NONE if omitted)
#--------------------------------------------------------------------------
sub printCol($rowNum, $col, ...) {
	my ($rowNum, $col, $attr, $linkType) = @_;
	my $colClass;
	if ($rowNum & 1) {
		if (defined $attr && ($attr == DSP_DIM)) {
			$colClass = "f";
		} elsif (defined $attr && ($attr == DSP_ALERT)) {
			$colClass = "h";
		} else {
			$colClass = "d";
		}
	} else {
		if (($attr == DSP_DIM)) {
			$colClass = "e";
		} elsif (($attr == DSP_ALERT)) {
			$colClass = "g";
		} else {
			$colClass = "c";
		}
	}

	if ($linkType == LNK_NONE) {
		print OUT "<td class=\"$colClass\">$col</td>";
	} elsif ($linkType == LNK_LINK) {
		print OUT "<td class=\"$colClass\"><a href=\"#$col\">$col</a></td>";
	} elsif ($linkType == LNK_TARGET) {
		print OUT "<td class=\"$colClass\" id=\"$col\">$col</td>";
	}
}
#--------------------------------------------------------------------------
#--------------------------------------------------------------------------
sub endRow() {
	print OUT "</tr>\n";
}

#--------------------------------------------------------------------------
# Prepare a SQL statement and return a handle. If the statemenmt cannoot be prepared,
# The program writes an error and exists.
# Parameters: 	SQL statement to be prepared,
# Returns:		A statement handle to the prepared statement.
#--------------------------------------------------------------------------
sub PrepareSQL($dbh, $sql) {
	my $dbh = shift;
	my $sql = shift;
	# Prepare statement
	my $sth = $dbh->prepare($sql) or EndProgram(EXIT_ERROR, "\n\nError preparing SQL statement: '$sql'\n\nThe Oracle error was:\n$DBI::errstr\n");

	return $sth;
}

#--------------------------------------------------------------------------
#--------------------------------------------------------------------------
sub EndProgram($$) {
	my $endCode = shift;
	my $msg = shift;
	
	print STDERR "\n\nERROR:-------------------\nA problem was encountered.\n";
	# Look for schema problem error
	if (index($msg, "ORA-00942: table or view does not exist") >= 0) {
		print STDERR "The account name you provided on the command line is not associated\n" .
					 "with the SPM schema that contains the AC_USER_LOGIN_HISTORY table.\n" .
				     "In order to use this account, you must also specify the SPM schema\n" .
					 "name using the -n option. The full error returned by Oracle is below.\n\n";
	}
	print STDERR $msg if (length($msg));
	if ($endCode == EXIT_OK) {
		print STDERR "\n\nReport created successfully.\n";
	} else {
		print STDERR "\n\nErrors encountered creating report.\n";
	}
	close (LOG);
	exit($endCode);
}



my $dataItemsLoaded = 0;
my %dataItems;
# -----------------------------------------
# Get a data item by name
# -----------------------------------------
sub getDATAItem($) {
	my $key = shift;
#	print "E-getDATAItem($key)\n";
	if (!$dataItemsLoaded) {
		LoadDATAItems() ;
		$dataItemsLoaded = 1;
	}
	
#	print "x-getDATAItem($key)\n";
	my $item = $dataItems{$key};
	die "Item '$key' is not defined in the _DATA_ section." if (!defined $item || length($item) == 0); # Consistency check
	return $dataItems{$key};
}

# -----------------------------------------
# Loads the items in the DATA section.
# Returns a hash of items strings by item key
# -----------------------------------------
sub LoadDATAItems() {
	my $value = undef;
	my $key = undef;
#	print "E-loadDATAItems()\n";
	while (<DATA>) {
		next if (/^#/);							# Skip comments
		next if (/^\s*$/ && !defined $key);	# skip blank lines until we get a key name
		# If we've reached the end of this section, add value and reset
		if (/^~/) {
			die "Missing key name in DATA section ending at line $.\n" if ($key eq '');
#			print " Saving key=$key, len=", length($value), "\n";
			$dataItems{$key} = $value;
			undef $key;
			undef $value;
			next;
		}
		if (/^\// && $key eq '') {
			chomp;
			$key = substr($_, 1);
		} else {
			$value .= $_ if ($key ne '');
		}
	}
	$dataItems{$key} = $value if (defined $key);
#	print "E-loadDATAItems()\n";
}


# -----------------------------------------
# -----------------------------------------
sub printReportHeader() {
	my $reportName = shift;
	my $coverageFrom = shift;
	my $coverageTo = shift;
	my $foundFrom = shift;
	my $foundTo = shift;
	my $sessionCt = shift;
	my $serviceMonitorSessions = shift;
	my $loginIdCt = shift;
	my $ppIdCt = shift;
	my $idleTimeoutSource = shift;
	my $idleTimeout = shift;
	die "Report name must be passed to printReportHeader" if (!defined $reportName);
	my $t = localtime;
	my $dateStr = $t->cdate;
	my $tzsecs = $t->tzoffset;
	my $tzhours = int($tzsecs / 3600);
	my $tzsecs = $tzsecs - ($tzhours * 3600);
	my $tzoffsetstr = sprintf("%2.2d:%2.2d (hh:mm)", $tzhours, $tzsecs);
	$dateStr .= $tzoffsetstr;
	my $value;
	$value = getDATAItem('PageHeader');
	$value =~ s/%Date%/$dateStr/g;
	$value =~ s/%TZOFFSET%/$tzoffsetstr/;
	$value =~ s/%ReportName%/$reportName/g;
	$value =~ s/%CoverageFrom%/$coverageFrom/;
	$value =~ s/%CoverageTo%/$coverageTo/;
	$value =~ s/%FoundFrom%/$foundFrom/;
	$value =~ s/%FoundTo%/$foundTo/;
	$value =~ s/%Sessions%/$sessionCt/;
	$value =~ s/%SvcSessions%/$serviceMonitorSessions/;
	$value =~ s/%LoginIDs%/$loginIdCt/;
	$value =~ s/%PPIDs%/$ppIdCt/;
	$value =~ s/%IdleTimeoutSource%/$idleTimeoutSource/;
	$value =~ s/%IdleTimeout%/$idleTimeout/;
#	print "Report header\n$value\nEnd\n";
	print OUT $value;
}

# -----------------------------------------
# -----------------------------------------
sub printReportFooter() {
	my $value;
	$value = getDATAItem('PageFooter');
	print OUT $value;
}

# -----------------------------------------
# -----------------------------------------
sub printGraphHeader() {
	my $value;
	$value = getDATAItem('GoogleTimelineHeader');
	print OUT $value;
}

# -----------------------------------------
# -----------------------------------------
sub printGraphFooter($$$) {
	my $elementID = shift;
	my $height = shift;
	my $width = shift;
	my $value;
	$value = getDATAItem('GoogleTimelineFooter');
	$value =~ s/%CHARTELEMENT%/$elementID/g;
	$value =~ s/%WIDTH%/$width/;
	$value =~ s/%HEIGHT%/$height/;
	print OUT $value;
}

# -----------------------------------------
# -----------------------------------------
sub printSessionSectionHeader($$) {
	my $sectionName = shift;
	my $resolution = shift;
	my $value = getDATAItem('SessionSectionHeader');
	$value =~ s/%SectionName%/$sectionName/g;
	$value =~ s/%Resolution%/$resolution/g;
	print OUT $value;
}

# -----------------------------------------
# -----------------------------------------
sub printsSectionHeader($) {
	my $sectionName = shift;
	my $value = getDATAItem('CombinationsSectionHeader');
	print OUT $value;
}


# -----------------------------------------
# -----------------------------------------
sub printTableHeader() {
	my $t = localtime;
	my $dateStr = $t->cdate;
	my $value;
	$value = getDATAItem('TableHeader');
	$value =~ s/%DATE%/$dateStr/g;
	print OUT $value;
}

# -----------------------------------------
# -----------------------------------------
sub printTableTrailer() {
	my $value;
	$value = getDATAItem('TableTrailer');
	print OUT $value;
}



# -----------------------------------------
# End current row (if there is one) and starts new row.
# -----------------------------------------
sub startNewRow($prevLoginId, $loginId, $role) {
	my ($prevLoginId, $loginId, $role) = @_;
	if ($html) {
		print OUT "\t\t</tr>\n" if ($prevLoginId ne "");
	} else {
		print OUT "\n" if ($prevLoginId ne "");
		print OUT sprintf("%-29s%s", $loginId, $role);
	}
}


# This logs all activity on a file
sub lg() {
    return; # no logging for now
    my ($s) = @_;
    
    open F, ">>logfile.txt" or die "$! logfile.txt";
    print F $s . "\n";
    close F;
}

#--------------------------------------------------------------------------
# parseCommandLine
# Returns true if the report file name was provided on the command line
#--------------------------------------------------------------------------
sub parseCommandLine #
{
    my($argc) = shift(@_);

    $server = "";
	$includeUserSessionsSection = 1;
	
    my $gotFileName = 0;
	my ($startGiven, $endGiven, $monthGiven, $lengthGiven) = (0, 0, 0, 0);
	my $duration;
	my $month;
	
	# The default time range is the start of the current month to now.
	# These get overwritten if other options are given
	$lclEndDate = ParseDate("tomorrow at midnight");
	$lclStartDate = substr($lclEndDate, 0, 6) . "01";
    my $paramCt = 0;
    # Parameters in order are: server name, database name
    for (my $i=0; $i<$argc; $i++)
    {
#		print "A[$i]=$ARGV[$i]\n";
        # Look for command options (First char is slash or dash)
        my $firstChar = substr($ARGV[$i], 0, 1);
        if ($firstChar eq "-" || $firstChar eq "/")
        {
            my $secondChar = substr($ARGV[$i], 1, 1);
            my $optionVal = substr($ARGV[$i], 2);

			# Start data given?
			if ($secondChar eq "s" || $secondChar eq "S")
			{
				$optionVal = getOptionValue(\$i);
				$startGiven = 1;
				my $d = ParseDate($optionVal);
				if (!$d) {
					printUsage("Error: invalid date ($optionVal) given in -s option\n");
				} else {
					$lclStartDate = $d;
				}
			}
			# end date?
			elsif ($secondChar eq "e" || $secondChar eq "E")
			{
				$endGiven = 1;
				$optionVal = getOptionValue(\$i);
				my $d = ParseDate($optionVal);
				if (!$d) {
					printUsage("Error: invalid date ($optionVal) given in -e option\n");
				} else {
					$lclEndDate = $d;
				}
			}
			# length of time
			elsif ($secondChar eq "l" || $secondChar eq "L")
			{
				$lengthGiven = 1;
				$optionVal = getOptionValue(\$i);
				my $d = ParseDateDelta($optionVal);
				if (!$d) {
					printUsage("Error: invalid duration($optionVal) given in -d option\n");
				} else {
					$duration = $d;
				}
			}
			# Specify a month of the current year
			elsif ($secondChar eq "m" || $secondChar eq "M")
			{
				$monthGiven = 1;
				$month = getOptionValue(\$i);
			}
            elsif ($secondChar eq "d" || $secondChar eq "D")
            {
                if (++$i < $argc)
                {
                    my $newDir = $ARGV[$i];
                    die "Failed to change working directory to directory $newDir given in -d option.\nYou must specify a valid, existing directory.\n" if (!chdir($newDir));
                } else {
                    printUsage("Error: missing directory name following -d option.\n");
                }
            }

			# Schema name option
            elsif ($secondChar eq "n" || $secondChar eq "N")
            {
				$schemaName = getOptionValue(\$i) . '.'; # Query syntax needs a '.' separator
            }

			# Customer name option
            elsif ($secondChar eq "c" || $secondChar eq "C")
            {
				$customerName = getOptionValue(\$i);
            }

			# Specify session idle timeout (mins)
			elsif ($secondChar eq "t" || $secondChar eq "t")
			{
				$idleTimeoutGiven = 1;
				$calculatedIdleTO = getOptionValue(\$i);
			}


			# Omit user session portion of report? 
#            elsif ($secondChar eq "u" || $secondChar eq "U")
#            {
#				$includeUserSessionsSection = 0;
#            }

			
            else
            {
                printUsage("Error: unrecognized command option $ARGV[$i]\n");
            }
        }

        # Otherwise it's a parameter, figure out which
        else
        {
            $paramCt++;
            if ($paramCt == 1)
            {
                $server = $ARGV[$i];
            }
            elsif ($paramCt == 2) {
                $dbLogin = $ARGV[$i];
            }
            elsif ($paramCt == 3) {
                $dbPassword = $ARGV[$i];
				$dbPasswordGiven = 1;
            }
            elsif ($paramCt == 4) {
                $fileName = $ARGV[$i];
                $gotFileName = 1;
            }
            else
            {
                printUsage("Error: Command line has too many parameters--see usage.");
            }
        }
		
#		print "EOL=$i\n";
	}
    
	my $err;
	# Validate that only valid date combinations were given
    printUsage("Error: you must provide a server name, database name, and a passsword--see usage.") if ($server eq "" || $dbLogin eq "" || !$dbPasswordGiven);
	if ($startGiven && $monthGiven) { printUsage("Error: the -s and -m options cannot be used together\n"); }
	if ($endGiven && $lengthGiven) { printUsage("Error: the -e and -l options cannot be used together\n"); }
	if ($monthGiven && $lengthGiven) { printUsage("Error: the -m and -l options cannot be used together\n"); }
		

	# Adjust start and end dates according to parameters given
	if ($monthGiven) {
#		print "month given\n";
		# No other options can be used with month
		printUsage("Error: the -s, -e, and -l options cannot be used with -m\n") if ($startGiven || $endGiven || $lengthGiven);
		if ($month >= 0 && $month <= 12) {
			my $curMonth = substr(ParseDate("now"), 4, 2);
			my $m;
			# Month 0 means to use current month
			if ($month == 0) {
				$m = $curMonth;
			} else {
				$m = sprintf("%02d", $month);
			}
		
			if ($m le $curMonth) {
				$lclStartDate = substr(ParseDate("now"), 0, 4) . $m . "01";
				$lclStartDate = ParseDate($lclStartDate);
				$lclEndDate = DateCalc($lclStartDate, '+1m');
			} else {
				printUsage("Error: month number in -m option ranges from 0 up to and including the current month ($curMonth)\n");
			}
		} else {
			printUsage("Error: Month number must be in the range 1-12 (inclusive) in the -m option\n");
		}
	} elsif ($lengthGiven) {		# Length can be used only with startdate
		#print "Length given\n";
		# If start was also given, then length is length from start
		if ($startGiven) {
			$lclEndDate = DateCalc($lclStartDate, $duration);
		# Otherwise length is length backward from now or end if end given
		} else {
			$lclEndDate = ParseDate("now") if (!$endGiven);
			print "now=$lclEndDate\n";
			# Make duration negative
			$duration = '-' . substr($duration, 1);
			$lclStartDate = DateCalc($lclEndDate, $duration, \$err);
		}
	} else {					# Only -s or -e given maybe
		$lclEndDate = ParseDate("tomorrow at midnight") if (!$endGiven);
		$lclStartDate = ParseDate("today at midnight") if (!$startGiven);
		
	}
	if ($lclEndDate lt $lclStartDate) { printUsage("Error: start date ($lclStartDate) must be less than or equal to end date ($lclEndDate)\n"); }
	print "Report will cover the period from: ", UnixDate($lclStartDate, "%Y-%m-%d %H:%M:%S"), " (inclusive)\n";
	print "                               to: ", UnixDate($lclEndDate, "%Y-%m-%d %H:%M:%S"), " (exclusive)\n";
	my $delta = DateCalc($lclStartDate, $lclEndDate, \$err);
#	print "D $delta\n";
	my $days = Delta_Format($delta, 0, ('%dt'));
#	print "days=$days\n";
	#die;
    return $gotFileName;
}

#--------------------------------------------------------------------------
#--------------------------------------------------------------------------
sub getOptionValue(\$) {
    my $refI = shift;
	die "getOptionVal must be called with a reference to a scalar\n" if (!ref $refI);
#	print "GO=$ARGV[$$refI]\n";
    my $optionVal = substr($ARGV[$$refI], 2);
#    print "OptionVal(e): $optionVal\n";
    if ($optionVal eq '') {
        $$refI++;
        $optionVal = $ARGV[$$refI];
    }

#    print "OptionVal(x): $optionVal\n";
    return $optionVal;
}




#--------------------------------------------------------------------------
# PrintUsage
#--------------------------------------------------------------------------
sub printUsage #(Msg)
{
    my ($Msg) = shift(@_);
    die(
        "\n" .
        "ReportUserSessionsOZ(v$version) - Generates a report of user session for the\n" .
		"  specified reporting period. This works by querying the AC_USER_LOGIN_HISTORY\n" .
		"  table in the Optymyze SPM Schema.\n" .
        "\n" .
        "Usage: ReportUserSessionsOZ.pl <db_server> <SPM_account> <SPM_password>\n" .
        "                                [<report_output_name>] [options...]\n" .
        "where\n" .
        "  <db_server> is the name of the database server housing the\n" .
        "    Optymyze application database.\n" .
        "  <SPM_account> is the account name directly tied to the SPM schema containing\n" .
		"    the AC_USER_LOGIN_HISTORY table. This schema is normally named '<client>_SPM\n'". 
		"    Look in OCM for this. If you are using an account that is not tied to the\n" .
		"    SPM schema directly, then you must also provide the SPM schema name using\n" .
		"    the -n option.\n" .
		"  <SPM_password> is the passsword to the SPM schema. Look in OCM for this.\n" .
        "  <report_output_name> is the name of the report output file. The name can\n" .
        "    include a full path name. If this is omitted the report output will be\n" .
        "    in the default directory with the report name:\n" .
        "      User_Session_Report_for_<Customer>_run_on_<Date>.htm\n" .
        "    where <Customer> is the value given in the -c option and <Date> is the\n" .
		"    date this script is run.\n\n" .
		"    Note that when you supply the filename, you can have the customer name\n" .
		"    and date inserted into the name automatically by using the place holders\n" .
		"    %C% and %D%, respectively, anywhere in file path.\n" .
		"\n" .
		" [options...] is one or more of the following:\n" .
		"    -c <customer name> - is the name of the customer to be placed on the\n" .
		"       report header. Optional.\n" .
        "    -d allows you to optionally set the process working directory to dir_name.\n" .
        "       By default, the process working directory is the location of the Perl\n" .
        "       script. By changing this, you can place the default report output file\n" .
        "       where you want it.\n" .
        "    -e <date> - end date/time of reporting period. Only log entries before\n" . 
        "       (but not including) this time are considered. If not given, defaults\n" .
		"       to tomorrow at midnight. May not be used with -d or -m.\n" .
        "    -l <length> - the length of the reporting period from the time given by\n" .
        "       -s. The general format is <n><u> where <n> is a count and <u> is one\n" .
        "       of the following time units: s (seconds), h (hours), d (days), w (weeks).\n" .
        "       Example: use '-d2d' to specify 2 days from the start time. May not be\n" .
		"       used with -e, -m, or -s.\n" .
		"    -m <month #> - month to report on. January is month 1. You may use 0 to\n" .
		"       always refer to the current month. May not be combined with -s, -e, or -d\n" .
		"    -n <Schema name for SPM> - is the optional name of the SPM schema. If the\n" .
		"       SPM_account provided on the command line does not default to the\n" .
		"       SPM schema, you must also provide the actual SPM schema name using this\n" .
		"       option or you will get a query failure." .
        "    -s <date> - start date/time of reporting period. Only log entries on or\n" .
        "       after this time are considered. If not given defaults to start of\n" .
		"       today.\n\n" .
		"    -t <session idle timeout (mins)> - for user sessions that time out (because the\n" .
		"       user just closed the browsser and didn't log out), their session is\n" .
		"       reported as longer than it was because it includes the idle timeout time.\n" .
		"       By providing the idle timeout time, a more accurate report can be\n" .
		"       generated by substrating the idle timeout from the total session length\n" .
		"       for sessions that timed out. Use -t 0 to override auto calculation.\n" .
#		"    -u omit user session section of report. By default, this section is included.\n" .
		"When specifying dates in date options, give dates and times in one of the\n" .
		"following formats:\n" .
		"   yyyy-mm\n" .
		"   yyyy-mm-dd\n" .
		"   mm/dd/yyyy\n" .
		"   yyyy-mm-dd-hh:mm:ss (minutes and seconds are optional)\n" .
		"   yyyy-mm-ddThh:mm:ss (minutes and seconds are optional)\n" .
		"\n" .		
		"\n" .
		"Processing:\n" .
		"If no date options are given, the report covers all records on or after the\n" .
		"first day of the current month.\n" .
		"\n" .
		"Note that the only supported authentication mechanism is password\n" .
		"authentication using the schema name and password. These can be pulled from\n" .
		"OCM.\n" .
        "\n" . $Msg . "\n"
    );	
}                                           




#<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

# The text after data is loaded into a hash with the hash key being the first line that starts with '/'.
# The value is every line after that up to but including the line starting with '~'.
# Comnments line (starting with '#') are ignored.
__DATA__
#-------------------------------------------------------------------
# Page header for main page
#-------------------------------------------------------------------
/PageHeader
# Report Header HTML (~ ends entry)
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html lang='en'>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title>%ReportName%</title>
<script type='text/javascript' src='https://www.google.com/jsapi'></script>

<style type="text/css" media="print,screen" > 
body            { font: 11pt tahoma,verdana,arial,helvetica,sans-serif; text-align:left; color: #000000; }
.table_border    { border-top: solid 1px #1F70B6; border-right: solid 1px #cccccc; border-bottom: solid 1px #cccccc; border-left: solid 1px #cccccc; background-color: none; text-align:left; }
.table_title     { border: solid; border-color: white; border-left-width: 0px; border-right-width: 0px; border-top-width: 1px; border-bottom-width: 1px; font: 14pt tohoma, verdana, arial, helvetica, sans-serif; text-align:left; font-weight: bold; color: #FFFFFF; padding: 4px 5px 4px 12px;}
.table_title_r   { border: solid; border-color: white; border-left-width: 0px; border-right-width: 0px; border-top-width: 1px; border-bottom-width: 1px; font: 12pt tohoma, verdana, arial, helvetica, sans-serif; text-align:right; font-weight: bold; color: #FFFFFF; padding: 4px 5px 4px 12px;}
.table_title_c   { border: solid; border-color: white; border-left-width: 0px; border-right-width: 0px; border-top-width: 1px; border-bottom-width: 1px; font: 14pt tohoma, verdana, arial, helvetica, sans-serif; text-align:center; font-weight: bold; color: #FFFFFF; padding: 4px 5px 4px 12px;}
.table_data   { padding: 0px; width: 60%; border: 0px solid #cccccc; border-top-width: 0px; border-left-width: 1px; border-right-width: 1px; border-bottom-width: 1px; background-color: #FFFFFF; text-align:left; }
.table_title_row { background-color: #1F70B6; }
.tr_head	{ background-color: #cccccc; } /* rows 0, 2, 4, etc */
.c /* Odd table column */    { border-right: solid 1px white; padding: 6px 4px 3px 4px; }
.d /* Even table column */   { border-right: solid 1px #EDEDED; padding: 6px 4px 3px 4px; }
.e /* Odd column dim */     { border-right: solid 1px white; padding: 3px 4px 3px 4px; color: #C0C0C0}
.f /* Even column dim */     { border-right: solid 1px #EDEDED; padding: 3px 4px 3px 4px; color: #C0C0C0}
.g /* Odd column alert */    { border-right: solid 1px white; padding: 3px 4px 3px 4px; background-color: #FFC0C0;}
.h /* Even column alert */   { border-right: solid 1px #EDEDED; padding: 3px 4px 3px 4px; background-color: #FFC0C0;}
.a  /* Odd table rows */  { background-color: #EDEDED;  } /* rows 1, 3, 5, etc */
.b	/* Even table rows */ { background-color: #FFFFFF;  } /* rows 0, 2, 4, etc */
th		{ border-right: solid 1px white; padding: 6px 2px 4px 4px; font: bold 10pt tahoma, arial, helvetica, sans-serif; text-align:left; color: #222; }
td		{ border-color: #ECECEC; border-left-width: 0px; border-right-width: 1px; border-top-width: 0px; border-bottom-width: 1px; font: 11px verdana, arial, helvetica, sans-serif; text-align:left; color: #000000; }
.tbigr { font: 11pt tahoma,verdana, arial, helvetica, sans-serif; text-align:right; }
.tbig  { font: 11pt tahoma,verdana, arial, helvetica, sans-serif; }
thead {
	display:table-header-group;
}
tbody {
	display:table-row-group;
}
@media print {
   thead {display: table-header-group;}
}
</style>
</head>    
<script>
function hideJSAlert()
{
  window.status = "hideJSAlert called";
}
</script>

<body onload='hideText()'>
<script type="text/javascript">
	function hideText() {
		var JSText = document.getElementById('JSAlert');
		JSText.style.display = 'none';
		}
	 </script>
<table class="table_data" cellspacing="0">
	<thead>
		<TR class="table_title_row"><TD colspan="7" class="table_title_c">%ReportName%</TD></TR>
		<TR class="table_title_row"><TD colspan="6" class="table_title">Optymyze Software</TD><TD class="table_title_r">%Date%</TD></TR>
	</thead>
</table>
<p>
This report contains information about user sessions and attributes for those sessions for a given period of time. It is derived from a 
database table that logs information each time a user logs into and out of the software.<br><br>All times are in UTC%TZOFFSET%.  
<p>
<table>
<tr><td class="tbigr"></td><td class="tbig"><b>Requested times<b></td><td>&nbsp;&nbsp;&nbsp;</td><td class="tbig"><b>Found Times<b></td></tr>
<tr><td class="tbigr">The report period from and to times are:</td><td class="tbig"><b>%CoverageFrom%<b></td><td>&nbsp;&nbsp;&nbsp;</td><td class="tbig"><b>%FoundFrom%<b></td></tr>
<tr><td class="tbigr">and up to but not including:</td><td class="tbig"><b>%CoverageTo%<b></td><td>&nbsp;&nbsp;&nbsp;</td><td class="tbig"><b>%FoundTo%<b></td></tr>
<tr><td class="tbig"></td></tr><tr><td class="tbig"></td></tr>
<tr><td class="tbig">Total number of user sessions:</td><td class="tbig"><b>%Sessions%</b></td></tr>
<tr><td class="tbig">Total number of service monitor sessions:</td><td class="tbig"><b>%SvcSessions%</b></td></tr>
<tr><td class="tbig">Total number of unique Login IDs:</td><td class="tbig"><b>%LoginIDs%</b></td></tr>
<tr><td class="tbig">%IdleTimeoutSource% session idle timeout (mins):</td><td class="tbig"><b>%IdleTimeout%&nbsp;&nbsp;&lt;---- Important! Confirm value is accurate for accurate report.</b></td></tr>
</table><br>
The report has the following sections:
<ul><li><a href="#_concurrent_sessions_section_">Users Session Totals and Concurrency</a> - shows graphs of total user sessions and session 
concurrency rates by various time measures
<li><a href='#Sessions By Login ID'>Sessions by Login ID</a> - shows session counts, participant ID, and roles by individual user (Login ID). 
Users with more than one Participant ID or Roles combination are highlighted in pink.
<!--
<li>the third section, <a href="#_detail_section_">Session History by User</a>, is a transaction log of user sessions ordered by Login Id and login date within Login Id. 
You can use this section to see details over time for a given Login Id. 
Here changes in Participant ID or Roles from the previous record are hightlighted in pink as an alert.
-->
</ul>

<br>
~


#-------------------------------------------------------------------
# Header for Google Annotated Time Line visualization (with specific columns
#-------------------------------------------------------------------
/GoogleTimelineHeader
<script type='text/javascript'>
       google.load('visualization', '1', {'packages':['annotatedtimeline']});       
	   google.setOnLoadCallback(drawChart);       
	   function drawChart() {         
var data = new google.visualization.DataTable(
     {
       cols: [{id: 'date', label: 'Datetime', type: 'datetime'},
              {id: 'concurrent', label: 'Sessions started', type: 'number'},
              {id: 'started', label: 'Concurrent sessions', type: 'number'}],
       rows: [
~

#-------------------------------------------------------------------
# Footer for Google Annotated Time Line visualization (with specific columns)
#-------------------------------------------------------------------
/GoogleTimelineFooter
]},0.6)
var chart = new google.visualization.AnnotatedTimeLine(document.getElementById('%CHARTELEMENT%')); 
var date_formatter = new google.visualization.DateFormat({ pattern: 'M-dd-yy HH:mm'});   
// Reformat our data.   
date_formatter.format(data, 0);   
chart.draw(data, {dateFormat: 'kk:mm EEE d-MMM-yyyy', displayAnnotations: true,scaleType:'fixed',colors:['#2014fa','#fa9589']});       
}     
</script>
<table align="left"><tr><td>
<div id='%CHARTELEMENT%' style='width: %WIDTH%px; height: %HEIGHT%px;'></div>   
</td></tr></table>
~

#-------------------------------------------------------------------
# Footer for main page
# <div id='chart_div' style='width: 900px; height: 350px;'></div>   
#-------------------------------------------------------------------
/PageFooter
</body> 
</html>
~
	   

#-------------------------------------------------------------------
# Table Trailer (~ end entry)
#-------------------------------------------------------------------
/TableTrailer
</tbody></table><br>
~
#-------------------------------------------------------------------
# Session Section Header
#-------------------------------------------------------------------
/SessionSectionHeader
<br><br>
<table align="left" id="#_concurrent_sessions_section_" class="table_data" cellspacing="0" style='page-break-before:always;'>
	<TR class="table_title_row"><TD colspan="4" class="table_title">%SectionName%<br><div class='tbig'>
This section shows user sessions by various time metrics. Sessions created by automated monitoring tools are excluded.
	</div></TD></TR>
</table>
<br><br><br><br>
The first graph is an interactive timeline of all user sessions in the reporting periods. The graph has two number series:
<ul>
<li>the hightest number of concurrent user sessions - this series shows the highest number of active user sessions during a period.
<li>the average number of sessions started - this series shows the number of sessions that were started during a period (whether they ended in the same period or not).
</ul> 
The resolution of the graph determines the length of a period. The resolution varies based on the amount of time covered
by the report to keep the number of points on the graph to a reasonable number. This graph has a resolution of %Resolution%.
<p>The remaining graphs are static graphs showing the same two metrics by day of week, day of month, and time of day.
<b id='JSAlert'><br><br>If you cannot see the graphs immediately below, it is likely that your browser is blocking JavaScript execution. 
You must enable JavaScript execution to view the graphs.</b>
<p>
~


/DayOfWeekGraphHeader
#-------------------------------------------------------------------
# Sessions by Day of week graph header
#-------------------------------------------------------------------
 <script type="text/javascript" src="https://www.google.com/jsapi"></script>     
 <script type="text/javascript">
 google.load("visualization", "1", {packages:["corechart"]});
 google.setOnLoadCallback(drawChart);
 function drawChart() {
 var data = new google.visualization.DataTable();
 data.addColumn('string', 'Sessions by Day of Week');  
 data.addColumn('number', 'Avg # of Sessions Started'); 
 data.addColumn('number', 'Largest # of Concurrent Sessions');
 data.addRows(7);  
 data.setValue(0, 0, 'Sun');  
 data.setValue(0, 1, %0S%);   
 data.setValue(0, 2, %0A%);   
 data.setValue(1, 0, 'Mon'); 
 data.setValue(1, 1, %1S%);   
 data.setValue(1, 2, %1A%);   
 data.setValue(2, 0, 'Tue'); 
 data.setValue(2, 1, %2S%);    
 data.setValue(2, 2, %2A%);    
 data.setValue(3, 0, 'Wed'); 
 data.setValue(3, 1, %3S%);   
 data.setValue(3, 2, %3A%);   
 data.setValue(4, 0, 'Thu'); 
 data.setValue(4, 1, %4S%);   
 data.setValue(4, 2, %4A%);   
 data.setValue(5, 0, 'Fri'); 
 data.setValue(5, 1, %5S%);   
 data.setValue(5, 2, %5A%);   
 data.setValue(6, 0, 'Sat'); 
 data.setValue(6, 1, %6S%);   
 data.setValue(6, 2, %6A%);   
 var chart = new google.visualization.ColumnChart(document.getElementById('dayofweekgraph')); 
 chart.draw(data, {width: 700, height: 300, legend:'top', title: 'Sessions by Day of Week', 
 hAxis: {title: '', titleTextStyle: {color: 'red'}}       
 });       }
 </script> 
 <div id="dayofweekgraph"></div>
~
/DayOfMonthGraphHeader
#-------------------------------------------------------------------
# Sessions by Day of Month graph header
#-------------------------------------------------------------------
 <script type="text/javascript" src="https://www.google.com/jsapi"></script>     
 <script type="text/javascript">
 google.load("visualization", "1", {packages:["corechart"]});
 google.setOnLoadCallback(drawChart);
 function drawChart() {
 var data = new google.visualization.DataTable();
 data.addColumn('string', 'Sessions by Day of Month');  
 data.addColumn('number', 'Avg # of Sessions Started'); 
 data.addColumn('number', 'Largest # of Concurrent Sessions'); 
 data.addRows(31);  
 %ColumnValues%
 var chart = new google.visualization.ColumnChart(document.getElementById('dayofmonthgraph')); 
 chart.draw(data, {width: 700, height: 300, legend:'top', title: 'Sessions by Day of Month', 
 hAxis: {title: '', titleTextStyle: {color: 'red'}}       
 });       }
 </script> 
 <div id="dayofmonthgraph"></div>
~
/TimeOfDayGraphHeader
#-------------------------------------------------------------------
# Sessions by Time of Day graph header
#-------------------------------------------------------------------
 <script type="text/javascript" src="https://www.google.com/jsapi"></script>     
 <script type="text/javascript">
 google.load("visualization", "1", {packages:["corechart"]});
 google.setOnLoadCallback(drawChart);
 function drawChart() {
 var data = new google.visualization.DataTable();
 data.addColumn('string', 'Sessions by Time of Day');  
 data.addColumn('number', 'Avg # of Sessions Started'); 
 data.addColumn('number', 'Largest # of Concurrent Sessions'); 
 %ColumnValues%
 var chart = new google.visualization.ColumnChart(document.getElementById('timeofdaygraph')); 
 chart.draw(data, {width: 1000, height: 300, legend:'top', title: 'Sessions by Time of Day (periods ending every %RES%)', 
 hAxis: {title: '', titleTextStyle: {color: 'red'}}       
 });       }
 </script> 
 <div id="timeofdaygraph"></div>
~
  