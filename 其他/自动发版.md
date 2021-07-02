```ruby

```

命令行输入
`gem which cocoapods`
会得到类似
`/Users/user/.rvm/rubies/ruby-2.6.3/lib/ruby/gems/2.6.0/gems/cocoapods-1.9.3/lib/cocoapods.rb`

前往文件夹（command+shift+g）

会看到一个

- `cocoapods`文件夹
- `cocoapods.rb`文件

进入`cocoapods`文件夹，找到文件`validator.rb`拷贝出来一份作为备份。再拷贝一份进行修改如下：

```ruby
搜索： when 找到如下代码

      when :ios
              command += %w(CODE_SIGN_IDENTITY=- -sdk iphonesimulator)
              command += Fourflusher::SimControl.new.destination(:oldest, 'iOS', deployment_target)
              xcconfig = consumer.pod_target_xcconfig
              if xcconfig
                archs = xcconfig['VALID_ARCHS']
                if archs && (archs.include? 'armv7') && !(archs.include? 'i386') && (archs.include? 'x86_64')
                  # Prevent Xcodebuild from testing the non-existent i386 simulator if armv7 is specified without i386
                  command += %w(ARCHS=x86_64)
                end
              end
      when :watchos

修改为：
      when :ios
#        command += %w(CODE_SIGN_IDENTITY=- -sdk iphonesimulator)
#        command += Fourflusher::SimControl.new.destination(:oldest, 'iOS', deployment_target)
#        xcconfig = consumer.pod_target_xcconfig
#        if xcconfig
#          archs = xcconfig['VALID_ARCHS']
#          if archs && (archs.include? 'armv7') && !(archs.include? 'i386') && (archs.include? 'x86_64')
#            # Prevent Xcodebuild from testing the non-existent i386 simulator if armv7 is specified without i386
#            command += %w(ARCHS=x86_64)
#          end
#        end
        command += %w(--help)
      when :watchos
```

意思就是， 注释掉这部分代码，用一个help命令代替。

然后替换原`validator.rb`文件即可。

参考链接：

https://www.jianshu.com/p/88180b4d2ab7