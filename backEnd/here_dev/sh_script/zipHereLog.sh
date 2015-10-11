#using for zip here log every day 23:59:59
#mydate=$(`date+%y%m%d`)
  
tar czvf $HOME/log_back/$mydate'_here_log.tar' $HOME/logs/*
rm $HOME/logs/*