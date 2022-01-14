//%attributes = {"invisible":true}
SHOW ON DISK:C922(Temporary folder:C486)

$credentials:=New object:C1471
$credentials.username:="keisuke.miyako@4d.com"  //apple ID
$credentials.password:="@keychain:altool"  //app specific password or keychain label; must be literal to use listProviders()
$credentials.ascProvider:="keisukemiyako105773250"  //long name or short name, optional

$signApp:=cs:C1710.SignApp.new($credentials)
$status:=$signApp.notarizationInfo("9b6c3378-9d93-4040-85fb-794894072075")

If ($status.success) & ($status.LogFileURL#Null:C1517)
	OPEN URL:C673($status.LogFileURL; *)
End if 