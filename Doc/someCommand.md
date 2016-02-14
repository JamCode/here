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

## 统计系统文件大小

统计文件系统可用空间
>* df -h

统计文件夹使用空间
>* du -m --max-depth=1|sort -rn

## pod 更新
pod install --verbose --no-repo-update
pod update --verbose --no-repo-update


## cul测试

post包测试

>* curl -d "user_id=xxx&user_name=xxxx" "http://112.74.102.178:8080/api"


## 抓包测试
>* sudo tcpdump -X -s 0 'tcp port 10666 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'


## openssl证书生成

>* 生成服务器端的非对称秘钥
openssl genrsa -des3 -out server.key 1024

>* 生成签名请求的CSR文件
openssl req -new -key server.key -out server.csr

>* 自己对证书进行签名，签名的有效期是365天
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

>* 去除证书文件的password
cp server.key server.key.orig
openssl rsa -in server.key.orig -out server.key



## 苹果推送pem生成

准备三个文件
>* 认证签名申请文件（CSR）
>* 私钥文件（PushChatKey.p12）
>* SSL证书文件（aps_developer_identity.cer）

生成pem
```
openssl x509 -in aps_developer_identity.cer -inform der -out PushChatCert.pem
openssl pkcs12 -nocerts -out PushChatKey.pem -in PushChatKey.p12

```

验证
```
telnet gateway.sandbox.push.apple.com 2195
```

```
openssl s_client -connect gateway.sandbox.push.apple.com:2195-cert PushChatCert.pem -key PushChatKey.pem
```
