#! /usr/bin/perl


#using for get system status report

#crontab task

#send email to monitor

$HOME = $ENV{HOME};
$env = $ENV{ENV};
`cd $HOME`;
`du -m --max-depth=1 ~/>$HOME/sys_report.txt`;
`df -h>>$HOME/sys_report.txt`;

my $time = shift || time();
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
$year += 1900;
$mon ++;

$subject = $year."-".$mon."-".$mday."-文件系统报告_".$env;
print $subject."\n";

$filePath = "$HOME/sys_report.txt";

`node $HOME/here/backEnd/here_dev/utility/sendEmail.js $subject $filePath &`
