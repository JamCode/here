#! /usr/bin/perl

#调用样例 proDeploy.pl 1.0.4
#部署1.0.4版本

print "stop all processes\n";
system("./stopall.sh");

$put=@ARGV;
if($put!=1){
	print "parameter error, should add version num like \"proDeploy.pl 1.0.4\"\n";
	exit -1;
}

print $ARGV[0]."\n";

system("cd `$HOME`");
system("wget https://github.com/JamCode/here/archive/".$ARGV[0].".zip");







