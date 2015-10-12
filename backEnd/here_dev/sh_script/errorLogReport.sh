#using for get log error and report to monitor
#crontab task
grep -i -n error $HOME/logs/*>$HOME/err_report.txt

#if error exist, send email to monitor

