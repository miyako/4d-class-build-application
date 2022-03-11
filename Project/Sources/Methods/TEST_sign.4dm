//%attributes = {"invisible":true}
$credentials:=New object:C1471
$credentials.username:="keisuke.miyako@4d.com"  //apple ID
$credentials.password:="@keychain:altool"  //app specific password or keychain label; must be literal to use listProviders()
$credentials.keychainProfile:="notarytool"

If (False:C215)
	$plist:=New object:C1471("LSArchitecturePriority"; New collection:C1472("x86_64"; "arm64"))
	$signApp:=cs:C1710.SignApp.new($credentials; $plist)
Else 
	$signApp:=cs:C1710.SignApp.new($credentials)
End if 

$version:=Application version:C493($build)
$folderName:="4D v"+Substring:C12($version; 1; 2)+"."+Substring:C12($version; 4; 1)
$folderName:="4D v19.2"

$applicationsFolder:=Folder:C1567(fk applications folder:K87:20)
$app:=$applicationsFolder.folder($folderName).folder("4D.app")
//$app:=$applicationsFolder.folder($folderName).folder("4D Server.app")

$statuses:=$signApp.sign($app)

$status:=$signApp.archive($app)

If ($status.success)
	$status:=$signApp.notarize($status.file)
End if 