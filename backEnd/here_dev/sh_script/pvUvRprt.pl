#! /usr/bin/perl

#using for get log error and report to monitor
#crontab task

#if error exist, send email to monitor

$HOME = $ENV{HOME};

#Run and Create Rport data task
#system("`node $HOME/here/backEnd/here_dev/utility/staticRprt.js &`");

my $time = shift || time();
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
$year += 1900;
$mon ++;

my $mydate= $year."-".$mon."-".$mday;

system("`tar czvf $HOME/log_back/$mydate'_accessLog.tar' $HOME/here/backEnd/here_dev/access.log &`");

system("`rm -rf $HOME/here/backEnd/here_dev/access.log &`");
