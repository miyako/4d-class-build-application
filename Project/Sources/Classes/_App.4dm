Class constructor
	
Function escape_param($escape_param : Text)->$param : Text
	
	$param:=$escape_param
	
	$metacharacters:="\\!\"#$%&'()=~|<>?;*`[] "
	C_LONGINT:C283($i)
	For ($i; 1; Length:C16($metacharacters))
		$metacharacter:=Substring:C12($metacharacters; $i; 1)
		$param:=Replace string:C233($param; $metacharacter; "\\"+$metacharacter; *)
	End for 
	
Function encodeObject($object : Object)->$encodedObject : Text
	
	If ($object#Null:C1517)
		
		var $json : Text
		$json:=JSON Stringify:C1217($object)
		
		var $data : Blob
		CONVERT FROM TEXT:C1011($json; "utf-8"; $data)
		
		BASE64 ENCODE:C895($data; $encodedObject)
		
	End if 