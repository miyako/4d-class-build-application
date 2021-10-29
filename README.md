![version](https://img.shields.io/badge/version-19%2B-4371C6)
[![license](https://img.shields.io/github/license/miyako/4d-class-build-application
)](LICENSE)

# 4d-class-build-application
Classes to build, sign, archive, notarise and staple an app.

* [BuildApp](https://github.com/miyako/4d-class-build-application/blob/main/compiler/compiler/Documentation/Classes/BuildApp.md)
* [SignApp](https://github.com/miyako/4d-class-build-application/blob/main/compiler/compiler/Documentation/Classes/SignApp.md)

The project itself is a generic compiler application. See [On Startup](https://github.com/miyako/4d-class-build-application/blob/main/compiler/compiler/Project/Sources/DatabaseMethods/onStartup.4dm). The project accepts JSON user parameters in base64 encoded format. See last part of [TEST_build](https://github.com/miyako/4d-class-build-application/blob/main/compiler/compiler/Project/Sources/Methods/TEST_build.4dm).

## Build Application

```4d
var $buildApp : cs.BuildApp

$buildApp:=cs.BuildApp.new(New object)

$buildApp.settings.BuildApplicationName:="TEST"
$buildApp.settings.BuildApplicationSerialized:=True
$buildApp.settings.BuildMacDestFolder:=Temporary folder+Generate UUID
$buildApp.settings.SourcesFiles.RuntimeVL.RuntimeVLIncludeIt:=True
$buildApp.settings.SourcesFiles.RuntimeVL.RuntimeVLMacFolder:=System folder(Applications or program files)+"4D v19 R3"+Folder separator+"4D Volume Desktop.app"
$buildApp.settings.SignApplication.MacSignature:=False
$buildApp.settings.SignApplication.AdHocSign:=False

$buildApp.settings.Licenses.ArrayLicenseMac.Item.push(Get 4D folder(Licenses folder)+"R-4UUD190UUS001XXXXXXXXXX.license4D")
$buildApp.settings.Licenses.ArrayLicenseMac.Item.push(Get 4D folder(Licenses folder)+"R-4DDP190UUS001XXXXXXXXXX.license4D")

$status:=$buildApp.build()
```

## Sign, Archive, Notarise, Staple Application

```4d
var $signApp : cs.SignApp

$credentials:=New object
$credentials.username:="keisuke.miyako@4d.com"  //apple ID
$credentials.password:="@keychain:altool"  //app specific password or keychain label; must be literal to use listProviders()

$signApp:=cs.SignApp.new($credentials)

$buildApp.build()

$app:=$buildApp.getPlatformDestinationFolder().folder("Final Application").folder($buildApp.settings.BuildApplicationName+".app")

$statusus:=$signApp.sign($app)

$status:=$signApp.archive($app)

If ($status.success)
	$status:=$signApp.notarize($status.file)
End if 
```
