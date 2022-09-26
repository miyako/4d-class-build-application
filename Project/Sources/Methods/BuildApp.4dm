//%attributes = {"invisible":true,"shared":true}
#DECLARE($settingsFile : Object)->$buildApp : cs:C1710.BuildApp

If (Count parameters:C259=0)
	$buildApp:=cs:C1710.BuildApp.new()
Else 
	$buildApp:=cs:C1710.BuildApp.new($settingsFile)
End if 