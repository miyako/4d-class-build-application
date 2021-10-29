<!-- Class to build 4D application -->
# BuildApp

Class to build 4D application. Invokes `BUILD APPLICATION`.

Resources: 

* `BuildApp-Template.4DSettings`

Intended scenario:

Build application more efficiently using `4D.Object` instead of XML. Do not over-write the master settings file, instead, use a temporary XML build project file with `BUILD APPLICATION`.

Expose all possible options:

* Every option in v17
* `DatabaseToEmbedInClientMacFolder` (v18)
* `DatabaseToEmbedInClientWinFolder` (v18)
* `AdHocSign` (v19)
* `UseStandardZipFormat` (v20)
* `MacCompiledDatabaseToWin` (v20)
* `MacCompiledDatabaseToWinIncludeIt` (v20)

Set `BUILD APPLICATION` parameters using  Object properties are 

### Remarks 

[Standard XPath implementation](https://doc.4d.com/4Dv19/4D/19/DOM-Find-XML-element.301-5391781.en.html) must be activated.

## Usage

* Load master build settings:

```4d
$buildApp:=cs.BuildApp.new()
```

Settings are loaded from `Get 4D file(Build application settings file; *)`.

* Load blank build settings:

```4d
$buildApp:=cs.BuildApp.new(New object)
```

Settings are created with default values when an instance of `4D.Object` is passed.

* Load existing build settings:

```4d
$buildApp:=cs.BuildApp.new($settingsFile)
```

Settings are loaded from file when an instance of `4D.File` is passed.

* Apply changes directly to `$buildApp.settings`. The property path name mirrors the standard XML key and path.

```4d
$buildApp.settings.BuildApplicationName:="TEST"
$buildApp.settings.BuildApplicationSerialized:=True
$buildApp.settings.BuildMacDestFolder:=Temporary folder+Generate UUID
$buildApp.settings.SourcesFiles.RuntimeVL.RuntimeVLIncludeIt:=True
$buildApp.settings.SourcesFiles.RuntimeVL.RuntimeVLMacFolder:=System folder(Applications or program files)+"4D v19 R3"+Folder separator+"4D Volume Desktop.app"
$buildApp.settings.SignApplication.MacSignature:=False
$buildApp.settings.SignApplication.AdHocSign:=False
```

* Build with custom settings:

```4d
$status:=$buildApp.build()
```

### Utilities

* Open the settings used for the most recent `build()`.

```4d
$buildApp.openProject($appName)
```

Simple wrapper of `OPEN URL`. Can only be called after `build()`. Returns `This` for chaining.

* Update master build settings:

```4d
$buildApp.save()
```

Settings are written to `Get 4D file(Build application settings file; *)`. Returns `This` for chaining.

```4d
$settingsFile:=$buildApp.getDefaultSettingsFile()
```

Returns `Get 4D file(Build application settings file; *)` as `4D.File`.

```4d
$destinationFolder:=$buildApp.getPlatformDestinationFolder()
```

Returns `BuildWinDestFolder` or `BuildMacDestFolder` as `4D.Folder`.

Not implemented: 

* `iconutil` on macOS
