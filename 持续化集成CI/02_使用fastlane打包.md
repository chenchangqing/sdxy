# 使用fastlane打包

## fastlane理解

之前写了一篇[使用shell打包](01_使用shell打包.md)的文章，从这篇文章打包是可以通过编写shell脚本完成，那么为什么还需要fastlane呢？

> 1. fastlane可以通过一个简单的通过简单命令来完成诸如截图、获取证书、编译、导出安装包，而不需要去关心如何去写大量的打包脚本。
> 2. fastlane可以定义多个任务，例如：打包到不同渠道包时，我们可以定义多个任务，只需要一行简单命令。
> 3. fastlane打包直接就包含了dsym等文件，而使用脚本还得自己去实现。

## fastlane安装及配置

fastlane安装
```ruby
sudo gem install fastlane -n /usr/local/bin
```

fastlane升级
```ruby 
bundle update fastlane
```

fastlane配置
```ruby
cd 项目目录
fastlane init
```

执行以上命令，项目目录下会生成相应的Appfile、Fastfile。

[执行`fastlane init`,`bundle update`卡住了](https://www.jianshu.com/p/7f9c7168eb5e)

## Appfile

Appfile是用来配置一些类似于AppleID、BundleID参数(参数是fastlane已经定义好的，新增的并没有用，如果想新增变量需要使用.env方式)，可以在Fastfile中使用，AppleID、BundleID等其实会被一些actions直接调用，并不需要写出来传递。

### 普通配置方式

直接在Appfile里填写app_identifier、apple_id、team_id等，然后根据lane的不同可以设置成不同。

```ruby
# 默认配置
app_identifier    "com.devhy.test"
apple_id    "devhy1@xxxx.com"
team_id    "xxxxxxxxx1"

# 如果lane是ent换成Dev的配置
for_lane :ent do
  app_identifier    "com.devhy.testDev"
  apple_id    "devhy2@xxxx.com"
  team_id    "xxxxxxxxx2"
end
```

### 使用.env配置方式

`.env`这个文件的作用是作为环境变量的配置文件，在`fastlane init`进行初始化后并不会自动生成，如果需要可以自己创建。

执行时默认会读取`.env`和`.env.default`文件里的配置。通过执行`fastlane [lane-name] --env [envName]`来指定使用配置文件`.env.[envName]`，读取顺序是.env -> .env.default -> .env.<envName>，相同的变量名会被后面的覆盖。

如我建了文件`.env.myDev`，里面写了一些参数，那在执行的时候使用`fastlane [lane-name] --env myDev`即可，想在`Appfile`、`Deliverfile`、`Fastfile`等调用，直接使用`ENV['keyName']`即可。

```ruby
# .env.myDev文件
# bundle id
App_Identifier = "com.devhy.testDev"
# 开发者账号
Apple_Id = "xx2@xxxx.com"
# 开发者TeamId
Team_Id  = "xxxxxxxxx2"
# project的target scheme名称
Scheme   = "HYTestDev"
```

```ruby
# Appfile使用.env方式直接读取变量即可
app_identifier	 ENV['App_Identifier']
apple_id 		 ENV['Apple_Id']
team_id			 ENV['Team_Id']
```

注意：因为是.env文件是.开头文件，默认是在finder中隐藏的，需要通过执行一下命令来显示：

```ruby
# 设置隐藏文件可见
defaults write com.apple.finder AppleShowAllFiles TRUE
# 重启finder服务以生效
killall Finder
```

### 配置方式对比

普通配置方式：简单易懂，但不能自定义变量，且每个lane想不一样都要写一个for_lane .env配置方式：功能性强，但配置起来稍微麻烦一点。

## Deliverfile

Deliverfile是用来配置上传到iTunesConnect所需信息的，由于我们主要用fastlane来打包，发布是手动将ipa包提交审核，由于没有进行过尝试所以该文件配置方式就不叙述了。

## Fastfile

Fastfile是对流程进行控制的核心文件，需要设定支持的平台和在一些环节里需要做的事情。

### 基本结构

Fastfile主要是根据设定的平台，可以在before_all、after_all、error中做一些操作以及建立一些lane作为关键的执行逻辑，可以在其中使用fastlane内置的action，也可以调用自建action，还可以调用别的lane。

```ruby
# 因为fastlane存在新老版本兼容问题，所以一般会指定fastlane版本
fastlane_version "2.62.0"
default_platform :ios

platform :ios do
  # 所有lane执行之前，可以做如执行cocoapods的pod install
  before_all do
    cocoapods
  end
  
  # 名字叫ent的lane，命令行里执行fastlane ent
  lane :ent do
    # 执行一些action，如cert下载证书，sigh下载pp文件，gym进行编译和导出包
  end

  # 执行fastlane store即可
  lane :store do
    # 调用一些action
    
    # 调用别的lane，比如send_msg
    send_msg
  end
  
  lane :send_msg do
    # 调用一些action
  end
  
  # 所有lane完成之后，可以适用参数lane来区分
  after_all do |lane|
  end
	
  # 所有lane失败之后，可以适用参数lane来区分
  error do |lane, exception|
  end
end
```

### Fastfile样例

下面的Fastfile样例是配置了.env+Appfile后进行编写，因为这样在配置action时，可以省去一些入参。
因为使用了Appfile，cert的username、team_id 以及 sigh的app_identifier、username、team_id 可以不用传入了，fastlane在执行时会自己去从Appfile里取。以及之前在.env环境配置中设定了一个Scheme的字段，那么gym的scheme我们可以使用ENV['Scheme']来调用。

```ruby
fastlane_version "2.62.0"
default_platform :ios

platform :ios do

  before_all do
    cocoapods
  end

  lane :store do
    # action(cert)，下载[开发者证书.cer]
    # 下载的文件会存在项目根目录的build文件夹下
    # fastlane会让你在命令行登录开发者账号，登录成功后，会在你的[钥匙串]中创建一个 {deliver.[username]} 的登录账户
    cert(
      # Appfile设置了这边就可以不用了
      # username: "devhy2@xxxx.com",
      # team_id: "xxxxxxxxx2",
      
      # 下载.cer文件的位置
      output_path: "build",
    )

    # action(sigh)，下载[安装app匹配的Provision Profile文件(pp文件)]
    # 建议自己去苹果开发者网站证书中手动处理一波provision_profile
    # 建议用 bundleId_导出方式 来命名比如: 
    #     企业包pp文件叫 testDev_InHouse.mobileprovision
    sigh(
      # Appfile设置了这边就可以不用了
      # app_identifier: "com.devhy.testDev",
      # username: "devhy2@xxxx.com",
      # team_id: "xxxxxxxxx2",

      # 下载pp文件的位置
      output_path: "build",
      # 自动下载签名时，adc里pp名字，不写也可以会根据你的bundle id、adhoc与否去下载最新的一个
      # provisioning_name: "testDev_InHouse", 
      # 仅下载不创建，默认是false
      readonly: true, 
      # 因为是根据BundleID下载，导致adhoc和appstore会优先appstore，导致最后导出报错，如果是adhoc包请设置为true
      adhoc: true, 
    )

    # 编译配置，编译的scheme，导出包方式
    gym(
      # 使用.env配置的环境变量
      scheme: ENV['Scheme'],
      # app-store, ad-hoc, package, enterprise, development, developer-id
      export_method: "enterprise", 
      # 输出日志的目录
      buildlog_path: "fastlanelog",
      # 输出编译结果
      output_directory: "build",
      include_bitcode: false
    )
  end
  
  after_all do |lane|
  end

  error do |lane, exception|
  end
end
```

### actions

在fastlane中使用的诸如cer()、sigh()、gym()都是action，其本质是预先写好的ruby脚本(如:sigh.rb)，fastlane中有很多已经写好的actions，当然也可以自己进行编写。

命令行常用的操作有：
	1. 查看所有Action fastlane actions
	2. 查看某个Action的参数说明 fastlane action [action_name]如(fastlane action gym)

### 版本自增及指定

```ruby
# 版本处理
def setup_version_build(options)
  if "#{options[:build]}".empty?
    increment_build_number(
      xcodeproj: ENV['Xcodeproj']
    )
  else
    increment_build_number(
      xcodeproj: ENV['Xcodeproj'],
      build_number:options[:build]
    )
  end

  unless "#{options[:version]}".empty?
    increment_version_number(
      xcodeproj: ENV['Xcodeproj'],
      version_number:options[:version]
    )
  end
end
```

### 使用fastlane上传App到蒲公英

https://www.pgyer.com/doc/view/fastlane

### 使用fastlane上传App到蒲公英

[fastlane-plugin-firim](https://github.com/whlsxl/firim/tree/master/fastlane-plugin-firim)

### Fastlane && AppStore Connect API

[Fastlane && AppStore Connect API](https://www.jianshu.com/p/19c8fe142c46)

### 配置后的使用

编写完各种配置后怎么使用？其实使用方法还是比较简单的，不使用.env配置，执行fastlane [lane_name]即可。

使用某个.env配置，执行fastlane [lane_name] --env [env_name]即可
，比如我在需要执行样例的Fastfile的store，并使用.env.myDev配置，那我可以执行fastlane store --env myDev。

## 完整脚本

[Fastfile](https://gitee.com/chenchangqing/packagewithfastlane/blob/master/fastlane/Fastfile)

## 参考链接

* [macOS Mojave 'ruby/config.h' file not found](https://stackoverflow.com/questions/53135863/macos-mojave-ruby-config-h-file-not-found)
* [和重复劳动说再见-使用fastlane进行iOS打包](https://juejin.cn/post/6844903561696903176)
* [iOS开发热门-自动打包fastlane](https://www.jianshu.com/p/1bf4d84f0d4f)
* [fastlane文档](https://docs.fastlane.tools/getting-started/ios/setup/)
* [Mac 下 fastlane 安装 以及常见错误处理](https://www.cnblogs.com/lesten/p/11735610.html)
* [Automating Version and Build Numbers Using agvtool](https://developer.apple.com/library/archive/qa/qa1827/_index.html)
* [iOS自动打包](https://www.jianshu.com/p/56b6e26019c3)
* [fastlane 在mac上配置iOS自动化上架](https://www.jianshu.com/p/48343a655f75)
* [deliver](https://docs.fastlane.tools/actions/deliver/)
* [使用fastlane deliver 自动上传App Store Connect 物料和截图](https://blog.csdn.net/ArthurChenJS/article/details/104728490)
* [itunesconnect](https://itunesconnect.apple.com/)
* [fastlane官网](https://fastlane.tools)