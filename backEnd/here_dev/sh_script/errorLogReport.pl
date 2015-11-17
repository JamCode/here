#! /usr/bin/perl


#using for get log error and report to monitor
#crontab task

#system("grep -i -n error $HOME/logs/*>$HOME/err_report.txt");


#if error exist, send email to monitor

$HOME = $ENV{HOME};
$env = $ENV{ENV};

`grep -i -n error $HOME/logs/*>$HOME/err_report.txt`;

my $time = shift || time();
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
$year += 1900;
$mon ++;

$subject = $year."-".$mon."-".$mday."-错误报告_".$env;
print $subject."\n";

$filePath = "$HOME/err_report.txt";

`node $HOME/here/backEnd/here_dev/utility/sendEmail.js $subject $filePath &`


# text="错误日志";

# cat $HOME/err_report.txt | while read line
# do
# 	text=$text$line;
# 	echo $text;
# done
# echo ${text};

#node $HOME/here/backEnd/here_dev/utility/sendEmail.js $subject $text &
