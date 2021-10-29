//%attributes = {"invisible":true}
var $buildApp : cs:C1710.BuildApp

/*

instance inherits default build project (if it exists)
otherwise most attributes are empty or null
pass new object to explictly request empty settings

*/

$buildApp:=cs:C1710.BuildApp.new(New object:C1471)

$buildApp.settings.BuildApplicationName:="TEST"
$buildApp.settings.BuildApplicationSerialized:=True:C214
$buildApp.settings.BuildMacDestFolder:=Temporary folder:C486+Generate UUID:C1066
$buildApp.settings.SourcesFiles.RuntimeVL.RuntimeVLIncludeIt:=True:C214
$buildApp.settings.SourcesFiles.RuntimeVL.RuntimeVLMacFolder:=System folder:C487(Applications or program files:K41:17)+"4D v19 R3"+Folder separator:K24:12+"4D Volume Desktop.app"
$buildApp.settings.SignApplication.MacSignature:=False:C215
$buildApp.settings.SignApplication.AdHocSign:=False:C215

Case of 
	: (Is macOS:C1572)
		
/*
		
TODO:
		
scan licenses folder
		
*/
		
		$buildApp.settings.Licenses.ArrayLicenseMac.Item.push(Get 4D folder:C485(Licenses folder:K5:11)+"R-4UUD190UUS001XXXXXXXXXX.license4D")
		$buildApp.settings.Licenses.ArrayLicenseMac.Item.push(Get 4D folder:C485(Licenses folder:K5:11)+"R-4DDP190UUS001XXXXXXXXXX.license4D")
		
End case 

/*

build() creates a temporary project
use save().build() to over-write default 4DSettings

*/

$status:=$buildApp.build()

If ($status.success)
	
	$app:=$buildApp.getPlatformDestinationFolder().folder("Final Application").folder($buildApp.settings.BuildApplicationName+".app")
	
	$app:=cs:C1710.App.new($app)
	
	$project:=File:C1566(Get 4D folder:C485(Database folder:K5:14)+\
		"Projects"+Folder separator:K24:12+\
		"stub"+Folder separator:K24:12+"Project"+Folder separator:K24:12+\
		"stub.4DProject"; fk platform path:K87:2)
	
	$userParams:=New object:C1471
	
	$userParams.project:=$project.path
	$userParams.options:=New object:C1471
	$userParams.options.targets:=New collection:C1472("x86_64_generic"; "arm64_macOS_lib")
	$userParams.options.typeInference:="locals"
	$userParams.options.defaultTypeForNumeric:=Is real:K8:4
	$userParams.options.defaultTypeForButtons:=Is longint:K8:6
	$userParams.options.generateSymbols:=True:C214
	$userParams.options.generateTypingMethods:="reset"
	$userParams.options.components:=New collection:C1472
	
	$userParam:=$app.encodeObject($userParams)
	
	$status:=$app.open(New collection:C1472("--headless"; "--dataless"; "--user-param"; $userParam))
	
Else 
	$buildApp.openProject("Xcode")
End if 