//%attributes = {"invisible":true}
var $buildApp : cs:C1710.BuildApp

/*

instance inherits default build project (if it exists)
otherwise most attributes are empty or null
pass new object to explictly request empty settings

*/

Case of 
	: (Is Windows:C1573)
		$applicationsFolder:=Folder:C1567(fk applications folder:K87:20).parent.folder("Program Files").folder("4D")
	: (Is macOS:C1572)
		$applicationsFolder:=Folder:C1567(fk applications folder:K87:20)
End case 

$version:=Application version:C493($build)
$folderName:="4D v"+Substring:C12($version; 1; 2)+"."+Substring:C12($version; 4; 1)

$buildApp:=cs:C1710.BuildApp.new(New object:C1471)

$buildApp.findLicenses(New collection:C1472("4DDP"; "4UUD"))

$buildApp.settings.BuildApplicationName:="TEST"
$buildApp.settings.BuildApplicationSerialized:=True:C214
$buildApp.settings.BuildMacDestFolder:=Temporary folder:C486+Generate UUID:C1066
$buildApp.settings.SourcesFiles.RuntimeVL.RuntimeVLIncludeIt:=True:C214
$buildApp.settings.SourcesFiles.RuntimeVL.RuntimeVLMacFolder:=$applicationsFolder.folder($folderName).folder("4D Volume Desktop.app").platformPath
$buildApp.settings.SignApplication.MacSignature:=False:C215
$buildApp.settings.SignApplication.AdHocSign:=False:C215

/*

build() creates a temporary project
use save().build() to over-write default 4DSettings

*/

$status:=$buildApp.build()

If ($status.success)
	
	$app:=$buildApp.getPlatformDestinationFolder().folder("Final Application").folder($buildApp.settings.BuildApplicationName+".app")
	
	//continue with SignApp
	
Else 
	$buildApp.openProject("Xcode")
End if 