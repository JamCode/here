#! /usr/bin/perl

#调用样例 proDeploy.pl 1.0.4
#部署1.0.4版本

print "stop all processes\n";
system("`stophere`");

$put=@ARGV;
if($put!=1){
	print "parameter error, should add version num like \"proDeploy.pl 1.0.4\"\n";
	exit -1;
}

print $ARGV[0]."\n";

chdir "$HOME";
system("wget https://github.com/JamCode/here/archive/".$ARGV[0].".zip");
system("unzip ".$ARGV[0]);
system("mv here here_old");
system("mv here-".$ARGV[0]." here");
chdir "$HOME/here";
system("rm -r -f ./frontEnd");


#数据库备份和升级

#system("mysqldump -hrdsruiaj3v2uaiv.mysql.rds.aliyuncs.com -upro_wanghan -ppro_wanghan pro_online > $HOME/database_last_back.sql");

chdir "$HOME/here/backEnd/here_dev/sql";

#执行数据库升级脚本
system("mysql -upro_wanghan -ppro_wanghan -Dpro_online <".$ARGV[0].".sql>./sqllog.txt");

#启动应用
system("`starthere`");

print "update finish!\n";

#升级完成













