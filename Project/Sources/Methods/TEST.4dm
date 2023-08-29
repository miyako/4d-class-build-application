//%attributes = {}
$credentials:=New object:C1471
$credentials.signingIdentity:="Developer ID Application: {氏名または事業者名} ({チームID})"  //証明書

If (True:C214)  //xcrun notarytool store-credentialsでapple-id,team-id,passwordをキーチェーンに保存されている場合 
	$credentials.keychainProfile:="notarytool"
Else   //そうでない場合
	$credentials.username:="{AppleID}"
	$credentials.teamId:="{チームID}"
	$credentials.password:="{アプリ用パスワード}"  //https://support.apple.com/en-us/HT204397
End if 

If (False:C215)  //Intelを優先する場合（https://4d-jp.github.io/2021/07/01/build-universal-binary/）
	$plist:=New object:C1471("LSArchitecturePriority"; New collection:C1472("x86_64"; "arm64"))
	$signApp:=cs:C1710.SignApp.new($credentials; $plist)
Else 
	$signApp:=cs:C1710.SignApp.new($credentials)
End if 

$app:=Folder:C1567("ここにappをドロップ"; fk platform path:K87:2)

$statuses:=$signApp.sign($app)

$status:=$signApp.archive($app; ".dmg")

If ($status.success)
	$status:=$signApp.notarize($status.file)
End if 