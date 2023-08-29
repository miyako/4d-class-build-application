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

$signApp:=cs:C1710.SignApp.new($credentials)
$status:=$signApp.notarizationInfo("{公証の受付ID}")

If ($status.success) & ($status.LogFileURL#Null:C1517)
	OPEN URL:C673($status.LogFileURL; *)
End if 