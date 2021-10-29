<!-- Class to launch an external app-->
# App

Class to launch an external app. Invokes `open` (macOS) or `cmd start` (Windows) via `LAUNCH EXTERNAL PROCESS`. 

Project methods:

* `escape_param`

Intended scenario: 

* Launch 4D with no license installed (Interpreted Desktop mode) and open a generic project that executes "compile project" according to parameters passed through `--user-params`. 

### Remarks 

[Standard XPath implementation](https://doc.4d.com/4Dv19/4D/19/DOM-Find-XML-element.301-5391781.en.html) must be activated for `_getBundleExecutable`.

## Usage

* Pass a `Folder` on macOS:

```4d
$file:=Folder(fk system folder).folder("Applications").folder("TextEdit.app")
$app:=cs.App.new($app)
```

**Note**: `Folder(fk applications folder)` on macOS returns the user application folder.

* Pass a `File` on macOS:

```4d
$file:=Folder(fk system folder).folder("Applications").folder("TextEdit.app").folder("Contents").folder("MacOS").file("TextEdit")
$app:=cs.App.new($file)
```

* Pass a `File` on Windows:

Same as macOS.

### Launch the app with arguments

```4d
$status:=$app.open(New collection("--headless"; "--dataless"; "--user-param"; $userParam))
```
Waits for the app to complete (`_4D_OPTION_BLOCKING_EXTERNAL_PROCESS` is `TRUE`).

### Utilities

* Base64 encode an object:

```4d
$encodedObject:=$app.encodeObject($object)
```

Not implemented: 

* handle `pid`
* asynchronous launch
