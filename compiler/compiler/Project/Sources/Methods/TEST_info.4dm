//%attributes = {"invisible":true}
$credentials:=New object:C1471
$credentials.username:="keisuke.miyako@4d.com"  //apple ID
$credentials.password:="@keychain:altool"  //app specific password or keychain label; must be literal to use listProviders()
$credentials.ascProvider:="keisukemiyako105773250"  //long name or short name, optional

$signApp:=cs:C1710.SignApp.new($credentials)
$status:=$signApp.notarizationInfo("f410db87-3bf4-4345-96dc-f02eb86df987")

If ($status.success) & ($status.LogFileURL#Null:C1517)
	OPEN URL:C673($status.LogFileURL; *)
End if 