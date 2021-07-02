# 1.常用工具

## Alfred 3.2 Mac破解版

[安装地址](http://www.sdifen.com/alfred32.html)

[“XXX.app 已损坏，打不开。您应该将它移到废纸篓”，Mac应用程序无法打开或文件损坏的处理方法](https://blog.csdn.net/yjk13703623757/article/details/108557804)

[5分钟上手Mac效率神器Alfred以及Alfred常用操作](https://www.jianshu.com/p/e9f3352c785f)

[Setting the Terminal/Shell to "Custom" (iTerm).](https://www.alfredforum.com/topic/11050-setting-the-terminalshell-to-custom-iterm/)

## Mac OS 终端利器 iTerm2

[安装教程](https://www.cnblogs.com/xishuai/p/mac-iterm2.html)

[How do I hide the “user@hostname” info #39](https://github.com/agnoster/agnoster-zsh-theme/issues/39)

[MAC TERMINAL终端或ITERM2出现问号解决方案](https://www.freesion.com/article/50691354899/)

[git - 警告:不建议使用此脚本，请参阅git-completion.zsh](https://www.coder.work/article/189388)

## SwitchHosts

[安装地址](https://github.com/oldj/SwitchHosts/tags)

[如何解决类似 curl: (7) Failed to connect to raw.githubusercontent.com port 443: Connection refused 的问题 #10](https://github.com/hawtim/blog/issues/10)

## OpenInTerminal

[安装教程](https://github.com/Ji4n1ng/OpenInTerminal/blob/master/Resources/README-Lite-zh.md)

## ios-app-signer

[下载地址](https://github.com/DanTheMan827/ios-app-signer/releases/tag/1.13.1)

## idapro

[IDA Pro 7.0.zip（MAC版本，下载下来可直接打开即可，在10.15.4测试通过）](https://download.csdn.net/download/weixin_43833642/12509408?utm_medium=distribute.pc_relevant.none-task-download-2~default~BlogCommendFromMachineLearnPai2~default-1.control)

[IDA Pro Mac版 V7.0-pc6](http://www.pc6.com/mac/566964.html)

[IDA Pro 7.0 for Mac(静态反编译软件) v7.0.170914中文版](http://blog.itpub.net/69956273/viewspace-2669928/)

[IDA Pro 7.0 macOS 10.15安装](https://blog.csdn.net/weixin_43833642/article/details/106664102)


## cycript

[安装Cycript报错找不到libruby.2.0.0.dylib](https://blog.csdn.net/youshaoduo/article/details/86649789)

[安装cycript遇到的问题](https://blog.csdn.net/ZCMUCZX/article/details/79978719?utm_medium=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7EBlogCommendFromMachineLearnPai2%7Edefault-1.control&dist_request_id=1619543602701_52270&depth_1-utm_source=distribute.pc_relevant_t0.none-task-blog-2%7Edefault%7EBlogCommendFromMachineLearnPai2%7Edefault-1.control)

[iOS 逆向必备工具和安装过程](https://www.jianshu.com/p/9aaa1c9dfcc4)

```
csrutil disable

sudo mkdir -p /System/Library/Frameworks/Ruby.framework/Versions/2.0/usr/lib/

sudo ln -s /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/libruby.2.6.dylib /System/Library/Frameworks/Ruby.framework/Versions/2.0/usr/lib/libruby.2.0.0.dylib
```

[mac下安装ruby2.2.0](https://www.jianshu.com/p/34148386e290)

[MacOS 下安装 Ruby](https://liangbogopher.github.io/2018/04/15/mac-upgrade-ruby)

pod update报错：
```
Traceback (most recent call last):
	2: from /usr/local/bin/pod:23:in `<main>'
	1: from /Library/Ruby/Site/2.6.0/rubygems.rb:296:in `activate_bin_path'
```

使用如下命令解决，[参考链接](https://blog.csdn.net/wujakf/article/details/100112821)：
```
sudo gem install cocoapods 
```