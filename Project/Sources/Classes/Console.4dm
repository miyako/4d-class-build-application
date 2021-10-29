Class constructor($project : 4D:C1709.File)
	
	This:C1470.project:=$project
	
Function printInformation($message : Text)
	
	LOG EVENT:C667(Into system standard outputs:K38:9; $message+"\n"; Information message:K38:1)
	
Function printWarning($message : Text)
	
	LOG EVENT:C667(Into system standard outputs:K38:9; $message+"\n"; Warning message:K38:2)
	
Function printError($message : Text)
	
	LOG EVENT:C667(Into system standard outputs:K38:9; $message+"\n"; Error message:K38:3)
	
Function printErrors($status : Object)
	
	If ($status#Null:C1517)
		If ($status.errors#Null:C1517)
			If ($status.errors.length>0)
				This:C1470.printInformation("::group::Compile project (errors)")
				var $error : Object
				For each ($error; $status.errors)
					This:C1470.print($error)
				End for each 
				This:C1470.printInformation("::endgroup::")
			End if 
		End if 
	End if 
	
Function printStatus($success : Boolean)
	
	$console.printInformation("::group::Compile project")
	$console.printInformation("::project="+This:C1470.project.path+",success="+String:C10($success)+"::")
	$console.printInformation("::endgroup::")
	
Function print($error : Object)
	
	var $relativePath : Text
	
	If ($error.code#Null:C1517)
		$relativePath:=Replace string:C233(File:C1566($error.code.file.platformPath; fk platform path:K87:2).path; This:C1470.project.parent.path; ""; 1; *)
		$file:="file="+String:C10($relativePath)+",line="+String:C10($error.lineInFile)
	Else 
		$file:=""
	End if 
	
	If (Bool:C1537($error.isError))
		This:C1470.printError("::"+$file+"::"+String:C10($error.message))
	Else 
		This:C1470.printWarning("::"+$file+"::"+String:C10($error.message))
	End if 
	