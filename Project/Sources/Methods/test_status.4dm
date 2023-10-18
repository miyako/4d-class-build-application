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

$signApp:=cs:C1710.SignApp.new($credentials)
$status:=$signApp.notarizationInfo("{notarisation id}")