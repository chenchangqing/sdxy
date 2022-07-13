# 使用shell打包

## 需求

使用shell脚本，导出adhoc/appstore的包，然后上传至appstore/fir/pgy等平台。

## 一、准备adhoc/appstore的证书描述文件

1. 新建iOS Distribution (App Store and Ad Hoc)证书。
2. 新增(Ad Hoc/App Store) Provisioning Profile证书描述文件（该文件会关联App、Distribution证书、iPhone设备）。

## 二、准备导出plist配置文件

在我们手动使用Xcode打包的时候，导出完毕后可以得到对应ExportOptions.plist，直接使用即可。

注意：adhoc的plist请使用adhoc的证书描述文件（AdHocProvisioningProfile）打包，appstore的则使用appstore的证书描述文件（AppStoreProvisioningProfile）打包。

AdHocExportOptions.plist

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>compileBitcode</key>
	<true/>
	<key>method</key>
	<string>ad-hoc</string>
	<key>provisioningProfiles</key>
	<dict>
		<key>com.******.packagewithscript</key>
		<string>AdHocProvisioningProfile</string>
	</dict>
	<key>signingCertificate</key>
	<string>Apple Distribution</string>
	<key>signingStyle</key>
	<string>manual</string>
	<key>stripSwiftSymbols</key>
	<true/>
	<key>teamID</key>
	<string>******</string>
	<key>thinning</key>
	<string>&lt;none&gt;</string>
</dict>
</plist>
```

AppStoreExportOptions

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>compileBitcode</key>
	<true/>
	<key>method</key>
	<string>app-store</string>
	<key>provisioningProfiles</key>
	<dict>
		<key>com.******.packagewithscript</key>
		<string>AppStoreProvisioningProfile</string>
	</dict>
	<key>signingCertificate</key>
	<string>Apple Distribution</string>
	<key>signingStyle</key>
	<string>manual</string>
	<key>stripSwiftSymbols</key>
	<true/>
	<key>teamID</key>
	<string>******</string>
	<key>thinning</key>
	<string>&lt;none&gt;</string>
</dict>
</plist>
```

## 三、配置表格

|证书类型|证书描述文件类型|证书描述文件名称|plist文件|
|:-|:-|:-|:-|
|iOS Distribution (App Store and Ad Hoc)|Ad Hoc|AdHocProvisioningProfile|AdHocExportOptions|
|iOS Distribution (App Store and Ad Hoc)|App Store|AppStoreProvisioningProfile|AppStoreExportOptions|

## 四、xcodebuild和xcrun安装

`xcodebuild`和`xcrun`都是来自`Command Line Tools`，Xcode自带，如果没有可以通过以下命令安装：

```
xcode-select --install
```

或者在下面的链接下载安装：

>https://developer.apple.com/downloads/

安装完可在以下路径看到这两个工具：

>/Applications/Xcode.app/Contents/Developer/usr/bin/

## 五、xcodebuild

[xcodebuild从入门到精通](https://www.hualong.me/2018/03/14/Xcodebuild/)

脚本打包ipa会使用到如下命令：

清理
```
xcodebuild \
clean -configuration ${development_mode} -quiet || rollbackIfNeed '清理失败' 
```

编译
```
xcodebuild \
archive -project ${project_name}.xcodeproj \
-scheme ${scheme_name} \
-configuration ${development_mode} \
-archivePath ${buildPath}/${project_name}.xcarchive -quiet || rollbackIfNeed '编译失败'
```

导出
```
xcodebuild -exportArchive -archivePath ${buildPath}/${project_name}.xcarchive \
-configuration ${development_mode} \
-exportPath ${exportFilePath} \
-exportOptionsPlist ${exportOptionsPlistPath} \
-quiet || rollbackIfNeed '打包失败'
```

## 五、altool

脚本上传ipa至apptore会使用如下命令：

```
# 验证并上传到App Store
# ${exportFilePath}/${scheme_name}.ipa：ipa路径
# ******@126.com: 苹果账号
# ****-****-vlnc-hill：双重认证密码
xcrun altool --validate-app -f ${exportFilePath}/${scheme_name}.ipa -t ios -u ******@126.com -p ****-****-vlnc-hill --output-format xml || rollbackIfNeed 'ipa校验失败'
xcrun altool --upload-app   -f ${exportFilePath}/${scheme_name}.ipa -t ios -u ******@126.com -p ****-****-vlnc-hill --output-format xml || rollbackIfNeed 'ipa上传失败'
```

* [通过 altool 上传 App 的二进制文件](https://help.apple.com/itc/apploader/#/apdATD1E53-D1E1A1303-D1E53A1126)
* [ipa上传](https://help.apple.com/app-store-connect/#/devb1c185036)
* [ipa上传stackflow](https://stackoverflow.com/questions/57976017/how-to-upload-ipa-now-that-application-loader-is-no-longer-included-in-xcode-11)

注：Xcode 11 的 altool 已经被命令 xcrun altool 替代。在终端运行xcrun altool -h可以查看说明。

## 六、fir-cli

[fir-cli安装](https://github.com/FIRHQ/fir-cli/blob/master/README.md)

脚本上传ipa至fir会使用如下命令：
```
# 上传到Fir
# 将******替换成自己的Fir平台的token
fir login -T ****** || rollbackIfNeed '登录fir失败'
fir publish $exportFilePath/$scheme_name.ipa || rollbackIfNeed '发布ipa包至fir失败'
```

## 七、蒲公英

[使用一条命令快速上传应用](https://www.pgyer.com/doc/view/upload_one_command)

脚本上传ipa至fir会使用如下命令：

```
# 上传到蒲公英
# 蒲公英aipKey
MY_PGY_API_K=******
# 蒲公英uKey
MY_PGY_UK=******
curl -F "file=@${exportFilePath}/${scheme_name}.ipa" \
-F "uKey=${MY_PGY_UK}" \
-F "_api_key=${MY_PGY_API_K}" \
https://www.pgyer.com/apiv1/app/upload || rollbackIfNeed '发布ipa包至pgy失败'
```

## 八、完整脚本

[xcodebuild.sh](https://gitee.com/chenchangqing/packagewithscript/blob/master/xcodebuild.sh)

## 九、参考链接

* [蒲公英](https://www.pgyer.com/)
* [fir](https://www.betaqr.com/)
* [While executing gem ... (Gem::FilePermissionError)](https://blog.csdn.net/shenyiyangnb/article/details/80897753)
* [详解Shell脚本实现iOS自动化编译打包提交](https://www.jianshu.com/p/bd4c22952e01)