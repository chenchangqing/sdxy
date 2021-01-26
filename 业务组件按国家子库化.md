# 业务组件按国家子库化

如何解决多个国家并行开发？

## 一、解决方案

方案一：不同国家不同分支
>一个国家对应一个分支，对应国家的宿主工程依赖国家分支。

方案二：多个国家多个子库
>按国家新建不同的子库，并且新建不同国家的target分别依赖子库。

对比两个方案，个人倾向方案二
>方案一修改代码比较麻烦，不利于代码复用。

## 二、新建子库

下面以GWHModuleHome为例：

### 2.1 整理项目文件夹，按国家划分

1. 在Classes下分别新建Core/Thailand/Russia文件夹。
2. 将Classes原来所有文件及文件夹放入Core
3. Thailand和Russia随便放一个swift文件，为了pod install可以显示这两个子库。

### 2.2 修改GWHModuleHome.podspec

1. 设置默认子库Core。
2. 新建Core/Thailand/Russia子库，源文件及资源文件路径一定要正确。
3. 执行pod install，这样就完成子库新建。

```ruby
Pod::Spec.new do |s|
	.....
	s.default_subspec = 'Core'

	s.subspec 'Core' do |ss|
		ss.source_files = 'GWHModuleHome/Classes/Core/**/*'
	  	ss.resource_bundles = {
	    	'GWHModuleHome' => [
	        	'GWHModuleHome/Assets/**/{*}',
	        	'GWHModuleHome/Classes/**/{*.storyboard,*.xib}'
	    	]
	  	}
	  
	  	ss.dependency 'GWHModuleMine'
	  	ss.dependency 'GWNetWork'
	  	ss.dependency 'GWCommonComponent'
	  	ss.dependency 'GWUserCenterBase'
	  	ss.dependency 'Aquaman'
	  	ss.dependency 'Trident'
	end

	s.subspec 'Russia' do |ss|
	 	ss.source_files = 'GWHModuleHome/Classes/Russia/**/*'
	  	ss.dependency 'GWHModuleHome/Core'
	end

	s.subspec 'Thailand' do |ss|
	  	ss.source_files = 'GWHModuleHome/Classes/Thailand/**/*'
	  	ss.dependency 'GWHModuleHome/Core'
	end
end
```

## 三、新建target

分别参考下面的链接：

* [Xcode 一个项目下创建多个Target](https://blog.csdn.net/ioszhanghui/article/details/90716642)
* [配置多个target及多个Target的podfile文件配置](https://www.jianshu.com/p/660769284826)
* [Xcode中Active Compilation Conditions和Preprocessor Macros的区别](https://www.crifan.com/xcode_active_compilation_conditions_vs_preprocessor_macros/)


