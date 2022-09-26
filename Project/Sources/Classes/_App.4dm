Class constructor
	
Function escape_param($escape_param : Text)->$param : Text
	
	$param:=$escape_param
	
	$metacharacters:="\\!\"#$%&'()=~|<>?;*`[] "
	C_LONGINT:C283($i)
	For ($i; 1; Length:C16($metacharacters))
		$metacharacter:=Substring:C12($metacharacters; $i; 1)
		$param:=Replace string:C233($param; $metacharacter; "\\"+$metacharacter; *)
	End for 
	
	