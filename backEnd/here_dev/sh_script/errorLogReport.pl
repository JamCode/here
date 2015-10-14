#! /usr/bin/perl


#using for get log error and report to monitor
#crontab task

#system("grep -i -n error $HOME/logs/*>$HOME/err_report.txt");


#if error exist, send email to monitor


my $time = shift || time();
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($time);
$year += 1900;
$mon ++;

$subject = $year."-".$mon."-".$mday."-错误报告";

$home = $ENV{HOME};

open(FILE,"<$home/err_report.txt")||die"cannot open the file: $!\n";

@linelist=<FILE>;
$content="";
foreach $eachline(@linelist){
    $content = $content.$eachline;
}

close FILE;

print $subject;
print $content;

system("node $home/here/backEnd/here_dev/utility/sendEmail.js ".$subject." ".$content." &");

# text="错误日志";

# cat $HOME/err_report.txt | while read line
# do
# 	text=$text$line;
# 	echo $text;
# done
# echo ${text};

#node $HOME/here/backEnd/here_dev/utility/sendEmail.js $subject $text &
