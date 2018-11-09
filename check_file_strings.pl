#!/usr/bin/perl
#################################################################################################
##
## check_file_strings.pl version 1.0
## 2018 Edson Lara based on check_file_content.pl by Alexandre Frandemiche (slobberbone4884 at gmail.com or on http://www.slobberbone.net)
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## The GNU GPL V2 is available at http://www.gnu.org/licenses/old-licenses/gpl-2.0.html
##
## contact the author directly for more information at:
## edson at edson.cl or on https://edson.cl
##
##################################################################################################
##
## Check if a string or a chain provided by -s option is present in a file
## which is critical when the number of founded line(s) is bigger than one provided by -c option.
## It works with local file
## This plugin requires that perl, perl-Filesys-SmbClient package are installed on the system.
## Exit 0 on success, providing some information
## Exit 1 on 
## Exit 2 on failure.
##
#################################################################################################

########## IMPORT PACKAGES ##########

use strict;
use POSIX;
use Getopt::Long;
use Encode;
use File::Slurp;
########## NAGIOS CODE ##########

my %ERRORS=('OK'=>0,'WARNING'=>1,'CRITICAL'=>2,'UNKNOWN'=>3);

########## VARIABLES ##########
my $Version='1.1';
my $Name=$0;
my $count = 0;
my $state = "OK";
my $status = "";
my $temp_file=		undef;

my $o_file =		undef; # path to file 
my $o_help=			undef; # want some help ?
my $o_version=		undef; # print version
my $o_ok_string=	undef; # number cause a warning
my $o_warn_string=	undef; # number cause a warning
my $o_crit_string=	undef; # number cause an error

########## MAIN ##########

check_options();

my $file_content = read_file($o_file);
$state = analyse_file($file_content,$o_ok_string, $o_warn_string,$o_crit_string);
print $file_content;
exit $ERRORS{$state};


########## FUNCTIONS ##########

# Display plugin's version
sub show_versioninfo { print "$Name version : $Version\n"; }

# Display plugin's usage
sub print_usage {
  print "Usage: $Name -f <file> -ok <ok_string> -w <warn_string> -c <crit_string>] -V\n";
}
sub analyse_file
{
	my $file_content=shift;
	my $o_ok_string=shift;
	my $o_warn_string=shift;
	my $o_crit_string=shift;
	my $retorno="UNKNOWN";
	
	if ($file_content =~ m/$o_ok_string/) {
		$retorno = "OK";
	}
	if ($file_content =~ m/$o_warn_string/) {
		$retorno = "WARNING";
	}
	if ($file_content =~ m/$o_crit_string/) {
		$retorno = "CRITICAL";
	}

  
  return $retorno;
}
sub check_options {
  Getopt::Long::Configure ("bundling");
  GetOptions(
		'h'     => \$o_help,        'help'				=> \$o_help,
		'f=s'   => \$o_file,        'file:s'    		=> \$o_file,
		'o=s'   => \$o_ok_string, 	 'ok:s'				=> \$o_ok_string,
		'w=s'   => \$o_warn_string,  'warn:s'			=> \$o_warn_string,
		'c=s'   => \$o_crit_string,  'critical:s'		=> \$o_crit_string,
		'V'     => \$o_version,     'version'			=> \$o_version,
  );
  if (defined ($o_help)) { help(); exit $ERRORS{"UNKNOWN"}};
  if (defined($o_version)) { show_versioninfo(); exit $ERRORS{"UNKNOWN"}};
  if ( (!defined($o_ok_string)) || (!defined($o_warn_string)) || (!defined($o_crit_string)) ) {
		print "Check warn and crit!\n"; print_usage(); exit $ERRORS{"UNKNOWN"}
  }
  if (!defined($o_file)) {
		print "Check access to the file!\n";
		print_usage();
		exit $ERRORS{"UNKNOWN"}
  }
}
sub help {
  print "Check_file_strings for Nagios, version ",$Version,"\n";
  print "GPL licence, (c)2018 Edson Lara\n\n";
  print "Site http://www.edson.cl\n\n";
  print_usage();
  print <<EOT;
-h, --help
	print this help message
-f, --filepath=PATHTOFILENAME
	full path to file to analyze
-o, --ok=STRING
	string to search to return OK
-w, --warn=STRING
	string to search to return WARNING
-c, --critical=STRING
	string to search to return CRITICAL
-V, --version
	prints version number
Note :
  The script will return
	 * With warn and critical options:
		  OK       if we are able to found expression from the var "o" we will return <ok_string>,
		  WARNING  if we are able to found expression var "w" we will return <warn_string>,
		  CRITICAL if we are able to found expression var "c" we will return <crit_string>,
		  UNKNOWN  if we aren't able to read the file
EOT
}
