#! /usr/bin/perl

#调用样例 proDeploy.pl 1.0.4
#部署1.0.4版本

print "stop all processes\n";
system("./stopall.sh");
$put=@ARGV;
print $put;




