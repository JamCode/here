# 后台部署流程




## 获取zip包

* cd $HOME
* wget zip链接


## 停止应用

* stophere

## 老版本应用改名here_old
## 新版本解压缩
* unzip 新版本zip文件
* 新版本重命名为here

## 执行数据库升级
* sql文件夹中对应版本号的文件，执行其中的sql脚本

## 执行应用脚本

## 重启后台应用
* starthere
