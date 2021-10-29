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
		
		If (Value type:C1509($userParams.project)=Is text:K8:3)
			
			var $folder : 4D:C1709.Folder
			
			Case of 
				: (Is macOS:C1572)
					$folder:=Folder:C1567(Application file:C491; fk platform path:K87:2).parent
				: (Is Windows:C1573)
					$folder:=File:C1566(Application file:C491; fk platform path:K87:2).parent
			End case 
			
			$project:=File:C1566($folder.path+$userParams.project)
			
			If ($project.exists)
				If ($userParams.options#Null:C1517)
					$options:=$userParams.options
				Else 
					$options:=New object:C1471
				End if 
				
				$status:=Compile project:C1760($project; $options)
				
				var $console : cs:C1710.Console
				
				$console:=cs:C1710.Console.new($project)
				
				$console.printStatus($status.success)
				
				$console.printErrors($status)
				
				QUIT 4D:C291
				
			End if 
		End if 
	End if 
End if 