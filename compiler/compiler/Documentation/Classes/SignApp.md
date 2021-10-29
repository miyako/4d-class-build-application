<!-- Class to sign, archive, notarise and staple an app -->
# SignApp

Class to sign, archive, notarise and staple an app. See article "[Customizing the Notarization Workflow](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution/customizing_the_notarization_workflow)".

Project methods:

* `escape_param`

Intended scenario: 

* Procedurally sign 4D, 4D Server or merged applications.

Prerequisites

* [macOS 10.14.5](https://developer.apple.com/jp/news/?id=04102019a) or later
* [Apple ID 2-factor authentication](https://support.apple.com/ja-jp/HT204915)
* [App specific password](https://support.apple.com/ja-jp/HT204397) strongly recommeded
* [Apple Developer Program](https://developer.apple.com/jp/programs/) membership
* Xcode 10 or later (`xcrun`)
* Apple Developer ID Application identity
* Apple Developer ID Installer identity (`.pkg` archive only)

### Remarks 

[Standard XPath implementation](https://doc.4d.com/4Dv19/4D/19/DOM-Find-XML-element.301-5391781.en.html) must be activated for `_getBundleExecutable`.

## Usage

* Set credentials

```4d
$credentials:=New object
$credentials.username:="keisuke.miyako@4d.com"  //apple ID
$credentials.password:="@keychain:altool"  //app specific password or keychain label
$signApp:=cs.SignApp.new($credentials)
```

* Sign

```4d
$app:=Folder("Macintosh HD:Applications:4D v18.5:271605:4D.app"; fk platform path)
$statusus:=$signApp.sign($app)
```

* Arvhive

```4d
//$signApp.archiveFormat:=".zip"
//$signApp.archiveFormat:=".pkg"
$signApp.archiveFormat:=".dmg"
$status:=$signApp.archive($app)
```

* Notarise and Staple

```4d
$status:=$signApp.notarize($status.file)
```

### Utilities

```4d
$Xcode:=$signApp.getXcodePath()
```

`$Xcode.path` is the current Xcode (`xcode-select -p`).  `$Xcode.paths` is a collection of Xcode applications found by Spotlight (`mdfind kMDItemCFBundleIdentifier == 'com.apple.dt.Xcode'`). 

```4d
$signApp.setXcodePath($Xcode)
```

Used to set the `DEVELOPER_DIR` environment variable before `xcrun`.

```4d
$providers:=$signApp.listProviders()
```

List identifiers associated with Apple ID. `$signApp` must be instantiated with clear password i.e. not `@keychain:{label}`.

```4d
$status:=$signApp.notarizationInfo($RequestUUID)
```

Obtain information about a particular submission.

Not implemented: 

* adhoc sign
