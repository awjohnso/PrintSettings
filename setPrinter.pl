#!/usr/bin/perl -3

use File::Basename;
use Cwd qw(abs_path);
use Sys::Hostname;
use File::Copy;

	# Subroutine to detetmine the full path to this program.
sub pathToMe
{
	my $path = abs_path($0);
	$path = dirname($path);
	return $path;
}

	# Subroutine to determine the program name.
sub MyName
{
	my $path = abs_path($0);
	$name = basename($path);
	return $name;
}

	# Subroutine to determine the log name based on the name of the executable.
sub LogName
{
	my $myName = MyName;
		# Get rid of the the .pl part 
	(my $Name) = split(/\./,$myName);
		# Add the path and the .log to the name.
	my $logName = "/Library/Logs/" . $Name . ".log";
	return $logName;
}

	# Subroutine to determine the date and time for logging purposes.
sub TimeStamp
{
	my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
	my @weekDays = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
	my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
	my $year = 1900 + $yearOffset;
	$hour = sprintf("%.2d", $hour);
	$minute = sprintf("%.2d", $minute);
	$second = sprintf("%.2d", $second);
	$dayOfMonth = sprintf("%.2d", $dayOfMonth);
	my $theTime = "$months[$month] $dayOfMonth $hour:$minute:$second";
	return $theTime;
}


my $log = LogName();
my $vers="v1.00";

	# Open the log file and start logging.
open(LOG,">$log");
print LOG TimeStamp . " " . MyName . "[". $$ . "]: " . "Starting " . MyName . " " . $vers . ".\n";

my $printStatus = `/usr/libexec/PlistBuddy -c 'Print :rights:system.print.operator:group' /private/etc/authorization`;
chomp $printStatus;

if ( $printStatus eq "everyone" )
{
	print LOG TimeStamp . " " . MyName . "[". $$ . "]: " . "system.print.operator group is set to the _lpoperator. Nothing to change.\n";
	print LOG TimeStamp . " " . MyName . "[". $$ . "]: " . "Ending " . MyName . " " . $vers . ".\n";
	close(LOG);
	exit;
}


while ( $printStatus eq "_lpoperator" )
{
	print LOG TimeStamp . " " . MyName . "[". $$ . "]: " . "system.print.operator group is set to the _lpoperator. I will now set it to everyone.\n";
	system("/usr/libexec/PlistBuddy -c 'Set :rights:system.print.operator:group everyone' /private/etc/authorization");
	$printStatus = `/usr/libexec/PlistBuddy -c 'Print :rights:system.print.operator:group' /private/etc/authorization`;
}

print LOG TimeStamp . " " . MyName . "[". $$ . "]: " . "Ending " . MyName . " " . $vers . ".\n";
close(LOG);
exit;
