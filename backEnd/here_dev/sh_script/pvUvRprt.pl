#! /usr/bin/perl

#using for get log error and report to monitor
#crontab task

#if error exist, send email to monitor

$HOME = $ENV{HOME};

my $time = shift || time();
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
$year += 1900;
$mon ++;

my $mydate= $year."-".$mon."-".$mday;

printf $mydate;

system("tar czvf $HOME/log_back/$mydate'_access_log.tar' $HOME/here/backEnd/here_dev/access.log");


#Run and Create Rport data task
print "count pv and upv\n";
system("node $HOME/here/backEnd/here_dev/utility/staticRprt.js");




print "clear access.log\n";
system(">$HOME/here/backEnd/here_dev/access.log");
print "end\n";
