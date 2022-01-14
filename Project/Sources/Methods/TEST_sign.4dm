//%attributes = {"invisible":true}
$credentials:=New object:C1471
$credentials.username:="keisuke.miyako@4d.com"  //apple ID
$credentials.password:="@keychain:altool"  //app specific password or keychain label; must be literal to use listProviders()

$signApp:=cs:C1710.SignApp.new($credentials)

$app:=Folder:C1567("Macintosh HD:Users:miyako:Desktop:Final Application:TEST.app:"; fk platform path:K87:2)

$statuses:=$signApp.sign($app)

$status:=$signApp.archive($app)

If ($status.success)
	$status:=$signApp.notarize($status.file)
End if 