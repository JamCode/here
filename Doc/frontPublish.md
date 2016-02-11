# 前端发布流程
----

>* 修改Info.plist中Bundle identifier为com.wanghan.herePro
>* 修改InfoPlist.strings中的app名字
>* 修改TARGETS中版本号
>* 修改TARGETS中Bundle Identifier
>* product ->scheme->edit scheme 中，build configuration修改
为release模式(很重要，不然app会连接到debug环境)
>* archive 打包，提交AppStore审核
