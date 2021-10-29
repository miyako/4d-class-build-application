//%attributes = {"invisible":true}
var $i : Integer
var $log : Object

$logFile:=Folder:C1567(fk logs folder:K87:17; *).folder("Components").file("compiler.log")

If (Not:C34($logFile.exists))
	$logFile.parent.create()
End if 

$size:=$logFile.size

$ENUM:=New object:C1471("create"; 0; "append"; 1; "SEEK_END"; 2)

If ($size=0)
	$doc:=Create document:C266($logFile.platformPath)
	$mode:=$ENUM.create
Else 
	$doc:=Append document:C265($logFile.platformPath)
	$mode:=$ENUM.append
End if 

If (OK=1)
	
	Case of 
		: ($mode=$ENUM.create)
			SEND PACKET:C103($doc; "[")
		: ($mode=$ENUM.append)
			SET DOCUMENT POSITION:C482($doc; -1; $ENUM.SEEK_END)
			SEND PACKET:C103($doc; ",")
	End case 
	
	ARRAY TEXT:C222($names; 0)
	ARRAY TEXT:C222($messages; 0)
	ARRAY LONGINT:C221($codes; 0)
	GET LAST ERROR STACK:C1015($codes; $names; $messages)
	
	$stack:=New collection:C1472
	$log:=New object:C1471(\
		"error"; ERROR; \
		"line"; ERROR LINE; \
		"method"; ERROR METHOD; \
		"formula"; ERROR FORMULA; \
		"stack"; $stack; \
		"callChain"; Get call chain:C1662.reverse())  //reverse: caller before callee
	
	For ($i; 1; Size of array:C274($codes))
		$stack.push(New object:C1471("code"; $codes{$i}; "names"; $names{$i}; "messages"; $messages{$i}))
	End for 
	
	SEND PACKET:C103($doc; JSON Stringify:C1217($log; *))
	
	SEND PACKET:C103($doc; "]")
	CLOSE DOCUMENT:C267($doc)
	
End if 