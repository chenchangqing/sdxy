# 使用jenkins打包

## 安装jenkins

1. 下载war，[下载地址](https://jenkins.io/download)
2. 启动jenkins
	java -jar jenkins.war --httpPort=8080
3. 下载[jdk8](https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html)
4. 请从本地复制密码并粘贴到下面。
	/Users/mengru.tian/.jenkins/secrets/initialAdminPassword
5. 创建第一个管理员用户

## 安装插件

1. 点击Manage Jenkins
2. 选择Manage Plugins
3. 点击Available
4. 安装证书插件
	1. 搜索keychain
	2. 点击“Download now and install after restart”
5. 安装蒲公英插件
	1. 搜索pgyer
	2. 点击“Download now and install after restart”
6. 安装Git Parameter插件

## 证书配置

1. 点击Manage Jenkins
2. 点击Keychains and Provisioning Profiles Management
3. cp ~/Library/Keychains/login.keychain-db /Users/Shared/Jenkins/login.keychain

## 配置构建参数

* [Mac下使用命令行安装 jenkins 方法](https://www.jianshu.com/p/5b5306a32fae)
* [Mac安装jenkins](https://juejin.cn/post/6844904080322756615)
* [利用Jenkins持续集成iOS项目](https://www.jifu.io/posts/388825549/)
* [Jenkins安装与配置](https://www.jianshu.com/p/3a70b83752b5)
* [关于jenkins 自动化打包部署的问题。](https://ask.csdn.net/questions/3198014)
* [iOS Jenkins自动化打包上传到蒲公英](https://www.jianshu.com/p/3fe781e15fd5?utm_campaign=hugo&utm_medium=reader_share&utm_content=note)
* [Git Parameter 插件](http://www.mydlq.club/article/45/)
* [MacOS Jenkins卸载方法](https://www.jianshu.com/p/44f321f67399)
* [Jenkins参数设置单选框、多选框、Git分支框](https://blog.csdn.net/qq_37688023/article/details/105983960)
* [jenkins 构建后shell_如何/何时执行Shell标记一个构建失败在Jenkins？](https://blog.csdn.net/weixin_39820244/article/details/111530546)
* [使用 Jenkins 插件上传应用到蒲公英](https://www.pgyer.com/doc/view/jenkins_plugin)
