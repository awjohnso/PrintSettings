#!/usr/bin/perl -w

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


	# Set some variables.
my $log = LogName();
my $vers="v1.00";
my $n = 0;

	# Determine if the script is run by root. If not it will not work.
my $me = `/usr/bin/whoami`;
chomp $me;

if ( $me ne "root" )
{
	print TimeStamp . " " . MyName . "[". $$ . "]: " . "Starting " . MyName . " " . $vers . ".\n";
	print TimeStamp . " " . MyName . "[". $$ . "]: " . "This script needs to be run by root.\n";
	print TimeStamp . " " . MyName . "[". $$ . "]: " . "Ending " . MyName . " " . $vers . ".\n";
	exit;
}

	# Open the log file and start logging. Only root can write to the log file location.
open(LOG,">$log");
print LOG TimeStamp . " " . MyName . "[". $$ . "]: " . "Starting " . MyName . " " . $vers . ".\n";

	# Check the print status to see if changes are necessary.
my $printStatus = `/usr/libexec/PlistBuddy -c 'Print :rights:system.print.operator:group' /private/etc/authorization`;
chomp $printStatus;

if ( $printStatus eq "everyone" )
{
	print LOG TimeStamp . " " . MyName . "[". $$ . "]: " . "system.print.operator group is set to everyone. Nothing to change.\n";
	print LOG TimeStamp . " " . MyName . "[". $$ . "]: " . "Ending " . MyName . " " . $vers . ".\n";
	close(LOG);
	exit;
}

	# If changes are necessary attempt to change them. Should it fail the loop will continue for n itereations in this case 3. After that it will give up.
while ( $printStatus eq "_lpoperator" )
{
	print LOG TimeStamp . " " . MyName . "[". $$ . "]: " . "system.print.operator group is set to _lpoperator. I will now set it to everyone.\n";
	system("/usr/libexec/PlistBuddy -c 'Set :rights:system.print.operator:group everyone' /private/etc/authorization");
	$n++;
	$printStatus = `/usr/libexec/PlistBuddy -c 'Print :rights:system.print.operator:group' /private/etc/authorization`;
	chomp $printStatus;
	print LOG TimeStamp . " " . MyName . "[". $$ . "]: " . "system.print.operator group has been successfully set to the everyone.\n" if ( $printStatus eq "everyone" );
	if ( $n == 3 )
	{
		print LOG TimeStamp . " " . MyName . "[". $$ . "]: " . "There is a problem setting system.print.operator group to the everyone.\n";
		print LOG TimeStamp . " " . MyName . "[". $$ . "]: " . "Unsuccessfull Exit: " . MyName . " " . $vers . ".\n";
		close(LOG);
		exit;
	}
}

print LOG TimeStamp . " " . MyName . "[". $$ . "]: " . "Ending " . MyName . " " . $vers . ".\n";
close(LOG);
exit;
