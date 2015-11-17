#! /usr/bin/perl

#using for get log error and report to monitor
#crontab task

#if error exist, send email to monitor

$HOME = $ENV{HOME};
chdir "$HOME/here/backEnd/here_dev/";
#delete (T-1) report data rptLog.txt
system("rm -r -f ./rptLog.txt");
#Run and Create Rport data task
system("`node $HOME/here/backEnd/here_dev/utility/staticRprt.js &`);
my $time = shift || time();
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
$year += 1900;
$mon ++;

$subject = $year."-".$mon."-".$mday."-PV AND UV 统计数据";
print $subject."\n";

$filePath = "$HOME/here/backEnd/here_dev/rptLog.txt";

`node $HOME/here/backEnd/here_dev/utility/sendEmail.js $subject $filePath &`
