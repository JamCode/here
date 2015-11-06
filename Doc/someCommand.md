# 一些命令

## 解压缩
tar –xvf file.tar //解压 tar包

## 80端口转发

适用于普通用户无法使用80端口的程序

添加转发规则
>* sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8090

查看当前转发规则
>* sudo iptables --line-numbers --list PREROUTING -t nat

删除转发规则
>* sudo iptables -t nat -D PREROUTING num
