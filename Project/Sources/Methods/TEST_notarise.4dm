//%attributes = {}
$credentials:=New object:C1471
$credentials.signingIdentity:="Developer ID Application: {name} ({team id})"  //your apple certificate

If (True:C214)  //if you used `xcrun notarytool store-credentials` to store apple-id, team-id, password in keychain
	$credentials.keychainProfile:="notarytool"
Else   //otherwise
	$credentials.username:="{apple id}"
	$credentials.teamId:="{team id}"
	$credentials.password:="{app specific password}"  //https://support.apple.com/en-us/HT204397
End if 

If (False:C215)  //e.g. to prioritise Intel（https://4d-jp.github.io/2021/07/01/build-universal-binary/）
	$plist:=New object:C1471("LSArchitecturePriority"; New collection:C1472("x86_64"; "arm64"))
	$signApp:=cs:C1710.SignApp.new($credentials; $plist)
Else 
	$signApp:=cs:C1710.SignApp.new($credentials)
End if 

$app:=Folder:C1567("{drop app here}"; fk platform path:K87:2)

$statuses:=$signApp.sign($app)

$status:=$signApp.archive($app; ".dmg")

If ($status.success)
	$status:=$signApp.notarize($status.file)
End if 