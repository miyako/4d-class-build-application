Class constructor($settingsFile : Object)
	
	This:C1470.settingsFile:=Null:C1517
	
	Case of 
		: (Count parameters:C259=0)
		: (OB Instance of:C1731($settingsFile; 4D:C1709.File))  //use this 4DSettings file
			This:C1470.settingsFile:=$settingsFile
	End case 
	
	If (This:C1470.settingsFile=Null:C1517)
		This:C1470.settingsFile:=This:C1470.getDefaultSettingsFile()  //use default 4DSettings file
	End if 
	
	This:C1470.settings:=This:C1470._getSettings(This:C1470.settingsFile)
	
Function findLicenses($licenseTypes : Collection)->$this : cs:C1710.BuildApp
	
	$this:=This:C1470
	
	var $build : Integer
	var $version; $prefix : Text
	
	$version:=Application version:C493($build)
	
	If (Substring:C12($version; 3; 1)#"0")
		$prefix:="R-"
	Else 
		$prefix:=""
	End if 
	
	$params:=New object:C1471("parameters"; New object:C1471)
	$params.parameters.licenseTypes:=New collection:C1472
	$params.parameters.license4D:=".license4D"
	$versionCode:=Substring:C12($version; 1; 2)+"0"
	For each ($licenseType; $licenseTypes)
		$params.parameters.licenseTypes.push($prefix+$licenseType+$versionCode+"@")
	End for each 
	
	var $files : Collection
	var $file : Object
	
	$files:=Folder:C1567(fk licenses folder:K87:16).files(fk ignore invisible:K87:22).query("name in :licenseTypes and  extension == :license4D"; $params)
	
	Case of 
		: (Is macOS:C1572)
			
			For each ($file; $files)
				This:C1470.settings.Licenses.ArrayLicenseMac.Item.push(Get 4D folder:C485(Licenses folder:K5:11)+$file.fullName)
			End for each 
			
		: (Is Windows:C1573)
			
			For each ($file; $files)
				This:C1470.settings.Licenses.ArrayLicenseWin.Item.push(Get 4D folder:C485(Licenses folder:K5:11)+$file.fullName)
			End for each 
			
	End case 
	
Function getPlatformDestinationFolder()->$folder : 4D:C1709.Folder
	
	If (This:C1470.settings#Null:C1517)
		
		var $settings : Object
		
		$settings:=This:C1470.settings
		
		var $path : Text
		
		Case of 
			: (Is Windows:C1573)
				$path:=$settings.BuildWinDestFolder
			: (Is macOS:C1572)
				$path:=$settings.BuildMacDestFolder
		End case 
		
		If (Substring:C12($path; 1; 1)=Folder separator:K24:12)
			$parentFolderPath:=Folder:C1567(Get 4D folder:C485(Database folder:K5:14); fk platform path:K87:2).parent.parent.platformPath
			$parentFolderPath:=Substring:C12($parentFolderPath; 1; Length:C16($parentFolderPath)-1)
			$parentFolderPath:=$parentFolderPath+Delete string:C232($path; 1; 1)
			$folder:=Folder:C1567($parentFolderPath; fk platform path:K87:2)
		Else 
			$folder:=Folder:C1567($path; fk platform path:K87:2)
		End if 
		
	End if 
	
Function getDefaultSettingsFile()->$settingsFile : 4D:C1709.File
	
	var $buildSettingsFilePath : Text
	
	$buildSettingsFilePath:=Get 4D file:C1418(Build application settings file:K5:60; *)
	
	If ($buildSettingsFilePath#"")
		var $file : 4D:C1709.File
		$file:=File:C1566($buildSettingsFilePath; fk platform path:K87:2)
		If ($file.exists)
			$settingsFile:=$file
		End if 
	End if 
	
Function openProject($appName : Text)->$this : cs:C1710.BuildApp
	
	$this:=This:C1470
	
	If (This:C1470.lastSettingsFile#Null:C1517)
		
		OPEN URL:C673(This:C1470.lastSettingsFile.platformPath; $appName)
		
	End if 
	
Function build()->$status : Object
	
	$status:=New object:C1471("success"; False:C215; "log"; New collection:C1472)
	
	var $file : 4D:C1709.File
	
	$file:=Folder:C1567(fk resources folder:K87:11).file("BuildApp-Template.4DSettings")
	
	If ($file.exists)
		
		$xml:=$file.getText()
		
		PROCESS 4D TAGS:C816($xml; $xml; This:C1470.settings)
		
		$UUID:=Generate UUID:C1066
		
		$settingsFile:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).file($UUID+".4DSettings")
		
		This:C1470.lastSettingsFile:=$settingsFile
		
		$settingsFile.setText($xml; "utf-8"; Document with LF:K24:22)
		
		BUILD APPLICATION:C871($settingsFile.platformPath)
		
		$status.success:=(OK=1)
		
		//this is for the default project
		//$logPath:=Get 4D file(Build application log file; *)
		
		$logPath:=Folder:C1567(fk logs folder:K87:17).file($UUID+".log.xml").platformPath
		
		If (Test path name:C476($logPath)=Is a document:K24:1)
			
			$dom:=DOM Parse XML source:C719($logPath)
			
			If (OK=1)
				
				$BuildApplicationLog:=DOM Find XML element:C864($dom; "/BuildApplicationLog")
				
				ARRAY TEXT:C222($Logs; 0)
				
				$log:=DOM Find XML element:C864($BuildApplicationLog; "Log"; $Logs)
				
				C_TEXT:C284($MessageType; $Target; $CodeDesc; $Message)
				C_LONGINT:C283($CodeId)
				
				For ($i; 1; Size of array:C274($Logs))
					
					$log:=$Logs{$i}
					
					DOM GET XML ELEMENT VALUE:C731(DOM Find XML element:C864($log; "MessageType"); $MessageType)
					DOM GET XML ELEMENT VALUE:C731(DOM Find XML element:C864($log; "Target"); $Target)
					DOM GET XML ELEMENT VALUE:C731(DOM Find XML element:C864($log; "CodeDesc"); $CodeDesc)
					DOM GET XML ELEMENT VALUE:C731(DOM Find XML element:C864($log; "CodeId"); $CodeId)
					DOM GET XML ELEMENT VALUE:C731(DOM Find XML element:C864($log; "Message"); $Message)
					
					$status.log[$i-1]:=New object:C1471(\
						"messageType"; $MessageType; \
						"target"; $Target; \
						"codeDesc"; $CodeDesc; \
						"codeId"; $CodeId; \
						"message"; $Message)
					
				End for 
				
				DOM CLOSE XML:C722($dom)
				
			End if 
			
		End if 
		
	End if 
	
Function save()->$this : cs:C1710.BuildApp
	
	$this:=This:C1470
	
	If ($this.settings#Null:C1517)
		
		var $file : 4D:C1709.File
		
		$file:=Folder:C1567(fk resources folder:K87:11).file("BuildApp-Template.4DSettings")
		
		If ($file.exists)
			
			$xml:=$file.getText()
			
			PROCESS 4D TAGS:C816($xml; $xml; This:C1470.settings)
			
			If (OB Instance of:C1731($this.settingsFile; 4D:C1709.File))
				$this.settingsFile.setText($xml; "utf-8"; Document with LF:K24:22)
			End if 
			
		End if 
		
	End if 
	
Function _getSettings($settingsFile : 4D:C1709.File)->$BuildApp : Object
	
/*
	
added: 
	
v18
	
DatabaseToEmbedInClientMacFolder
DatabaseToEmbedInClientWinFolder
ClientWinSingleInstance*
	
v19
	
AdHocSign
PackProject
ServerStructureFolderName*
ClientServerSystemFolderName*
	
v20
	
UseStandardZipFormat
MacCompiledDatabaseToWin
MacCompiledDatabaseToWinIncludeIt
ClientUserPreferencesFolderByPath*
HideDataExplorerMenuItem*
HideRuntimeExplorerMenuItem*
ServerEmbedsProjectDirectoryFile*
ServerDataCollection*
ShareLocalResourcesOnWindowsClient*
	
*/
	
	$BuildApp:=New object:C1471
	
	$BuildApp:=New object:C1471(\
		"BuildApplicationName"; Null:C1517; \
		"BuildWinDestFolder"; Null:C1517; \
		"BuildMacDestFolder"; Null:C1517; \
		"DataFilePath"; Null:C1517; \
		"BuildApplicationSerialized"; False:C215; \
		"BuildApplicationLight"; False:C215; \
		"IncludeAssociatedFolders"; False:C215; \
		"BuildComponent"; False:C215; \
		"BuildCompiled"; False:C215; \
		"ArrayExcludedPluginName"; New object:C1471("ItemsCount"; Formula:C1597(This:C1470.Item.length); "Item"; New collection:C1472); \
		"ArrayExcludedPluginID"; New object:C1471("ItemsCount"; Formula:C1597(This:C1470.Item.length); "Item"; New collection:C1472); \
		"ArrayExcludedComponentName"; New object:C1471("ItemsCount"; Formula:C1597(This:C1470.Item.length); "Item"; New collection:C1472); \
		"UseStandardZipFormat"; False:C215; \
		"PackProject"; True:C214)
	
	$BuildApp.AutoUpdate:=New object:C1471(\
		"CS"; \
		New object:C1471(\
		"Client"; New object:C1471("StartElevated"; Null:C1517); \
		"ClientUpdateWin"; New object:C1471("StartElevated"; Null:C1517); \
		"Server"; New object:C1471("StartElevated"; Null:C1517)); \
		"RuntimeVL"; New object:C1471("StartElevated"; Null:C1517))
	
	$BuildApp.CS:=New object:C1471(\
		"BuildServerApplication"; False:C215; \
		"BuildCSUpgradeable"; False:C215; \
		"BuildV13ClientUpgrades"; False:C215; \
		"IPAddress"; Null:C1517; \
		"PortNumber"; Null:C1517; \
		"HardLink"; Null:C1517; \
		"RangeVersMin"; 1; \
		"RangeVersMax"; 1; \
		"CurrentVers"; 1; \
		"LastDataPathLookup"; Null:C1517; \
		"ServerSelectionAllowed"; False:C215; \
		"ServerStructureFolderName"; Null:C1517; \
		"ClientServerSystemFolderName"; Null:C1517; \
		"ClientWinSingleInstance"; False:C215; \
		"ServerEmbedsProjectDirectoryFile"; False:C215; \
		"ServerDataCollection"; False:C215; \
		"HideDataExplorerMenuItem"; False:C215; \
		"HideRuntimeExplorerMenuItem"; False:C215; \
		"ClientUserPreferencesFolderByPath"; False:C215; \
		"ShareLocalResourcesOnWindowsClient"; False:C215; \
		"MacCompiledDatabaseToWin"; Null:C1517; \
		"MacCompiledDatabaseToWinIncludeIt"; False:C215)
	
	$BuildApp.Licenses:=New object:C1471(\
		"ArrayLicenseWin"; New object:C1471("ItemsCount"; Formula:C1597(This:C1470.Item.length); "Item"; New collection:C1472); \
		"ArrayLicenseMac"; New object:C1471("ItemsCount"; Formula:C1597(This:C1470.Item.length); "Item"; New collection:C1472))
	
	$BuildApp.RuntimeVL:=New object:C1471("LastDataPathLookup"; "ByAppName")
	
	$BuildApp.SignApplication:=New object:C1471("MacSignature"; Null:C1517; "MacCertificate"; Null:C1517; "AdHocSign"; Null:C1517)
	
	$BuildApp.SourcesFiles:=New object:C1471(\
		"RuntimeVL"; New object:C1471(\
		"RuntimeVLIncludeIt"; False:C215; \
		"RuntimeVLWinFolder"; Null:C1517; \
		"RuntimeVLMacFolder"; Null:C1517; \
		"RuntimeVLIconWinPath"; Null:C1517; \
		"RuntimeVLIconMacPath"; Null:C1517; \
		"IsOEM"; False:C215); \
		"CS"; New object:C1471(\
		"ServerIncludeIt"; False:C215; \
		"ServerWinFolder"; Null:C1517; \
		"ServerMacFolder"; Null:C1517; \
		"ClientWinIncludeIt"; False:C215; \
		"ClientWinFolderToWin"; Null:C1517; \
		"ClientWinFolderToMac"; Null:C1517; \
		"ClientMacIncludeIt"; False:C215; \
		"ClientMacFolderToWin"; Null:C1517; \
		"ClientMacFolderToMac"; Null:C1517; \
		"ServerIconWinPath"; Null:C1517; \
		"ServerIconMacPath"; Null:C1517; \
		"ClientMacIconForMacPath"; Null:C1517; \
		"ClientWinIconForMacPath"; Null:C1517; \
		"ClientMacIconForWinPath"; Null:C1517; \
		"ClientWinIconForWinPath"; Null:C1517; \
		"DatabaseToEmbedInClientWinFolder"; Null:C1517; \
		"DatabaseToEmbedInClientMacFolder"; Null:C1517; \
		"IsOEM"; False:C215))
	
	$BuildApp.Versioning:=New object:C1471(\
		"Common"; New object:C1471(\
		"CommonVersion"; Null:C1517; \
		"CommonCopyright"; Null:C1517; \
		"CommonCreator"; Null:C1517; \
		"CommonComment"; Null:C1517; \
		"CommonCompanyName"; Null:C1517; \
		"CommonFileDescription"; Null:C1517; \
		"CommonInternalName"; Null:C1517; \
		"CommonLegalTrademark"; Null:C1517; \
		"CommonPrivateBuild"; Null:C1517; \
		"CommonSpecialBuild"; Null:C1517); \
		"RuntimeVL"; New object:C1471(\
		"RuntimeVLVersion"; Null:C1517; \
		"RuntimeVLCopyright"; Null:C1517; \
		"RuntimeVLCreator"; Null:C1517; \
		"RuntimeVLComment"; Null:C1517; \
		"RuntimeVLCompanyName"; Null:C1517; \
		"RuntimeVLFileDescription"; Null:C1517; \
		"RuntimeVLInternalName"; Null:C1517; \
		"RuntimeVLLegalTrademark"; Null:C1517; \
		"RuntimeVLPrivateBuild"; Null:C1517; \
		"RuntimeVLSpecialBuild"; Null:C1517); \
		"Server"; New object:C1471(\
		"ServerVersion"; Null:C1517; \
		"ServerCopyright"; Null:C1517; \
		"ServerCreator"; Null:C1517; \
		"ServerComment"; Null:C1517; \
		"ServerCompanyName"; Null:C1517; \
		"ServerFileDescription"; Null:C1517; \
		"ServerInternalName"; Null:C1517; \
		"ServerLegalTrademark"; Null:C1517; \
		"ServerPrivateBuild"; Null:C1517; \
		"ServerSpecialBuild"; Null:C1517); \
		"Client"; New object:C1471(\
		"ClientVersion"; Null:C1517; \
		"ClientCopyright"; Null:C1517; \
		"ClientCreator"; Null:C1517; \
		"ClientComment"; Null:C1517; \
		"ClientCompanyName"; Null:C1517; \
		"ClientFileDescription"; Null:C1517; \
		"ClientInternalName"; Null:C1517; \
		"ClientLegalTrademark"; Null:C1517; \
		"ClientPrivateBuild"; Null:C1517; \
		"ClientSpecialBuild"; Null:C1517))
	
	If (OB Instance of:C1731($settingsFile; 4D:C1709.File))
		
		If ($settingsFile.exists)
			
			$path:=$settingsFile.platformPath
			
			C_LONGINT:C283($intValue)
			C_TEXT:C284($stringValue)
			C_BOOLEAN:C305($boolValue)
			
			ARRAY TEXT:C222($linkModes; 3)
			$linkModes{1}:="InDbStruct"
			$linkModes{2}:="ByAppName"
			$linkModes{3}:="ByAppPath"
			
			$dom:=DOM Parse XML source:C719($path)
			
			If (OK=1)
				
				$BuildApplicationName:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/BuildApplicationName")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildApplicationName; $stringValue)
					$BuildApp.BuildApplicationName:=$stringValue
				End if 
				
				$BuildCompiled:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/BuildCompiled")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildCompiled; $boolValue)
					$BuildApp.BuildCompiled:=$boolValue
				End if 
				
				$IncludeAssociatedFolders:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/IncludeAssociatedFolders")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($IncludeAssociatedFolders; $boolValue)
					$BuildApp.IncludeAssociatedFolders:=$boolValue
				End if 
				
				$BuildComponent:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/BuildComponent")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildComponent; $boolValue)
					$BuildApp.BuildComponent:=$boolValue
				End if 
				
				$BuildApplicationSerialized:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/BuildApplicationSerialized")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildApplicationSerialized; $boolValue)
					$BuildApp.BuildApplicationSerialized:=$boolValue
				End if 
				
				$BuildApplicationLight:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/BuildApplicationLight")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildApplicationLight; $boolValue)
					$BuildApp.BuildApplicationLight:=$boolValue
				End if 
				
				$BuildMacDestFolder:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/BuildMacDestFolder")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildMacDestFolder; $stringValue)
					$BuildApp.BuildMacDestFolder:=$stringValue
				End if 
				
				$PackProject:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/PackProject")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($PackProject; $boolValue)
					$BuildApp.PackProject:=$boolValue
				End if 
				
				$UseStandardZipFormat:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/UseStandardZipFormat")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($UseStandardZipFormat; $boolValue)
					$BuildApp.UseStandardZipFormat:=$boolValue
				End if 
				
				$BuildWinDestFolder:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/BuildWinDestFolder")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildWinDestFolder; $stringValue)
					$BuildApp.BuildWinDestFolder:=$stringValue
				End if 
				
				$RuntimeVLIncludeIt:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/RuntimeVL/RuntimeVLIncludeIt")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($RuntimeVLIncludeIt; $boolValue)
					$BuildApp.SourcesFiles.RuntimeVL.RuntimeVLIncludeIt:=$boolValue
				End if 
				
				$RuntimeVLMacFolder:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/RuntimeVL/RuntimeVLMacFolder")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($RuntimeVLMacFolder; $stringValue)
					$BuildApp.SourcesFiles.RuntimeVL.RuntimeVLMacFolder:=$stringValue
				End if 
				
				$RuntimeVLWinFolder:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/RuntimeVL/RuntimeVLWinFolder")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($RuntimeVLWinFolder; $stringValue)
					$BuildApp.SourcesFiles.RuntimeVL.RuntimeVLWinFolder:=$stringValue
				End if 
				
				$IsOEM:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/RuntimeVL/IsOEM")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($IsOEM; $boolValue)
					$BuildApp.SourcesFiles.RuntimeVL.IsOEM:=$boolValue
				End if 
				
				$IsOEM:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/RuntimeVL/IsOEM")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($IsOEM; $boolValue)
					$BuildApp.SourcesFiles.RuntimeVL.IsOEM:=$boolValue
				End if 
				
				$ServerIncludeIt:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ServerIncludeIt")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ServerIncludeIt; $boolValue)
					$BuildApp.SourcesFiles.CS.ServerIncludeIt:=$boolValue
				End if 
				
				$ClientMacIncludeIt:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientMacIncludeIt")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientMacIncludeIt; $boolValue)
					$BuildApp.SourcesFiles.CS.ClientMacIncludeIt:=$boolValue
				End if 
				
				$ClientWinIncludeIt:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientWinIncludeIt")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientWinIncludeIt; $boolValue)
					$BuildApp.SourcesFiles.CS.ClientWinIncludeIt:=$boolValue
				End if 
				
				$ServerMacFolder:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ServerMacFolder")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ServerMacFolder; $stringValue)
					$BuildApp.SourcesFiles.CS.ServerMacFolder:=$stringValue
				End if 
				
				$ServerWinFolder:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ServerWinFolder")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ServerWinFolder; $stringValue)
					$BuildApp.SourcesFiles.CS.ServerWinFolder:=$stringValue
				End if 
				
				$ClientWinFolderToWin:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientWinFolderToWin")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientWinFolderToWin; $stringValue)
					$BuildApp.SourcesFiles.CS.ClientWinFolderToWin:=$stringValue
				End if 
				
				$ClientWinFolderToMac:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientWinFolderToMac")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientWinFolderToMac; $stringValue)
					$BuildApp.SourcesFiles.CS.ClientWinFolderToMac:=$stringValue
				End if 
				
				$ClientMacFolderToWin:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientMacFolderToWin")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientMacFolderToWin; $stringValue)
					$BuildApp.SourcesFiles.CS.ClientMacFolderToWin:=$stringValue
				End if 
				
				$ClientMacFolderToMac:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientMacFolderToMac")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientMacFolderToMac; $stringValue)
					$BuildApp.SourcesFiles.CS.ClientMacFolderToMac:=$stringValue
				End if 
				
				$ServerIconWinPath:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ServerIconWinPath")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ServerIconWinPath; $stringValue)
					$BuildApp.SourcesFiles.CS.ServerIconWinPath:=$stringValue
				End if 
				
				$ServerIconMacPath:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ServerIconMacPath")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ServerIconMacPath; $stringValue)
					$BuildApp.SourcesFiles.CS.ServerIconMacPath:=$stringValue
				End if 
				
				$ClientMacIconForMacPath:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientMacIconForMacPath")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientMacIconForMacPath; $stringValue)
					$BuildApp.SourcesFiles.CS.ClientMacIconForMacPath:=$stringValue
				End if 
				
				$ClientWinIconForMacPath:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientWinIconForMacPath")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientWinIconForMacPath; $stringValue)
					$BuildApp.SourcesFiles.CS.ClientWinIconForMacPath:=$stringValue
				End if 
				
				$ClientMacIconForWinPath:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientMacIconForWinPath")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientMacIconForWinPath; $stringValue)
					$BuildApp.SourcesFiles.CS.ClientMacIconForWinPath:=$stringValue
				End if 
				
				$ClientWinIconForWinPath:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/ClientWinIconForWinPath")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ClientWinIconForWinPath; $stringValue)
					$BuildApp.SourcesFiles.CS.ClientWinIconForWinPath:=$stringValue
				End if 
				
				$ToEmbedInClientMacFolder:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/DatabaseToEmbedInClientMacFolder")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ToEmbedInClientMacFolder; $stringValue)
					$BuildApp.SourcesFiles.CS.DatabaseToEmbedInClientMacFolder:=$stringValue
				End if 
				
				$ToEmbedInClientWinFolder:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/DatabaseToEmbedInClientWinFolder")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ToEmbedInClientWinFolder; $stringValue)
					$BuildApp.SourcesFiles.CS.DatabaseToEmbedInClientWinFolder:=$stringValue
				End if 
				
				$IsOEM:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SourcesFiles/CS/IsOEM")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($IsOEM; $boolValue)
					$BuildApp.SourcesFiles.RuntimeVL.IsOEM:=$boolValue
				End if 
				
				$BuildServerApplication:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/BuildServerApplication")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildServerApplication; $boolValue)
					$BuildApp.CS.BuildServerApplication:=$boolValue
				End if 
				
				$LastDataPathLookup:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/LastDataPathLookup")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($LastDataPathLookup; $stringValue)
					If (Find in array:C230($linkModes; $stringValue)#-1)
						$BuildApp.CS.LastDataPathLookup:=$stringValue
					End if 
				End if 
				
				$BuildCSUpgradeable:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/BuildCSUpgradeable")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildCSUpgradeable; $boolValue)
					$BuildApp.CS.BuildCSUpgradeable:=$boolValue
				End if 
				
				$CurrentVers:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/CurrentVers")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($CurrentVers; $intValue)
					If ($intValue>0)
						$BuildApp.CS.CurrentVers:=$intValue
					End if 
				End if 
				
				$HardLink:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/HardLink")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($HardLink; $stringValue)
					$BuildApp.CS.HardLink:=$stringValue
				End if 
				
				$BuildV13ClientUpgrades:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/BuildV13ClientUpgrades")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($BuildV13ClientUpgrades; $boolValue)
					$BuildApp.CS.BuildV13ClientUpgrades:=$boolValue
				End if 
				
				$IPAddress:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/IPAddress")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($IPAddress; $stringValue)
					$BuildApp.CS.IPAddress:=$stringValue
				End if 
				
				$PortNumber:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/PortNumber")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($PortNumber; $intValue)
					$BuildApp.CS.PortNumber:=$intValue
				End if 
				
				$RangeVersMin:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/RangeVersMin")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($RangeVersMin; $intValue)
					If ($intValue>0)
						$BuildApp.CS.RangeVersMin:=$intValue
					End if 
				End if 
				
				$RangeVersMax:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/RangeVersMax")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($RangeVersMax; $intValue)
					If ($intValue>0)
						$BuildApp.CS.RangeVersMax:=$intValue
					End if 
				End if 
				
				$ServerSelectionAllowed:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/ServerSelectionAllowed")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($ServerSelectionAllowed; $boolValue)
					$BuildApp.CS.ServerSelectionAllowed:=$boolValue
				End if 
				
				$MacCompiledDatabaseToWin:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/MacCompiledDatabaseToWin")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($MacCompiledDatabaseToWin; $stringValue)
					$BuildApp.CS.MacCompiledDatabaseToWin:=$stringValue
				End if 
				
				$MacCompiledDatabaseToWinInclude:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/CS/MacCompiledDatabaseToWinIncludeIt")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($MacCompiledDatabaseToWinInclude; $boolValue)
					$BuildApp.CS.MacCompiledDatabaseToWinIncludeIt:=$boolValue
				End if 
				
				$MacSignature:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SignApplication/MacSignature")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($MacSignature; $boolValue)
					$BuildApp.SignApplication.MacSignature:=$boolValue
				End if 
				
				$MacCertificate:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SignApplication/MacCertificate")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($MacCertificate; $stringValue)
					$BuildApp.SignApplication.MacCertificate:=$stringValue
				End if 
				
				$AdHocSign:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/SignApplication/AdHocSign")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($AdHocSign; $boolValue)
					$BuildApp.SignApplication.AdHocSign:=$boolValue
				End if 
				
				$LastDataPathLookup:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/RuntimeVL/LastDataPathLookup")
				
				If (OK=1)
					DOM GET XML ELEMENT VALUE:C731($LastDataPathLookup; $stringValue)
					If (Find in array:C230($linkModes; $stringValue)#-1)
						$BuildApp.RuntimeVL.LastDataPathLookup:=$stringValue
					End if 
				End if 
				
				ARRAY TEXT:C222($names; 0)
				OB GET PROPERTY NAMES:C1232($BuildApp.Licenses; $names)
				
				For ($i; 1; Size of array:C274($names))
					$name:=$names{$i}
					$ItemsCount:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/Licenses/"+$name+"/ItemsCount")
					If (OK=1)
						//BuildApp.Licenses{$name}.ItemsCount
						//BuildApp.Licenses{$name}.Item[]
						DOM GET XML ELEMENT VALUE:C731($ItemsCount; $intValue)
						ARRAY OBJECT:C1221($DatabaseNames; $intValue)
						//$BuildApp.Licenses[$name].ItemsCount:=$intValue
						$Item:=DOM Get next sibling XML element:C724($ItemsCount)
						For ($j; 0; $intValue-1)  //0 based index
							DOM GET XML ELEMENT VALUE:C731($Item; $stringValue)
							$BuildApp.Licenses[$name].Item[$j]:=Choose:C955($stringValue=""; Null:C1517; $stringValue)
							$Item:=DOM Get next sibling XML element:C724($Item)
						End for 
					End if 
				End for 
				
				ARRAY TEXT:C222($names; 3)
				
				$names{1}:="ArrayExcludedPluginName"
				$names{2}:="ArrayExcludedPluginID"
				$names{3}:="ArrayExcludedComponentName"
				
				For ($i; 1; Size of array:C274($names))
					$name:=$names{$i}
					$ItemsCount:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/"+$name+"/ItemsCount")
					If (OK=1)
						DOM GET XML ELEMENT VALUE:C731($ItemsCount; $intValue)
						ARRAY OBJECT:C1221($DatabaseNames; $intValue)
						//$BuildApp[$name].ItemsCount:=$intValue
						$Item:=DOM Get next sibling XML element:C724($ItemsCount)
						For ($j; 0; $intValue-1)  //0 based index
							DOM GET XML ELEMENT VALUE:C731($Item; $stringValue)
							$BuildApp[$name].Item[$j]:=Choose:C955($stringValue=""; Null:C1517; $stringValue)
							$Item:=DOM Get next sibling XML element:C724($Item)
						End for 
					End if 
				End for 
				
				OB GET PROPERTY NAMES:C1232($BuildApp.Versioning; $names)
				$Versioning:=DOM Find XML element:C864($dom; "/Preferences4D/BuildApp/Versioning")
				
				If (OK=1)
					
					For ($i; 1; Size of array:C274($names))
						$name:=$names{$i}
						$parent:=DOM Find XML element:C864($Versioning; $name)
						ARRAY TEXT:C222($itemNames; 0)
						OB GET PROPERTY NAMES:C1232($BuildApp.Versioning[$name]; $itemNames)
						For ($j; 1; Size of array:C274($itemNames))
							$itemName:=$itemNames{$j}
							$child:=DOM Find XML element:C864($parent; $itemName)
							If (OK=1)
								DOM GET XML ELEMENT VALUE:C731($child; $stringValue)
								$BuildApp.Versioning[$name][$itemName]:=$stringValue
							End if 
							
						End for 
						
					End for 
					
				End if 
				
				DOM CLOSE XML:C722($dom)
				
			End if 
			
		End if 
		
	End if 
	
Function buildComponent($name : Text)->$that : cs:C1710.BuildApp
	
	$that:=This:C1470
	
	$databaseFolder:=Folder:C1567(Get 4D folder:C485(Database folder:K5:14; *); fk platform path:K87:2)
	
	If (Count parameters:C259=0)
		$BuildApplicationName:=$databaseFolder.name
	Else 
		$BuildApplicationName:=$name
	End if 
	
	$settings:=This:C1470.settings
	
	$settings.UseStandardZipFormat:=False:C215
	
	$settings.CS.BuildServerApplication:=False:C215
	$settings.CS.BuildCSUpgradeable:=False:C215
	$settings.CS.BuildV13ClientUpgrades:=False:C215
	$settings.CS.MacCompiledDatabaseToWinIncludeIt:=False:C215
	$settings.CS.ServerSelectionAllowed:=False:C215
	
	$settings.SourcesFiles.CS.ClientMacIncludeIt:=False:C215
	$settings.SourcesFiles.CS.ClientWinIncludeIt:=False:C215
	$settings.SourcesFiles.CS.ServerIncludeIt:=False:C215
	$settings.SourcesFiles.CS.IsOEM:=False:C215
	
	$settings.SourcesFiles.RuntimeVLIncludeIt:=False:C215
	$settings.SourcesFiles.RuntimeVL.IsOEM:=False:C215
	
	$settings.BuildComponent:=True:C214
	$settings.BuildCompiled:=False:C215
	$settings.BuildApplicationSerialized:=False:C215
	$settings.BuildApplicationLight:=False:C215
	$settings.BuildApplicationName:=$BuildApplicationName
	$settings.BuildMacDestFolder:=$databaseFolder.parent.parent.platformPath
	
	$settings.SignApplication.MacSignature:=False:C215
	$settings.SignApplication.AdHocSign:=False:C215
	
	$settings.PackProject:=True:C214
	$settings.IncludeAssociatedFolders:=True:C214
	
	$status:=This:C1470.build()
	
Function getAppFolderForVersion()->$folder : 4D:C1709.Folder
	
	$version:=Application version:C493($build)
	If (Substring:C12($version; 3; 1)="0")
		$folderName:="4D v"+Substring:C12($version; 1; 2)+"."+Substring:C12($version; 4; 1)
	Else 
		$folderName:="4D v"+Substring:C12($version; 1; 2)+" R"+Substring:C12($version; 3; 1)
	End if 
	
	$folder:=Folder:C1567(fk applications folder:K87:20).folder($folderName)