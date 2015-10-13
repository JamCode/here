#using for get log error and report to monitor
#crontab task
grep -i -n error $HOME/logs/*>$HOME/err_report.txt

#if error exist, send email to monitor
mydate=`date +"%Y%m%d"`

$subject = "错误报告-"+mydate

echo $subject;
#node $HOME/here/backEnd/here_dev/utility/sendEmail.js $subject "no"
