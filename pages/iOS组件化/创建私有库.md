### 创建私有库

#### 一、创建存放podsepc的私有仓库

在自己的git服务器中创建一个保存podspec的仓库：[repo name]。

创建完仓库之后获取仓库地址 在terminal中执行pod的指令将仓库添加到本地的pod repo中。

`pod repo add [repo name] [url]`

添加完成之后，在~/.cocoapods/repos中就可以看到名称为[repo name]的文件夹，这就是我们的私有pod仓库。

当然也可以使用`pod repo remove [repo name]`移除repo。

#### 二、创建存放源码的仓库并推送到私有仓库

在git服务器上再创建一个仓库用于存放源代码。

在terminal中执行`pod lib create [lib name]`创建一个cocoapods的demo工程。

执行之后会从git克隆一个模板，并会问几个问题，依次按照需求选择即可，完成之后会打开一个Xcode project。

#### 三、编辑podspec文件

```ruby
Pod::Spec.new do |s|
  s.name             = '名字'
  s.version          = '版本号 需要和git tag保持一致'
  s.summary          = '简述'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: 描述
                       DESC

  s.homepage         = '主页 最好保证可以访问'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'changqing.chen' => 'chenchangqing198@126.com' }
  s.source           = { :git => 'git仓库地址', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'utlogin/Classes/**/*'
  
  # s.resource_bundles = {
  #   'utlogin' => ['utlogin/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

```

#### 四、校验podspec文件

编辑完成之后，使用`pod lib lint`来验证podspec填写的准确性，可以选择参数:

* `--verbose`查看整个过程
* `--allow-warnings`允许一些警告通过验证，如果验证出错，而`project build success`可以尝试添加这个参数
* `--source`如果依赖的库是一个私有仓库创建的库，可以使用这个参数指定私有仓库的podspec仓库，除此之外最好将cocoapods公有库的source也指定一下

指定source
```ruby
pod lib lint --sources='[私有podsepec仓库地址],https://github.com/CocoaPods/Specs' --verbose --allow-warnings --no-clean
```

不指定source
```ruby
pod lib lint --verbose --allow-warnings --no-clean
```

执行问`pod lib lint`，看到`[lib name] passed validation`后就算通过校验。


#### 五、推送至私有仓库

编辑.gitignore，将`# Pods/`修改为`Pods/`，忽略Pods文件夹，第三方代码就不会上传。

通过验证后，将源码推送至git仓库：
```
git init
git add .
git commit -am 'desc'
git remote add origin 'url'
git push origin master
git tag 'tag'
git push --tags
```

将podsepc添加到私有repo中使用命令：
```
pod repo push [repo name] [name.podspec] --verbose --allow-warnings
```

