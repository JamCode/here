#! /usr/bin/perl

#using for get log error and report to monitor
#crontab task

#if error exist, send email to monitor

$HOME = $ENV{HOME};

#Run and Create Rport data task
system("`node $HOME/here/backEnd/here_dev/utility/staticRprt.js &`");
