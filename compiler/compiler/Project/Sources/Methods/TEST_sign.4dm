//%attributes = {"invisible":true}
$credentials:=New object:C1471
$credentials.username:="keisuke.miyako@4d.com"  //apple ID
$credentials.password:="@keychain:altool"  //app specific password or keychain label; must be literal to use listProviders()
//$credentials.ascProvider:="keisukemiyako105773250"  //long name or short name, optional

$signApp:=cs:C1710.SignApp.new($credentials)

If (False:C215)
	$Xcode:=$signApp.getXcodePath()
	$signApp.setXcodePath()
	$providers:=$signApp.listProviders()
End if 

$app:=Folder:C1567("Macintosh HD:Applications:4D v18.5:271605:4D.app"; fk platform path:K87:2)

$statusus:=$signApp.sign($app)

//$signApp.archiveFormat:=".zip"
$signApp.archiveFormat:=".dmg"
//$signApp.archiveFormat:=".pkg"

$status:=$signApp.archive($app)

If ($status.success)
	$status:=$signApp.notarize($status.file)
End if 