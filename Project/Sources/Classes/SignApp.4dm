Class extends _App

Class constructor($credentials : Object; $plist : Object)
	
	Super:C1705()
	
	If ($credentials#Null:C1517)
		
		This:C1470.username:=$credentials.username
		This:C1470.password:=$credentials.password
		This:C1470.ascProvider:=$credentials.ascProvider
		This:C1470.teamId:=$credentials.teamId
		This:C1470.keychainProfile:=$credentials.keychainProfile
		
		If ($credentials.signingIdentity#Null:C1517)
			This:C1470.signingIdentity:=$credentials.signingIdentity
		Else 
			This:C1470.identity:=This:C1470.findIdentity()
			If (This:C1470.identity.length#0)
				$identity:=This:C1470.identity.query("name == :1"; "Developer ID Application:@")
				If ($identity.length#0)
					This:C1470.signingIdentity:=$identity[0].name
				End if 
			End if 
		End if 
		
		This:C1470.destination:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2)
		This:C1470.ENVIRONMENT:=New object:C1471
		This:C1470.CONST:=New object:C1471
		
/*
unused option:local (don't use timestamp server)
*/
		
		This:C1470.CONST.FORCE:=New object:C1471("force"; True:C214)
		This:C1470.CONST.REMOVE:=New object:C1471("remove"; True:C214)
		This:C1470.CONST.MECAB:=New object:C1471("force"; True:C214; "mecab"; True:C214)
		This:C1470.CONST.UPDATER:=New object:C1471("force"; True:C214; "sandbox"; True:C214)
		
		This:C1470.CONST.WITH_HARDENED_RUNTIME:=True:C214
		This:C1470.CONST.WITHOUT_HARDENED_RUNTIME:=False:C215
		
		This:C1470.CONST.NO_OPTIONS:=Null:C1517
		
		This:C1470.versionID:=Lowercase:C14(Generate UUID:C1066)
		This:C1470.primaryBundleId:="com.4D."+This:C1470.versionID
		
		This:C1470.entitlements:=New object:C1471  //empty object: default entitlements
		This:C1470.plist:=New object:C1471  //empty object: use current plist (no change)
		
		If ($plist#Null:C1517)
			This:C1470.plist:=$plist
		End if 
		
		If (This:C1470.plist.CFBundleIdentifier#Null:C1517)
			This:C1470.bundleIdentifier:=This:C1470.plist.CFBundleIdentifier
		End if 
		
		This:C1470.options:=New object:C1471
		
		This:C1470.options.signApp:=True:C214
		This:C1470.options.signNativeComponents:=True:C214
		
		//these can be False (signed with .app, presumably)
		This:C1470.options.signFrameworks:=False:C215
		This:C1470.options.signInternalComponents:=False:C215
		
		This:C1470.options.signPlugins:=True:C214
		This:C1470.options.signSASLPlugins:=True:C214
		This:C1470.options.signPHP:=True:C214
		This:C1470.options.signHelpers:=True:C214
		This:C1470.options.signUpdater:=True:C214
		This:C1470.options.signMobile:=True:C214
		This:C1470.options.signMecab:=True:C214
		This:C1470.options.signContents:=True:C214
		This:C1470.options.signComponents:=True:C214
		This:C1470.options.signDatabase:=True:C214  //in particular, for lib4d-arm64.dylib
		
		This:C1470.options.deleteTempFiles:=True:C214
		This:C1470.options.cleanFirst:=True:C214
		This:C1470.options.removePHP:=False:C215
		This:C1470.options.movePluginManifest:=False:C215
		This:C1470.options.removeComponentPlugins:=True:C214
		This:C1470.options.removeCEF:=False:C215
		
/*
		
not implemented
		
remove mecab
remove CEF
		
*/
		
		This:C1470.setXcodePath()
		
	End if 
	
Function sign($app : 4D:C1709.Folder)->$statuses : Collection
	
	If (Is macOS:C1572)
		If (OB Instance of:C1731($app; 4D:C1709.Folder))
			If ($app.exists)
				If (This:C1470.signingIdentity#Null:C1517)
					
					This:C1470.app:=$app
					
					$statuses:=New collection:C1472
					
					If (This:C1470.options.signApp)
						
						If (This:C1470.options.deleteTempFiles)
							This:C1470._deleteTempFiles($app)
						End if 
						
						If (This:C1470.options.cleanFirst)
							This:C1470._removeSignature($app; $statuses)
						End if 
						
						If (This:C1470.options.signHelpers)
							This:C1470._signHelpers($app; $statuses)
						End if 
						
						If (This:C1470.options.removeCEF)
							This:C1470._removeCEF($app; $statuses)
						End if 
						
						If (This:C1470.options.signNativeComponents)
							This:C1470._signNativeComponents($app; $statuses)
						End if 
						
						If (This:C1470.options.signUpdater)  //server only
							This:C1470._signUpgrade4DClient($app; $statuses)
							This:C1470._signUpdater($app; $statuses)
						End if 
						
						If (This:C1470.options.signFrameworks)
							This:C1470._signFrameworks($app; $statuses)
						End if 
						
						If (This:C1470.options.signMobile)
							This:C1470._signMobile($app; $statuses)
						End if 
						
						If (This:C1470.options.signInternalComponents)
							This:C1470._signInternalComponents($app; $statuses)
						End if 
						
						If (This:C1470.options.removeComponentPlugins)
							This:C1470._removeComponentPlugins($app; $statuses)
						End if 
						
						If (This:C1470.options.signPlugins)
							This:C1470._signPlugins($app; $statuses)
						End if 
						
						If (This:C1470.options.signComponents)
							This:C1470._signComponents($app; $statuses)
						End if 
						
						If (This:C1470.options.signDatabase)
							This:C1470._signDatabase($app; $statuses)
						End if 
						
						If (This:C1470.options.signMecab)
							This:C1470._signMecab($app; $statuses)
						End if 
						
						If (This:C1470.options.signSASLPlugins)
							This:C1470._signSASLPlugins($app; $statuses)
						End if 
						
						If (This:C1470.options.signContents)
							This:C1470._signContents($app; $statuses)
						End if 
						
						If (This:C1470.options.removePHP)
							This:C1470._removePHP($app; $statuses)
						Else 
							If (This:C1470.options.signPHP)
								This:C1470._signPHP($app; $statuses)
							End if 
						End if 
						
						This:C1470._signBin($app; $statuses)
						
						This:C1470._signApp($app; $statuses)
						
					End if 
				End if 
			End if 
		End if 
	End if 
	
Function notarize($file : 4D:C1709.File; $useOldTool : Boolean)->$status : Object
	
	$status:=New object:C1471("success"; False:C215; "readyForPublication"; False:C215; "readyForDistribution"; False:C215)
	
	var $use_altool : Boolean
	
	If (Count parameters:C259>1)
		$use_altool:=$useOldTool
	End if 
	
	If (Is macOS:C1572)
		If (OB Instance of:C1731($file; 4D:C1709.File))
			If ($file.exists)
				
				If ($use_altool)
					$status:=This:C1470._altool(New object:C1471("file"; $file))
				Else 
					$status:=This:C1470._notarytool(New object:C1471("file"; $file))
				End if 
				
				$gotResult:=False:C215
				
				If ($status.success)
					
					If ($use_altool)
						Repeat 
							$status:=This:C1470._altool(New object:C1471("RequestUUID"; $status.RequestUUID))
							If ($status.success) & ($status.LogFileURL#Null:C1517)
								$gotResult:=True:C214
								C_TEXT:C284($response)
								$statusCode:=HTTP Get:C1157($status.LogFileURL; $response)
								If ($statusCode=200)
									C_OBJECT:C1216($json)
									ON ERR CALL:C155("ON_PARSE_ERROR")
									$json:=JSON Parse:C1218($response; Is object:K8:27)
									ON ERR CALL:C155("")
									$status.readyForDistribution:=($json.status="Accepted")
								End if 
							End if 
							If (Not:C34($gotResult))
								DELAY PROCESS:C323(Current process:C322; 60*60)  //check every minute
							End if 
						Until ($gotResult)
					Else 
						$status.readyForDistribution:=True:C214
					End if 
					
					If ($status.readyForDistribution)
						$status:=This:C1470._staple($file)
						$status.readyForPublication:=$status.success
					End if 
					
				End if 
			End if 
		End if 
	End if 
	
Function _staple($file : 4D:C1709.File)->$status : Object
	
	$status:=New object:C1471("success"; False:C215)
	
	var $stdIn; $stdOut; $stdErr : Blob
	var $pid : Integer
	
	SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
	LAUNCH EXTERNAL PROCESS:C811("xcrun stapler staple "+This:C1470.escape_param($file.path); $stdIn; $stdOut; $stdErr; $pid)
	
	If (BLOB size:C605($stdErr)#0)
		$status.staple:=Convert to text:C1012($stdErr; "utf-8")
		$status.staple:=Split string:C1554($status.staple; "\n"; sk ignore empty strings:K86:1 | sk trim spaces:K86:2)
	Else 
		$status.staple:=Convert to text:C1012($stdOut; "utf-8")
		$status.success:=($status.staple="@The staple and validate action worked!@")
		$status.staple:=Split string:C1554($status.staple; "\n"; sk ignore empty strings:K86:1 | sk trim spaces:K86:2)
	End if 
	
Function _notarytool_path()->$command : Text
	
	$command:="xcrun notarytool"
	
	$osVersion:=Get system info:C1571.osVersion
	If ($osVersion="@10.15.@")
		var $stdIn; $stdOut; $stdErr : Blob
		LAUNCH EXTERNAL PROCESS:C811("xcrun -f notarytool"; $stdIn; $stdOut; $stdErr)
		$paths:=Split string:C1554(Convert to text:C1012($stdOut; "utf-8"); "\n"; sk ignore empty strings:K86:1 | sk trim spaces:K86:2)
		If ($paths.length#0)
			$command:=$paths[0]
		End if 
	End if 
	
Function _notarytool($params : Object)->$status : Object
	
	$status:=New object:C1471("success"; False:C215)
	
	If (OB Instance of:C1731($params.file; 4D:C1709.File))
		
		$command:=This:C1470._notarytool_path()+" submit "+This:C1470.escape_param($params.file.path)
		
		Case of 
			: (This:C1470.keychainProfile#Null:C1517)
				$command:=$command+" --keychain-profile "+This:C1470.keychainProfile+" --wait"
			: (This:C1470.username#Null:C1517) & (This:C1470.teamId#Null:C1517) & (This:C1470.password#Null:C1517)
				$command:=$command+" --apple-id \""+This:C1470.username+"\""+" --team-id "+This:C1470.teamId+" --password "+This:C1470.password+" --wait"
			Else 
				$command:=""
		End case 
		
		If ($command#"")
			
			var $stdIn; $stdOut; $stdErr : Blob
			var $pid : Integer
			
			SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
			LAUNCH EXTERNAL PROCESS:C811($command; $stdIn; $stdOut; $stdErr; $pid)
			
			C_TEXT:C284($info)
			
			If (BLOB size:C605($stdErr)#0)
				$info:=Convert to text:C1012($stdErr; "utf-8")
				$status.info:=Split string:C1554($info; "\n"; sk trim spaces:K86:2 | sk ignore empty strings:K86:1)
			End if 
			
			If (BLOB size:C605($stdOut)#0)
				$info:=Convert to text:C1012($stdOut; "utf-8")
				$status.info:=Split string:C1554($info; "\n"; sk trim spaces:K86:2 | sk ignore empty strings:K86:1)
			End if 
			
			If ($status.info.length#0)
				$statusCode:=$status.info.pop()
				If ($statusCode="status: Accepted")
					$status.success:=True:C214
				End if 
			End if 
			
		End if 
		
	End if 
	
Function _altool($params : Object)->$status : Object
	
	$status:=New object:C1471("success"; False:C215)
	
	Case of 
		: (Value type:C1509($params.RequestUUID)=Is text:K8:3)
			$status.RequestUUID:=$params.RequestUUID
			$command:="xcrun altool --notarization-info "+$params.RequestUUID
		: (OB Instance of:C1731($params.file; 4D:C1709.File))
			$command:="xcrun altool --notarize-app --file "+This:C1470.escape_param($params.file.path)
		Else 
			$command:=""
	End case 
	
	If ($command#"")
		If (Value type:C1509(This:C1470.primaryBundleId)=Is text:K8:3)
			$command:=$command+" --primary-bundle-id "+This:C1470.escape_param(This:C1470.primaryBundleId)
		End if 
		If (Value type:C1509(This:C1470.ascProvider)=Is text:K8:3)
			$command:=$command+" --asc-provider "+This:C1470.escape_param(This:C1470.ascProvider)
		End if 
		If (Value type:C1509(This:C1470.username)=Is text:K8:3)
			$command:=$command+" --username "+This:C1470.escape_param(This:C1470.username)
		End if 
		If (Value type:C1509(This:C1470.password)=Is text:K8:3)
			$command:=$command+" --password "+This:C1470.escape_param(This:C1470.password)
		End if 
		
		If (This:C1470.ENVIRONMENT.DEVELOPER_DIR#Null:C1517)
			$DEVELOPER_DIR:=This:C1470.ENVIRONMENT.DEVELOPER_DIR
			SET ENVIRONMENT VARIABLE:C812("DEVELOPER_DIR"; $DEVELOPER_DIR)
		End if 
		
		var $stdIn; $stdOut; $stdErr : Blob
		var $pid : Integer
		
		SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
		LAUNCH EXTERNAL PROCESS:C811($command; $stdIn; $stdOut; $stdErr; $pid)
		
		C_TEXT:C284($info)
		
		If (BLOB size:C605($stdErr)#0)
			$info:=Convert to text:C1012($stdErr; "utf-8")
			$status.info:=Split string:C1554($info; "\n"; sk trim spaces:K86:2 | sk ignore empty strings:K86:1)
		End if 
		
		If (BLOB size:C605($stdOut)#0)
			$info:=Convert to text:C1012($stdOut; "utf-8")
			$status.info:=Split string:C1554($info; "\n"; sk trim spaces:K86:2 | sk ignore empty strings:K86:1)
		End if 
		
		ARRAY LONGINT:C221($pos; 0)
		ARRAY LONGINT:C221($len; 0)
		C_LONGINT:C283($i)
		$i:=1
		
		$status.success:=($info="@No errors uploading@")
		
		If ($status.success)
			//upload successful
			While (Match regex:C1019("(?m)^\\s*(\\S+)\\s*=\\s*(.+)$"; $info; $i; $pos; $len))
				$key:=Substring:C12($info; $pos{1}; $len{1})
				$status[$key]:=Substring:C12($info; $pos{2}; $len{2})
				If ($status[$key]="(null)")
					$status[$key]:=Null:C1517
				End if 
				$i:=$pos{2}+$len{2}
			End while 
			If ($status.RequestUUID#Null:C1517)
				$params.RequestUUID:=$status.RequestUUID
			End if 
		Else 
			$status.success:=($info="@No errors getting notarization info@")
			If ($status.success)
				//got status
				While (Match regex:C1019("(?m)^\\s*(\\S+)\\s*:\\s*(.+)$"; $info; $i; $pos; $len))
					$key:=Substring:C12($info; $pos{1}; $len{1})
					$status[$key]:=Substring:C12($info; $pos{2}; $len{2})
					If ($status[$key]="(null)")
						$status[$key]:=Null:C1517
					End if 
					$i:=$pos{2}+$len{2}
				End while 
				If ($status.LogFileURL#Null:C1517)
					If ($status.LogFileURL="https://@")
						If (HTTP Get:C1157($status.LogFileURL; $stdOut)=200)
							$json:=Convert to text:C1012($stdOut; "utf-8")
							$status.LogFile:=JSON Parse:C1218($json)
						End if 
					End if 
				End if 
			Else 
				//already uploaded?
				If (Match regex:C1019("(?m)^\\s*Package Summary:$"; $info; 1; $pos; $len))
					$info:=Substring:C12($info; $pos{0}+$len{0})
					If (Match regex:C1019("\"The software asset has already been uploaded. The upload ID is (.+)\""; $info; 1; $pos; $len))
						$params.RequestUUID:=Substring:C12($info; $pos{1}; $len{1})
						//2nd call, get status
						$status:=This:C1470._altool($params)
					End if 
				End if 
			End if 
		End if 
	End if 
	
Function notarizationInfo($RequestUUID : Text)->$status : Object
	
	$status:=This:C1470._altool(New object:C1471("RequestUUID"; $RequestUUID))
	
Function archive($app : 4D:C1709.Folder; $format : Text)->$status : Object
	
	var $archiveFormat : Text
	
	If (Count parameters:C259>1)
		Case of 
			: ($format=".pkg")
				$archiveFormat:=$format
			: ($format=".zip")
				$archiveFormat:=$format
			Else 
				$archiveFormat:=".dmg"
		End case 
	End if 
	
	$status:=New object:C1471("success"; False:C215)
	
	If (Is macOS:C1572)
		If (OB Instance of:C1731($app; 4D:C1709.Folder))
			If ($app.exists)
				
				$dst:=This:C1470.destination.folder(This:C1470.versionID)
				
				Case of 
					: ($archiveFormat=".dmg")
						
						$status:=This:C1470.hdiutil($app; $dst)
						
					: ($archiveFormat=".zip")
						
						$status:=This:C1470.ditto($app; $dst)
						
					Else 
						
						$status:=This:C1470.pkgbuild($app; $dst)
						
						If ($status.success)
							
							$status:=This:C1470.productsign($status.pkg; $dst)
							
						End if 
						
				End case 
				
				var $archive : 4D:C1709.File
				
				If ($status.success)
					
					$archive:=This:C1470.destination.folder(This:C1470.versionID).file($app.name+$archiveFormat)
					
					If ($archive.exists)
						$status.file:=$archive
					Else 
						$status.success:=False:C215
					End if 
					
				End if 
			End if 
		End if 
	End if 
	
Function _signDatabase($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	$extensions:=New collection:C1472(".html"; ".json"; ".js"; ".dylib")
	
	$folder:=$app.folder("Contents").folder("Database")
	
	If ($folder.exists)
		For each ($file; $folder.files(fk recursive:K87:7 | fk ignore invisible:K87:22).query("extension in :1"; $extensions))
			$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
		End for each 
	End if 
	
	$folder:=$app.folder("Contents").folder("Server Database")
	
	If ($folder.exists)
		For each ($file; $folder.files(fk recursive:K87:7 | fk ignore invisible:K87:22).query("extension in :1"; $extensions))
			$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITHOUT_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
		End for each 
	End if 
	
Function _removeComponentPlugins($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	$folder:=$app.folder("Contents").folder("Components")
	
	For each ($component; $folder.folders())
		$plugins:=$component.folder("Plugins")
		If ($plugins.exists)
			$plugins.delete(Delete with contents:K24:24)
		End if 
	End for each 
	
Function _removeCEF($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	$folder:=$app.folder("Contents").folder("Native Components").folder("WebViewerCEF.bundle")
	$folder.delete(Delete with contents:K24:24)
	
	$file:=$app.folder("Contents").file("Chromium Embedded Framework.framework")
	$file.delete()
	
/*
(invalid destination for symbolic link in bundle)
*/
	
	$file:=$app.folder("Contents").folder("Frameworks").file("Chromium Embedded Framework.framework")
	$file.delete()
	
Function _removePHP($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	$folder:=$app.folder("Contents").folder("Resources").folder("php").folder("Mac")
	$folder.delete(Delete with contents:K24:24)
	
Function _removeSignature($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	If (This:C1470.options.signApp)
		
		$statuses.push(This:C1470.codesign($app; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.REMOVE))
		
		If (This:C1470.options.signNativeComponents)
			$folder:=$app.folder("Contents").folder("Native Components")
			For each ($component; $folder.folders())
				$statuses.push(This:C1470.codesign($component; This:C1470.CONST.WITHOUT_HARDENED_RUNTIME; This:C1470.CONST.REMOVE))
			End for each 
		End if 
		
	End if 
	
Function _signComponents($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	$folder:=$app.folder("Contents").folder("Components")
	
	$extensions:=New collection:C1472(".html"; ".json"; ".js"; ".dylib")
	
	If ($folder.exists)
		For each ($file; $folder.files(fk recursive:K87:7 | fk ignore invisible:K87:22).query("extension in :1"; $extensions))
			$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
		End for each 
	End if 
	
Function _signUpgrade4DClient($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	$folder:=$app.folder("Contents").folder("Upgrade4DClient")
	
	$extensions:=New collection:C1472(".html"; ".json"; ".js"; ".dylib")
	
	If ($folder.exists)
		For each ($file; $folder.files(fk recursive:K87:7 | fk ignore invisible:K87:22).query("extension in :1"; $extensions))
			$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
		End for each 
	End if 
	
Function _signNativeComponents($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	//sometimes, there is a framework folder here; symlink here will prevent codesign, so delete it
	$folder:=$app.folder("Contents").folder("Native Components").folder("WebViewerCEF.bundle").folder("Contents").folder("Frameworks").folder("4D Helper.app").folder("Contents").folder("Frameworks")
	If ($folder.exists)
		$folder.delete(Delete with contents:K24:24)
		$file:=$app.folder("Contents").folder("Native Components").folder("WebViewerCEF.bundle").folder("Contents").folder("Frameworks").folder("4D Helper.app").folder("Contents").folder("MacOS").file("4D Helper")
		$from:="@executable_path/../Frameworks/Chromium Embedded Framework.framework/Chromium Embedded Framework"
		$to:="@executable_path/../../../../Frameworks/Chromium Embedded Framework.framework/Chromium Embedded Framework"
		This:C1470.install_name_tool($file; $from; $to; $statuses)
		$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
	End if 
	
	$folder:=$app.folder("Contents").folder("Native Components").folder("WebViewerCEF.bundle").folder("Contents").folder("Frameworks").folder("4D Helper (Plugin).app")
	
	If ($folder.exists)
		$statuses.push(This:C1470.codesign($folder; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
	End if 
	
	$folder:=$app.folder("Contents").folder("Native Components").folder("WebViewerCEF.bundle").folder("Contents").folder("Frameworks").folder("4D Helper (GPU).app")
	
	If ($folder.exists)
		$statuses.push(This:C1470.codesign($folder; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
	End if 
	
	$folder:=$app.folder("Contents").folder("Native Components").folder("WebViewerCEF.bundle").folder("Contents").folder("Frameworks").folder("4D Helper (Renderer).app")
	
	If ($folder.exists)
		$statuses.push(This:C1470.codesign($folder; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
	End if 
	
	$folder:=$app.folder("Contents").folder("Native Components").folder("WebViewerCEF.bundle").folder("Contents").folder("Frameworks").folder("4D Helper.app")
	
	If ($folder.exists)
		$statuses.push(This:C1470.codesign($folder; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
	End if 
	
	//sign dylibs
	$folder:=$app.folder("Contents").folder("Native Components").folder("WebViewerCEF.bundle").folder("Contents").folder("Frameworks").folder("Chromium Embedded Framework.framework").folder("Libraries")
	For each ($file; $folder.files(fk recursive:K87:7 | fk ignore invisible:K87:22))
		$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
	End for each 
	
	//sign executable
	$file:=$app.folder("Contents").folder("Native Components").folder("WebViewerCEF.bundle").folder("Contents").folder("Frameworks").folder("Chromium Embedded Framework.framework").file("Chromium Embedded Framework")
	$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
	
	//sign these without hardened runtime; use NO_OPTIONS (don't use --deep) or 4D Helper will become invalid
	$folder:=$app.folder("Contents").folder("Native Components").folder("WebViewerCEF.bundle").folder("Contents").folder("Frameworks").folder("Chromium Embedded Framework.framework")
	$statuses.push(This:C1470.codesign($folder; This:C1470.CONST.WITHOUT_HARDENED_RUNTIME; This:C1470.CONST.NO_OPTIONS))
	
	//sign these without hardened runtime; use NO_OPTIONS (don't use --deep) or 4D Helper will become invalid
	$folder:=$app.folder("Contents").folder("Native Components")
	For each ($component; $folder.folders())
		$statuses.push(This:C1470.codesign($component; This:C1470.CONST.WITHOUT_HARDENED_RUNTIME; This:C1470.CONST.NO_OPTIONS))
	End for each 
	
Function _signInternalComponents($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	$folder:=$app.folder("Contents").folder("Resources").folder("Internal Components")
	
	$extensions:=New collection:C1472(".html"; ".json"; ".js"; ".dylib")
	
	If ($folder.exists)
		For each ($file; $folder.files(fk recursive:K87:7 | fk ignore invisible:K87:22).query("extension in :1"; $extensions))
			$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITHOUT_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
		End for each 
	End if 
	
Function _signPlugins($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	$folder:=$app.folder("Contents").folder("Plugins")
	
	If ($folder.exists)
		For each ($plugin; $folder.folders().query("extension == :1"; ".bundle"))
			$manifest:=$plugin.folder("Contents").file("manifest.json")
			If ($manifest.exists)
				If (This:C1470.movePluginManifest)
					$manifest.moveTo($manifest.parent.folder("Resources"))
				Else 
					$statuses.push(This:C1470.codesign($manifest; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
				End if 
			End if 
			$statuses.push(This:C1470.codesign($plugin; This:C1470.CONST.WITHOUT_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
		End for each 
	End if 
	
Function _signFrameworks($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	$folder:=$app.folder("Contents").folder("Frameworks")
	
	If ($folder.exists)
		For each ($framework; $folder.folders())
			$statuses.push(This:C1470.codesign($framework; This:C1470.CONST.WITHOUT_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
		End for each 
	End if 
	
Function _signContents($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	$names:=New collection:C1472("PkgInfo"; "CodeResources")
	
	$folder:=$app.folder("Contents")
	
	If ($folder.exists)
		For each ($file; $folder.files(fk ignore invisible:K87:22).query("not((name in :1) or (name == :2 and extension == :3))"; $names; "Info"; ".plist"))
			$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITHOUT_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
		End for each 
	End if 
	
Function _signMecab($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	$folder:=$app.folder("Contents").folder("Resources").folder("mecab").folder("mecab.bundle")
	
	If ($folder.exists)
		$statuses.push(This:C1470.codesign($folder; This:C1470.CONST.WITHOUT_HARDENED_RUNTIME; This:C1470.CONST.MECAB))
	End if 
	
Function _signSASLPlugins($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	$file:=$app.folder("Contents").folder("SASL Plugins").file("libdigestmd5.plugin")
	
	If ($file.exists)
		$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITHOUT_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
	End if 
	
Function _signPHP($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	$file:=$app.folder("Contents").folder("Resources").folder("php").folder("Mac").file("php-fcgi-4d")
	
	If ($file.exists)
		$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
	End if 
	
Function _signBin($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	$folder:=$app.folder("Contents").folder("Resources").folder("bin")
	
	If ($folder.exists)
		For each ($file; $folder.files(fk recursive:K87:7 | fk ignore invisible:K87:22))
			$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
		End for each 
	End if 
	
Function _signHelpers($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	$file:=$app.folder("Contents").folder("MacOS").file("HelperTool")
	
	If ($file.exists)
		$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
	End if 
	
	$file:=$app.folder("Contents").folder("MacOS").file("InstallTool")
	
	If ($file.exists)
		$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
	End if 
	
	$file:=$app.folder("Contents").folder("MacOS").folder("InstallTool.app").folder("Contents").folder("Library").folder("LaunchServices").file("com.4D.Helper")
	
	If ($file.exists)
		$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
	End if 
	
	$folder:=$app.folder("Contents").folder("MacOS").folder("InstallTool.app")
	
	If ($folder.exists)
		$statuses.push(This:C1470.codesign($folder; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
	End if 
	
Function _signUpdater($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	var $folder : 4D:C1709.Folder
	
	$folder:=$app.folder("Contents").folder("Resources").folder("Updater").folder("Updater.app").folder("Contents").folder("Frameworks")
	
	If ($folder.exists)
		For each ($file; $folder.files(fk recursive:K87:7 | fk ignore invisible:K87:22))
			$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITHOUT_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
		End for each 
	End if 
	
	//sign with hardened runtime because this is an app
	$folder:=$app.folder("Contents").folder("Resources").folder("Updater").folder("Updater.app")
	If ($folder.exists)
		$statuses.push(This:C1470.codesign($folder; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.UPDATER))
	End if 
	
Function _signMobile($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	var $file : 4D:C1709.File
	
	For each ($file; $app.folder("Contents").folder("Resources").folder("Internal User Components").folder("4D Mobile App.4dbase").folder("Resources").folder("scripts").files(fk recursive:K87:7 | fk ignore invisible:K87:22))
		$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
	End for each 
	
	For each ($file; $app.folder("Contents").folder("Resources").folder("Internal User Components").folder("4D Mobile App.4dbase").folder("Resources").folder("sdk").files(fk recursive:K87:7 | fk ignore invisible:K87:22))
		$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITHOUT_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
	End for each 
	
	$platforms:=New collection:C1472("iOS"; "tvOS"; "watchOS"; "Mac")
	$extensions:=New collection:C1472(".framework"; ".dSYM")
	
	For each ($file; $app.folder("Contents").folder("Resources").folder("Internal User Components").folder("4D Mobile App.4dbase").folder("Resources").folder("sdk").files(fk recursive:K87:7 | fk ignore invisible:K87:22).query("extension == :1"; ".zip"))
		$temporaryFolder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder(Generate UUID:C1066).folder($app.name)
		$temporaryFolder.create()
		This:C1470.ditto($file; $temporaryFolder)
		For each ($platform; $platforms)
			$platformFolder:=$temporaryFolder.folder("Carthage").folder("Build").folder($platform)
			If ($platformFolder.exists)
				For each ($framework; $platformFolder.folders().query("extension in :1"; $extensions))
					If (This:C1470.options.cleanFirst)
						$statuses.push(This:C1470.codesign($framework; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.REMOVE))
					End if 
					$folder:=$framework.folder("Contents").folder("Resources").folder("DWARF")
					If ($folder.exists)
						For each ($file; $folder.files(fk recursive:K87:7 | fk ignore invisible:K87:22))
							$statuses.push(This:C1470.codesign($file; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
						End for each 
						$statuses.push(This:C1470.codesign($framework; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.FORCE))
					End if 
				End for each 
			End if 
		End for each 
		This:C1470.ditto($temporaryFolder; $file; True:C214)
	End for each 
	
Function _signApp($app : 4D:C1709.Folder; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	$statuses.push(This:C1470.codesign($app; This:C1470.CONST.WITH_HARDENED_RUNTIME; This:C1470.CONST.NO_OPTIONS))
	
Function _deleteTempFiles($app : 4D:C1709.Folder)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	If (OB Instance of:C1731($app; 4D:C1709.Folder))
		
		//remove codesign temp files (created after abort)
		
		$files:=$app.files(fk recursive:K87:7).query("extension == :1"; ".cstemp")
		For each ($file; $files)
			$file.delete()
		End for each 
		
	End if 
	
Function _copyDefaultProperties()->$keys : Object
	
	//keys to always insert in Info.plist (UsageDescription) because they can not be added later
	//https://developer.apple.com/documentation/bundleresources/information_property_list
	
	$keys:=New object:C1471
	$keys.NSRequiresAquaSystemAppearance:="NO"
	$keys.NSAppleEventsUsageDescription:=""
	$keys.NSCalendarsUsageDescription:=""
	$keys.NSContactsUsageDescription:=""
	$keys.NSRemindersUsageDescription:=""
	$keys.NSCameraUsageDescription:=""
	$keys.NSMicrophoneUsageDescription:=""
	$keys.NSLocationUsageDescription:=""
	$keys.NSPhotoLibraryUsageDescription:=""
	$keys.NSSystemAdministrationUsageDescription:=""
	
Function _copyDefaultEntitlements()->$entitlements : Object
	
/*
Hardened Runtime entitlements
https://developer.apple.com/documentation/security/hardened_runtime_entitlements?language=objc
*/
	
	$entitlements:=New object:C1471
	$entitlements["com.apple.security.smartcard"]:=True:C214
	$entitlements["com.apple.security.automation.apple-events"]:=True:C214
	$entitlements["com.apple.security.cs.allow-dyld-environment-variables"]:=True:C214
	$entitlements["com.apple.security.cs.allow-jit"]:=True:C214
	$entitlements["com.apple.security.cs.allow-unsigned-executable-memory"]:=True:C214
	$entitlements["com.apple.security.cs.debugger"]:=True:C214
	$entitlements["com.apple.security.cs.disable-executable-page-protection"]:=True:C214
	$entitlements["com.apple.security.cs.disable-library-validation"]:=True:C214
	$entitlements["com.apple.security.get-task-allow"]:=True:C214  //need this for debugging
	$entitlements["com.apple.security.device.audio-input"]:=True:C214
	$entitlements["com.apple.security.device.camera"]:=True:C214
	$entitlements["com.apple.security.personal-information.photos-library"]:=True:C214
	$entitlements["com.apple.security.personal-information.location"]:=True:C214
	$entitlements["com.apple.security.personal-information.addressbook"]:=True:C214
	$entitlements["com.apple.security.personal-information.calendars"]:=True:C214
	
Function install_name_tool($src : Object; $from : Text; $to : Text; $statuses : Collection)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	$status:=New object:C1471("success"; False:C215)
	
	If (Is macOS:C1572)
		
		If ($to="")
			$command:="install_name_tool -id "+\
				"'"+$from+"' "+\
				"'"+$src.path+"'"
		Else 
			$command:="install_name_tool -change "
			$command:=$command+\
				"'"+$from+"' "+\
				"'"+$to+"' "+\
				"'"+$src.path+"'"
		End if 
		
		var $stdIn; $stdOut; $stdErr : Blob
		var $pid : Integer
		
		SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
		LAUNCH EXTERNAL PROCESS:C811($command; $stdIn; $stdOut; $stdErr; $pid)
		
		If (BLOB size:C605($stdErr)#0)
			$status.install_name_tool:=Convert to text:C1012($stdErr; "utf-8")
			$status.success:=($status.install_name_tool="@changes being made to the file will invalidate the code signature@")
			$status.install_name_tool:=Split string:C1554($status.install_name_tool; "\n"; sk ignore empty strings:K86:1 | sk trim spaces:K86:2)
		Else 
			$status.success:=True:C214
		End if 
		
		$statuses.push($status)
		
	End if 
	
Function productsign($src : 4D:C1709.File; $dst : 4D:C1709.Folder)->$status : Object
	
	$this:=This:C1470
	
	$status:=New object:C1471("success"; False:C215)
	
	If (Is macOS:C1572)
		
		C_TEXT:C284($signingIdentity)
		
		If (This:C1470.signingIdentity#Null:C1517)
			$signingIdentity:=This:C1470.signingIdentity
		Else 
			If (This:C1470.identity.length#0)
				$identity:=This:C1470.identity.query("name == :1"; "Developer ID Installer:@")
				If ($identity.length#0)
					$signingIdentity:=$identity[0].name
				End if 
			End if 
		End if 
		
		$name:=$src.fullName
		$src:=$src.rename("$"+$name)
		$dst:=$dst.file($name)
		
		$dst.parent.create()
		
		var $stdIn; $stdOut; $stdErr : Blob
		var $pid : Integer
		
		$command:="productsign --sign '"+$signingIdentity+"' "+This:C1470.escape_param($src.path)+" "+This:C1470.escape_param($dst.path)
		
		SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; $src.parent.platformPath)
		LAUNCH EXTERNAL PROCESS:C811($command; $stdIn; $stdOut; $stdErr; $pid)
		
		If (BLOB size:C605($stdErr)#0)
			$status.productsign:=Convert to text:C1012($stdErr; "utf-8")
			$status.productsign:=Split string:C1554($status.productsign; "\n"; sk ignore empty strings:K86:1 | sk trim spaces:K86:2)
		Else 
			If (BLOB size:C605($stdOut)#0)
				$status.productsign:=Convert to text:C1012($stdOut; "utf-8")
				$status.productsign:=Split string:C1554($status.productsign; "\n"; sk ignore empty strings:K86:1 | sk trim spaces:K86:2)
			End if 
			$status.success:=True:C214
		End if 
		
		$src.delete()
		
	End if 
	
Function pkgbuild($src : Object; $dst : Object)->$status : Object
	
	$this:=This:C1470
	
	$status:=New object:C1471("success"; False:C215)
	
	If (Is macOS:C1572)
		
		If (OB Instance of:C1731($src; 4D:C1709.File)) | (OB Instance of:C1731($src; 4D:C1709.Folder))
			
			Case of 
				: (OB Instance of:C1731($dst; 4D:C1709.Folder))
					$dst:=$dst.file($src.name+".pkg")
				: (OB Instance of:C1731($dst; 4D:C1709.File))
					$dst:=$dst.parent.file($dst.name+".pkg")
				Else 
					$dst:=$dst.parent.file($dst.name+".pkg")
			End case 
			
			$dst.parent.create()
			
			$installLocation:=Folder:C1567(fk applications folder:K87:20)
			$installLocation:=$installLocation.file($src.fullName)
			
			$payloadFolder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder(Generate UUID:C1066)
			$payloadFolder.create()
			
			var $stdIn; $stdOut; $stdErr : Blob
			var $pid : Integer
			
			$command:="mkdir payload"
			
			SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; $payloadFolder.platformPath)
			LAUNCH EXTERNAL PROCESS:C811($command; $stdIn; $stdOut; $stdErr; $pid)
			
			$command:="cp -R "+\
				This:C1470.escape_param($src.path)+" "+\
				This:C1470.escape_param($payloadFolder.folder("payload").path)
			
			SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
			LAUNCH EXTERNAL PROCESS:C811($command; $stdIn; $stdOut; $stdErr; $pid)
			
			$command:="pkgbuild --analyze --root payload component.plist"
			
			SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; $payloadFolder.platformPath)
			LAUNCH EXTERNAL PROCESS:C811($command; $stdIn; $stdOut; $stdErr; $pid)
			
			$command:="plutil -replace BundleIsRelocatable -bool NO component.plist"
			
			SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; $payloadFolder.platformPath)
			LAUNCH EXTERNAL PROCESS:C811($command; $stdIn; $stdOut; $stdErr; $pid)
			
			$command:="plutil -replace BundleIsVersionChecked -bool NO component.plist"
			
			SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; $payloadFolder.platformPath)
			LAUNCH EXTERNAL PROCESS:C811($command; $stdIn; $stdOut; $stdErr; $pid)
			
			$command:="pkgbuild --install-location "+This:C1470.escape_param($installLocation.path)+" --root payload --component-plist component.plist "+\
				This:C1470.escape_param($dst.path)+" --identifier "+This:C1470.primaryBundleId
			
			SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; $payloadFolder.platformPath)
			LAUNCH EXTERNAL PROCESS:C811($command; $stdIn; $stdOut; $stdErr; $pid)
			
			If (BLOB size:C605($stdErr)#0)
				$status.pkgbuild:=Convert to text:C1012($stdErr; "utf-8")
				$status.pkgbuild:=Split string:C1554($status.pkgbuild; "\n"; sk ignore empty strings:K86:1 | sk trim spaces:K86:2)
			Else 
				If (BLOB size:C605($stdOut)#0)
					$status.pkgbuild:=Convert to text:C1012($stdOut; "utf-8")
					$status.pkgbuild:=Split string:C1554($status.pkgbuild; "\n"; sk ignore empty strings:K86:1 | sk trim spaces:K86:2)
				End if 
				$status.success:=True:C214
				$status.pkg:=$dst
			End if 
			
		End if 
	End if 
	
Function hdiutil($src : Object; $dst : Object)->$status : Object
	
	$this:=This:C1470
	
	$status:=New object:C1471("success"; False:C215)
	
	If (Is macOS:C1572)
		
		If (OB Instance of:C1731($src; 4D:C1709.File)) | (OB Instance of:C1731($src; 4D:C1709.Folder))
			
			Case of 
				: (OB Instance of:C1731($dst; 4D:C1709.Folder))
					$dst:=$dst.file($src.name+".dmg")
				: (OB Instance of:C1731($dst; 4D:C1709.File))
					$dst:=$dst.parent.file($dst.name+".dmg")
				Else 
					$dst:=$dst.parent.file($dst.name+".dmg")
			End case 
			
			var $stdIn; $stdOut; $stdErr : Blob
			var $pid : Integer
			
			//hdiutil fails if the target already exists
			If ($dst.exists)
				$dst.delete(Delete with contents:K24:24)
			Else 
				//hdiutil does not create intermediate folders
				$dst.parent.create()
			End if 
			
			//better to receive output in xml plist 
			$command:="hdiutil create -format UDBZ -plist -srcfolder "+\
				This:C1470.escape_param($src.path)+" "+\
				This:C1470.escape_param($dst.path)
			SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
			LAUNCH EXTERNAL PROCESS:C811($command; $stdIn; $stdOut; $stdErr; $pid)
			
			If (BLOB size:C605($stdErr)=0)
				$status.success:=True:C214
				$info:=Convert to text:C1012($stdOut; "utf-8")
				ON ERR CALL:C155("ON_PARSE_ERROR")
				$dom:=DOM Parse XML variable:C720($info)
				ON ERR CALL:C155("")
				If (OK=1)
					ARRAY TEXT:C222($strings; 0)
					C_TEXT:C284($path)
					$string:=DOM Find XML element:C864($dom; "/plist/array/string"; $strings)
					$status.hdiutil:=New collection:C1472
					For ($i; 1; Size of array:C274($strings))
						$string:=$strings{$i}
						DOM GET XML ELEMENT VALUE:C731($string; $path)
						$status.hdiutil.push($src.path)
					End for 
					DOM CLOSE XML:C722($dom)
				End if 
			Else 
				$status.hdiutil:=Convert to text:C1012($stdErr; "utf-8")
				$status.hdiutil:=Split string:C1554($status.hdiutil; "\n"; sk ignore empty strings:K86:1 | sk trim spaces:K86:2)
			End if 
			
		End if 
	End if 
	
Function ditto($src : Object; $dst : Object; $noParentFolder : Boolean)->$status : Object
	
	$this:=This:C1470
	
	$status:=New object:C1471("success"; False:C215)
	
	If (Is macOS:C1572)
		
		$unzip:=($src.extension=".zip")
		
		If (OB Instance of:C1731($src; 4D:C1709.File)) | (OB Instance of:C1731($src; 4D:C1709.Folder))
			
			$unzip:=($src.extension=".zip")
			
			If (Not:C34($unzip))
				
				Case of 
					: (OB Instance of:C1731($dst; 4D:C1709.Folder))
						$dst:=$dst.file($src.name+".zip")
					: (OB Instance of:C1731($dst; 4D:C1709.File))
						$dst:=$dst.parent.file($dst.name+".zip")
					Else 
						$dst:=$dst.parent.file($dst.name+".zip")
				End case 
				
			End if 
			
			var $stdIn; $stdOut; $stdErr : Blob
			var $pid : Integer
			var $unzip : Boolean
			
			If ($unzip)
				
				$command:="ditto -x -k "+\
					This:C1470.escape_param($src.path)+" "+\
					This:C1470.escape_param($dst.path)
				SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
				LAUNCH EXTERNAL PROCESS:C811($command; $stdIn; $stdOut; $stdErr; $pid)
			Else 
				
				If ($noParentFolder)
					$command:="ditto -c -k "+\
						This:C1470.escape_param($src.path)+" "+\
						This:C1470.escape_param($dst.path)
					SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
					LAUNCH EXTERNAL PROCESS:C811($command; $stdIn; $stdOut; $stdErr; $pid)
				Else 
					//.app is a parent folder so --keepParent
					$command:="ditto -c -k --keepParent "+\
						This:C1470.escape_param($src.path)+" "+\
						This:C1470.escape_param($dst.path)
					SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
					LAUNCH EXTERNAL PROCESS:C811($command; $stdIn; $stdOut; $stdErr; $pid)
				End if 
				
				If (BLOB size:C605($stdErr)#0)
					$status.ditto:=Convert to text:C1012($stdErr; "utf-8")
					$status.ditto:=Split string:C1554($status.ditto; "\n"; sk ignore empty strings:K86:1 | sk trim spaces:K86:2)
				Else 
					If (BLOB size:C605($stdOut)#0)
						$status.ditto:=Convert to text:C1012($stdOut; "utf-8")
						$status.ditto:=Split string:C1554($status.ditto; "\n"; sk ignore empty strings:K86:1 | sk trim spaces:K86:2)
					End if 
					$status.success:=True:C214
				End if 
				//ditto does not return much information in stdOut or stdErr
			End if 
			
		End if 
	End if 
	
Function codesign($app : Object; $hardenedRuntime : Boolean; $options : Object)->$status : Object
	
	$status:=New object:C1471("success"; False:C215)
	
	$keys:=This:C1470._copyDefaultProperties()
	
	For each ($key; This:C1470.plist)
		$keys[$key]:=This:C1470.plist[$key]
	End for each 
	
	This:C1470.isSandBox:=Bool:C1537($entitlements["com.apple.security.app-sandbox"])
	
	$entitlements:=This:C1470._copyDefaultEntitlements()
	
	If ($hardenedRuntime)
		For each ($key; This:C1470.entitlements)
			$entitlements[$key]:=This:C1470.entitlements[$key]
		End for each 
	End if 
	
	C_LONGINT:C283($i)
	C_TEXT:C284($keyName)
	
	C_BLOB:C604($stdIn; $stdOut; $stdErr)
	C_LONGINT:C283($pid)
	
	If (OB Instance of:C1731($app; 4D:C1709.Folder))
		
		//bundle, framework, app
		$bundleType:=Substring:C12($app.extension; 2)
		$status[$bundleType]:=$app.path
		
		//look for plist for .app or .bundle
		$infoPlistFile:=$app.folder("Contents").file("Info.plist")
		
		If (Not:C34($infoPlistFile.exists))
			//look for plist for .framework
			$resourcesFolder:=$app.folder("Resources")
			RESOLVE ALIAS:C695($resourcesFolder.platformPath; $resourcesPath)
			$infoPlistFile:=Folder:C1567($resourcesPath; fk platform path:K87:2).file("Info.plist")
		End if 
		
		If (Not:C34($infoPlistFile.exists))
			//look for plist for .framework where Resources is not a symbolic link
			$resourcesFolder:=$app.folder("Resources")
			$infoPlistFile:=$resourcesFolder.file("Info.plist")
		End if 
		
		If ($infoPlistFile.exists) & (Bool:C1537($options.mecab))
			This:C1470._lowercaseExecutableName($infoPlistFile; $keys; $status)
		End if 
		
		If ($infoPlistFile.exists) & (($bundleType="app") | ($bundleType="bundle"))
			This:C1470._updateProperties($infoPlistFile; $keys; $status; (This:C1470.app.path=$app.path))
		End if 
		
	End if 
	
	If (Bool:C1537($options.remove))
		This:C1470._clean($app)
		$command:="codesign --remove-signature "+\
			This:C1470.escape_param($app.fullName)
	Else 
		
		$status:=New object:C1471("success"; False:C215)
		
		If (Bool:C1537($options.local))
			$command:="codesign --verbose --deep "
		Else 
			$command:="codesign --verbose --deep --timestamp "
		End if 
		
		If (Bool:C1537($options.force))
			$command:=$command+"--force "
		End if 
		
		If (Not:C34($hardenedRuntime))
			
			$command:=$command+" --sign "+\
				This:C1470.escape_param(This:C1470.signingIdentity)+" "+\
				This:C1470.escape_param($app.fullName)
			
		Else 
			
			//create entitlements.plist
			$entitlementsFolder:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).folder(Generate UUID:C1066)
			$entitlementsFolder.create()
			$entitlementsFile:=$entitlementsFolder.file("entitlements.plist")
			
			$dom:=DOM Create XML Ref:C861("plist")
			$doctype:=DOM Append XML child node:C1080($dom; XML DOCTYPE:K45:19; "plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"")
			DOM SET XML ATTRIBUTE:C866($dom; "version"; "1.0")
			$dict:=DOM Create XML element:C865($dom; "dict")
			
			If (Bool:C1537($options.sandbox))
				//can't be sandbox because the updater needs access to application
				//$entitlements["com.apple.security.app-sandbox"]:=True
				//$entitlements["com.apple.security.network.client"]:=True
				//$entitlements["com.apple.security.network.server"]:=True
				//$entitlements["com.apple.security.files.user-selected.read-write"]:=True
				//$entitlements["com.apple.security.files.user-selected.executable"]:=True
			Else 
				
				If (This:C1470.isSandBox)
					If (This:C1470.app.path#$app.path)
						$entitlements:=New object:C1471
						$entitlements["com.apple.security.inherit"]:=True:C214
						$entitlements["com.apple.security.app-sandbox"]:=True:C214
					End if 
				End if 
				
			End if 
			
			For each ($key; $entitlements)
				
				Case of 
					: (Value type:C1509($entitlements[$key])=Is text:K8:3)
						DOM SET XML ELEMENT VALUE:C868(DOM Create XML element:C865($dict; "key"); $key)
						DOM SET XML ELEMENT VALUE:C868(DOM Create XML element:C865($dict; "string"); $entitlements[$key])
					: (Value type:C1509($entitlements[$key])=Is boolean:K8:9)
						DOM SET XML ELEMENT VALUE:C868(DOM Create XML element:C865($dict; "key"); $key)
						If (Bool:C1537($entitlements[$key]))
							$value:=DOM Create XML element:C865($dict; "true")
						Else 
							$value:=DOM Create XML element:C865($dict; "false")
						End if 
					: (Value type:C1509($entitlements[$key])=Is collection:K8:32)
						var $keyValues : Collection
						DOM SET XML ELEMENT VALUE:C868(DOM Create XML element:C865($dict; "key"); $key)
						$array:=DOM Create XML element:C865($dict; "array")
						$keyValues:=$entitlements[$key]
						For each ($keyValue; $keyValues)
							DOM SET XML ELEMENT VALUE:C868(DOM Create XML element:C865($array; "string"); $keyValue)
						End for each 
					Else 
						//TODO: string, array, dict...
				End case 
				
			End for each 
			
			ON ERR CALL:C155("ON_PARSE_ERROR")
			DOM EXPORT TO FILE:C862($dom; $entitlementsFile.platformPath)
			ON ERR CALL:C155("")
			
			DOM CLOSE XML:C722($dom)
			
			SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; $entitlementsFile.parent.platformPath)
			SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
			LAUNCH EXTERNAL PROCESS:C811("plutil -convert xml1 "+This:C1470.escape_param($entitlementsFile.fullName); $stdIn; $stdOut; $stdErr; $pid)
			
			$command:=$command+" --options=runtime --entitlements "+\
				This:C1470.escape_param($entitlementsFile.path)+" --sign "+\
				This:C1470.escape_param(This:C1470.signingIdentity)+" "+\
				This:C1470.escape_param($app.fullName)
			
			$status.entitlements:=$entitlements
			
		End if 
		
	End if 
	
	SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; $app.parent.platformPath)
	SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
	
	LAUNCH EXTERNAL PROCESS:C811($command; $stdIn; $stdOut; $stdErr; $pid)
	
	If (BLOB size:C605($stdErr)#0)
		$status.codesign:=Convert to text:C1012($stdErr; "utf-8")
		$status.success:=($status.codesign="@replacing existing signature@")
		$status.success:=$status.success | ($status.codesign="@signed@")  //app bundle, bundle, generic...
		$status.codesign:=Split string:C1554($status.codesign; "\n"; sk ignore empty strings:K86:1 | sk trim spaces:K86:2)
	Else 
		$status.success:=True:C214
	End if 
	
Function _lowercaseExecutableName($infoPlistFile : 4D:C1709.File; $keys : Object; $status : Object)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	If (OB Instance of:C1731($infoPlistFile; 4D:C1709.File))
		
		//correct case mismatch (MeCab vs mecab) which prevents notarisation
		
		var $stdIn; $stdOut; $stdErr : Blob
		
		ON ERR CALL:C155("ON_PARSE_ERROR")
		$dom:=DOM Parse XML source:C719($infoPlistFile.platformPath)
		ON ERR CALL:C155("")
		
		If (OK=1)
			$domKey:=DOM Find XML element:C864($dom; "//key[text()='CFBundleExecutable']")
			If (OK=1)
				var $stringValue : Text
				$domKey:=DOM Get next sibling XML element:C724($domKey)
				DOM GET XML ELEMENT VALUE:C731($domKey; $stringValue)
				DOM SET XML ELEMENT VALUE:C868($domKey; Lowercase:C14($stringValue; *))
			End if 
			
			ON ERR CALL:C155("ON_PARSE_ERROR")
			DOM EXPORT TO FILE:C862($dom; $infoPlistFile.platformPath)
			ON ERR CALL:C155("")
			
			If (OK=1)
				
				$status.success:=True:C214
				$status.plist:=$infoPlistFile.platformPath
				
				SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; $infoPlistFile.parent.platformPath)
				SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
				LAUNCH EXTERNAL PROCESS:C811("plutil -convert xml1 "+This:C1470.escape_param($infoPlistFile.fullName); $stdIn; $stdOut; $stdErr; $pid)
				
				If (Not:C34(Bool:C1537($options.remove)))
					//modification to info.plist makes the signature invalid
					$command:="codesign --verbose --sign "+\
						This:C1470.escape_param(This:C1470.signingIdentity)+" "+\
						This:C1470.escape_param($infoPlistFile.fullName)
					
					SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; $infoPlistFile.parent.platformPath)
					SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
					LAUNCH EXTERNAL PROCESS:C811($command; $stdIn; $stdOut; $stdErr; $pid)
					
					If (BLOB size:C605($stdErr)#0)
						$status.codesign:=Convert to text:C1012($stdErr; "utf-8")
						$status.codesign:=Split string:C1554($status.codesign; "\n"; sk ignore empty strings:K86:1 | sk trim spaces:K86:2)
					End if 
				End if 
				
			End if 
			DOM CLOSE XML:C722($dom)
		End if 
		
	End if 
	
Function _updateProperties($infoPlistFile : 4D:C1709.File; $keys : Object; $status : Object; $isApp : Boolean)->$this : cs:C1710.SignApp
	
	var $stdIn; $stdOut; $stdErr : Blob
	
	$this:=This:C1470
	
	If (OB Instance of:C1731($infoPlistFile; 4D:C1709.File))
		
		$status.plist:=$infoPlistFile.platformPath
		
		ON ERR CALL:C155("ON_PARSE_ERROR")
		$dom:=DOM Parse XML source:C719($infoPlistFile.platformPath)
		ON ERR CALL:C155("")
		
		If (OK=1)
			
			$usageDescriptionKeys:=New collection:C1472(\
				"NSDesktopFolderUsageDescription"; \
				"NSDocumentsFolderUsageDescription"; \
				"NSDownloadsFolderUsageDescription"; \
				"NSRemovableVolumesUsageDescription"; \
				"NSNetworkVolumesUsageDescription")
			
			C_TEXT:C284($dict)
			$dict:=DOM Find XML element:C864($dom; "/plist/dict")
			
			C_TEXT:C284($originalIdentifier)
			
			ARRAY TEXT:C222($domKeys; 0)
			$domKey:=DOM Find XML element:C864($dict; "key"; $domKeys)
			//remove keys we want to write
			For ($i; 1; Size of array:C274($domKeys))
				$domKey:=$domKeys{$i}
				DOM GET XML ELEMENT VALUE:C731($domKey; $keyName)
				If ($keyName="CFBundleIdentifier")
					DOM GET XML ELEMENT VALUE:C731(DOM Get next sibling XML element:C724($domKey); $originalIdentifier)
				End if 
				If ($keys[$keyName]#Null:C1517)
					DOM REMOVE XML ELEMENT:C869(DOM Get next sibling XML element:C724($domKey))
					DOM REMOVE XML ELEMENT:C869($domKey)
				End if 
				
				If ($usageDescriptionKeys.indexOf($keyName)#-1)
					DOM REMOVE XML ELEMENT:C869(DOM Get next sibling XML element:C724($domKey))
					DOM REMOVE XML ELEMENT:C869($domKey)
				End if 
				
			End for 
			
			C_TEXT:C284($applicationGroup)
			ARRAY LONGINT:C221($pos; 0)
			ARRAY LONGINT:C221($len; 0)
			
			If (Match regex:C1019("(?:[^(]+)\\(([A-Z0-9]+)\\)"; This:C1470.signingIdentity; 1; $pos; $len))
				$applicationGroup:=Substring:C12(This:C1470.signingIdentity; $pos{1}; $len{1})
			End if 
			
			If (Value type:C1509(This:C1470.entitlements["com.apple.security.application-groups"])=Is collection:K8:32)
				If (This:C1470.entitlements["com.apple.security.application-groups"].length#0)
					$applicationGroup:=This:C1470.entitlements["com.apple.security.application-groups"][0]
				End if 
			End if 
			
			$prefix:=""
			
			//write keys
			For each ($key; $keys)
				Case of 
					: (Value type:C1509($keys[$key])=Is text:K8:3)
						If ($key="CFBundleIdentifier")
							
							$stringValue:=$originalIdentifier
							
							If (Not:C34($isApp))
								If (This:C1470.isSandBox)
									If (This:C1470.bundleIdentifier#Null:C1517)
										If ($stringValue#(This:C1470.bundleIdentifier+"@"))
											$stringValue:=This:C1470.bundleIdentifier+"."+$stringValue
										End if 
									End if 
								End if 
							Else 
								$stringValue:=$keys[$key]
							End if 
							
						Else 
							$stringValue:=$keys[$key]
						End if 
						DOM SET XML ELEMENT VALUE:C868(DOM Create XML element:C865($dict; "key"); $key)
						DOM SET XML ELEMENT VALUE:C868(DOM Create XML element:C865($dict; "string"); $stringValue)
					: (Value type:C1509($keys[$key])=Is boolean:K8:9)
						DOM SET XML ELEMENT VALUE:C868(DOM Create XML element:C865($dict; "key"); $key)
						If (Bool:C1537($keys[$key]))
							$value:=DOM Create XML element:C865($dict; "true")
						Else 
							$value:=DOM Create XML element:C865($dict; "false")
						End if 
					: (Value type:C1509($keys[$key])=Is collection:K8:32)
						var $keyValues : Collection
						DOM SET XML ELEMENT VALUE:C868(DOM Create XML element:C865($dict; "key"); $key)
						$array:=DOM Create XML element:C865($dict; "array")
						$keyValues:=$keys[$key]
						For each ($keyValue; $keyValues)
							DOM SET XML ELEMENT VALUE:C868(DOM Create XML element:C865($array; "string"); $keyValue)
						End for each 
					Else 
						//dict, etc.
				End case 
			End for each 
			
			ON ERR CALL:C155("ON_PARSE_ERROR")
			DOM EXPORT TO FILE:C862($dom; $infoPlistFile.platformPath)
			ON ERR CALL:C155("")
			
			If (OK=1)
				
				$status.success:=True:C214
				
				SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; $infoPlistFile.parent.platformPath)
				SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
				
				LAUNCH EXTERNAL PROCESS:C811("plutil -convert xml1 "+This:C1470.escape_param($infoPlistFile.fullName); $stdIn; $stdOut; $stdErr)
				
				If (Not:C34(Bool:C1537($options.remove)))
					//modification to info.plist makes the signature invalid
					$command:="codesign --verbose --sign "+\
						This:C1470.escape_param(This:C1470.signingIdentity)+" "+\
						This:C1470.escape_param($infoPlistFile.fullName)
					
					SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; $infoPlistFile.parent.platformPath)
					SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
					LAUNCH EXTERNAL PROCESS:C811($command; $stdIn; $stdOut; $stdErr)
					
					If (BLOB size:C605($stdErr)#0)
						$status.codesign:=Convert to text:C1012($stdErr; "utf-8")
						$status.codesign:=Split string:C1554($status.codesign; "\n"; sk ignore empty strings:K86:1 | sk trim spaces:K86:2)
					End if 
				End if 
			End if 
			DOM CLOSE XML:C722($dom)
		End if 
	End if 
	
Function _clean($app : 4D:C1709.Folder)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	If (OB Instance of:C1731($app; 4D:C1709.Folder))
		
		var $stdIn; $stdOut; $stdErr : Blob
		
		var $CURRENT_DIRECTORY : Text
		
		$CURRENT_DIRECTORY:=$app.platformPath
		
		//recursively remove extended attributes in case of --remove-signature
		SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; $CURRENT_DIRECTORY)
		SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
		LAUNCH EXTERNAL PROCESS:C811("xattr -cr ."; $stdIn; $stdOut; $stdErr)
		
	End if 
	
Function setXcodePath($Xcode : 4D:C1709.Folder)->$this : cs:C1710.SignApp
	
	$this:=This:C1470
	
	Case of 
		: (Count parameters:C259=0)
			This:C1470.ENVIRONMENT.DEVELOPER_DIR:=Null:C1517
		: ($Xcode=Null:C1517)
			This:C1470.ENVIRONMENT.DEVELOPER_DIR:=Null:C1517
		: (OB Instance of:C1731($Xcode; 4D:C1709.Folder))
			If ($Xcode.exists)
				This:C1470.ENVIRONMENT.DEVELOPER_DIR:=$Xcode.path
			End if 
	End case 
	
Function getXcodePath()->$Xcode : Object
	
	$Xcode:=New object:C1471("path"; Null:C1517; "paths"; New collection:C1472)
	
	If (Is macOS:C1572)
		
		C_TEXT:C284($path; $paths)
		
		C_BLOB:C604($stdIn; $stdOut; $stdErr)
		C_LONGINT:C283($pid)
		SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
		LAUNCH EXTERNAL PROCESS:C811("xcode-select -p"; $stdIn; $stdOut; $stdErr; $pid)
		
		$path:=Convert to text:C1012($stdOut; "utf-8")
		
		C_LONGINT:C283($pos)
		C_LONGINT:C283($len)
		
		If (Match regex:C1019("^.+$"; $path; 1; $pos; $len))
			$path:=Substring:C12($path; $pos; $len)
			$Xcode.path:=Folder:C1567($path)
			$Xcode.paths.push($Xcode.path)
		End if 
		
		//spotlight should be enabled for applications
		
		SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
		LAUNCH EXTERNAL PROCESS:C811("mdfind "+This:C1470.escape_param("kMDItemCFBundleIdentifier == 'com.apple.dt.Xcode'"); $stdIn; $stdOut; $stdErr; $pid)
		
		$paths:=Convert to text:C1012($stdOut; "utf-8")
		
		$i:=1
		
		While (Match regex:C1019("(?m)^.+$"; $paths; $i; $pos; $len))
			$path:=Substring:C12($paths; $pos; $len)
			If (Path to object:C1547($path).extension=".app")
				$path:=$path+"/Contents/Developer/"
				If ($Xcode.paths.query("path == :1"; $path).length=0)
					$Xcode.paths.push(Folder:C1567($path))
				End if 
			End if 
			$i:=$pos+$len
		End while 
		
	End if 
	
Function listProviders()->$providers : Collection
	
	$providers:=New collection:C1472
	
	If (Is macOS:C1572)
		$Xcode:=This:C1470.getXcodePath()
		If ($Xcode.paths.length#0)
			$iTMSTransporter:=$Xcode.path.folder("usr").folder("bin").file("iTMSTransporter")
			If (Is macOS:C1572)
				C_BLOB:C604($stdIn; $stdOut; $stdErr)
				C_LONGINT:C283($pid)
				SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_CURRENT_DIRECTORY"; $iTMSTransporter.parent.platformPath)
				SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
				LAUNCH EXTERNAL PROCESS:C811("iTMSTransporter -m provider -u "+This:C1470.escape_param(This:C1470.username)+" -p "+This:C1470.escape_param(This:C1470.password); $stdIn; $stdOut; $stdErr; $pid)
				
				$info:=Convert to text:C1012($stdOut; "utf-8")
				
				ARRAY LONGINT:C221($pos; 0)
				ARRAY LONGINT:C221($len; 0)
				
				If (Match regex:C1019("(?m)^(Provider\\s+listing:)$"; $info; 1; $pos; $len))
					$info:=Substring:C12($info; $pos{1}+$len{1})
					If (Match regex:C1019("(?m)^(\\s*-\\s+Long\\s+Name\\s+-\\s+-\\s+Short\\s+Name\\s+-)$"; $info; 1; $pos; $len))
						$info:=Substring:C12($info; $pos{1}+$len{1})
						C_LONGINT:C283($i)
						$i:=1
						While (Match regex:C1019("(?m)^(\\d+)\\s+(.+)\\s+(\\S+)$"; $info; $i; $pos; $len))
							$providers.push(New object:C1471("id"; Substring:C12($info; $pos{1}; $len{1}); \
								"shortName"; Substring:C12($info; $pos{2}; $len{2}); \
								"longName"; Substring:C12($info; $pos{3}; $len{3})))
							$i:=$pos{3}+$len{3}
						End while 
					End if 
				End if 
			End if 
		End if 
	End if 
	
Function findIdentity()->$identity : Collection
	
	$identity:=New collection:C1472
	
	If (Is macOS:C1572)
		C_BLOB:C604($stdIn; $stdOut; $stdErr)
		C_LONGINT:C283($pid)
		SET ENVIRONMENT VARIABLE:C812("_4D_OPTION_BLOCKING_EXTERNAL_PROCESS"; "TRUE")
		LAUNCH EXTERNAL PROCESS:C811("security find-identity -p basic -v"; $stdIn; $stdOut; $stdErr; $pid)
		
		//basic, to include installer (codesigning does not include it)
		
		$info:=Convert to text:C1012($stdOut; "utf-8")
		
		ARRAY LONGINT:C221($pos; 0)
		ARRAY LONGINT:C221($len; 0)
		C_LONGINT:C283($i)
		$i:=1
		While (Match regex:C1019("(?m)\\s+(\\d+\\))\\s+([:Hex_Digit:]+)\\s+\"([^\"]+)\"$"; $info; $i; $pos; $len))
			$identity.push(New object:C1471("id"; Substring:C12($info; $pos{2}; $len{2}); "name"; Substring:C12($info; $pos{3}; $len{3})))
			$i:=$pos{3}+$len{3}
		End while 
	End if 