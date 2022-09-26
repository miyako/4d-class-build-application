//%attributes = {"invisible":true,"shared":true}
#DECLARE($credentials : Object; $options : Object)->$signApp : cs:C1710.SignApp

var $plist : Object

If ($options=Null:C1517)
	$plist:=New object:C1471
Else 
	$plist:=$options
End if 

$signApp:=cs:C1710.SignApp.new($credentials; $plist)