#using for get log error and report to monitor
#crontab task

system("grep -i -n error $HOME/logs/*>$HOME/err_report.txt");


#if error exist, send email to monitor
$mydate=system("`date +"%Y%m%d"`");
print $mydate."\n";
$subject=$mydate."错误报告";
print $subject."\n";


# text="错误日志";

# cat $HOME/err_report.txt | while read line
# do
# 	text=$text$line;
# 	echo $text;
# done
# echo ${text};

#node $HOME/here/backEnd/here_dev/utility/sendEmail.js $subject $text &
