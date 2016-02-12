# nginx相关配置

## 安装
>* yum install nginx

## 启动
>* sudo service nginx start

## 停止
>* sudo service nginx stop

## 修改配置后重启
>* nginx -s reload

## 配置

>* vi /etc/nginx/nginx.conf


## 反向代理配置

```
server{
        listen 80;
        server_name wanghan2015.xyz;
        location / {
                proxy_pass http://localhost:10808;
        }
    }
```
