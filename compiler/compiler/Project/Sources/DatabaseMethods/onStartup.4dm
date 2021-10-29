/*

On Startup

*/

var $params : Real
var $userParams; $options : Object
var $project : 4D:C1709.File

var $userParam : Text

$params:=Get database parameter:C643(User param value:K37:94; $userParam)

var $data : Blob
var $userParamsJson : Text

CONVERT FROM TEXT:C1011($userParam; "utf-8"; $data)
BASE64 DECODE:C896($data; $userParamsJson)

If ($userParamsJson#"")
	
	ON ERR CALL:C155("ON_PARSE_ERROR")
	$userParams:=JSON Parse:C1218($userParamsJson; Is object:K8:27)
	ON ERR CALL:C155("")
	
	If ($userParams#Null:C1517)
		
		If ($userParams.project#Null:C1517)
			
			$project:=File:C1566($userParams.project)
			
			If ($project.exists)
				If ($userParams.options#Null:C1517)
					$options:=$userParams.options
				Else 
					$options:=New object:C1471
				End if 
				
				$status:=Compile project:C1760($project; $options)
				
				var $console : cs:C1710.Console
				
				$console:=cs:C1710.Console.new($project)
				
				$console.printErrors($status)
				
			End if 
		End if 
	End if 
End if 

If (Application type:C494=4D Desktop:K5:4)
	QUIT 4D:C291
End if 
