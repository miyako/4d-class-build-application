![version](https://img.shields.io/badge/version-19%2B-4371C6)
[![license](https://img.shields.io/github/license/miyako/4d-class-build-application
)](LICENSE)

# 4d-class-build-application
Classes to build, sign, archive, notarise and staple an app.

* [BuildApp](https://github.com/miyako/4d-class-build-application/blob/main/compiler/compiler/Documentation/Classes/BuildApp.md)
* [SignApp](https://github.com/miyako/4d-class-build-application/blob/main/compiler/compiler/Documentation/Classes/SignApp.md)

The project itself is a generic compiler application. See [On Startup](https://github.com/miyako/4d-class-build-application/blob/main/compiler/compiler/Project/Sources/DatabaseMethods/onStartup.4dm). 

## Usage with GitHub Actions

Example workflow [here](https://github.com/4D-JP/librezept/blob/main/.github/workflows/compile.yml).

c.f. [Learn GitHub Actions](https://docs.github.com/en/actions/learn-github-actions)

### Points of Interest

```yml
on:
  push:
    branches: [ main ]
    paths:
    - 'Project/*'
``` 

[`push`](https://docs.github.com/en/actions/learn-github-actions/events-that-trigger-workflows#push) event on `main` branch triggers the workflow. Limit to contents of the `Project` folder. Remember to quote the path since the forward slash is a metacharacter.

Create a copy of 4D.app. Register its download URL as a GitHub Secret, for example as `URL_4D_19_272594_LTS`.

c.f. [Encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

The first part of the job runs a shell script:

```yml
jobs:
  compile:
    runs-on: macos-latest
    steps:
      - name: checkout
        uses: actions/checkout@v2
      - name: compile project
        run: |
          ./main.sh ${{ secrets.URL_4D_19_272594_LTS }}
```

The [`main.sh`](https://github.com/4D-JP/librezept/blob/main/main.sh) shell script does the following:

* Download 4D.dmg from `URL_4D_19_272594_LTS`
* Mount disk image 
* Copy app to current directory
* Clone this project to `./compiler`
* Launch this project in headless mode to run `Compile project` on GitHub
* Unmount disk image
* Delete 4D.app
* Delete 4D.dmg
* Delete this project

The second part of the job commits the compiled product back to the repository:

```yml
      - name: commit
        run: |
            git config --global user.name '4D-JP'
            git config --global user.email '4D-JP@users.noreply.github.com'
            git remote set-url origin https://x-access-token:${{ secrets.GITHUB_TOKEN }}@github.com/$GITHUB_REPOSITORY
            git add -A
            git commit -m "Automated Compilation"
            git push
```

## Build Application

```4d
var $buildApp : cs.BuildApp

$buildApp:=cs.BuildApp.new(New object)

$buildApp.settings.BuildApplicationName:="TEST"
$buildApp.settings.BuildApplicationSerialized:=True
$buildApp.settings.BuildMacDestFolder:=Temporary folder+Generate UUID
$buildApp.settings.SourcesFiles.RuntimeVL.RuntimeVLIncludeIt:=True
$buildApp.settings.SourcesFiles.RuntimeVL.RuntimeVLMacFolder:=System folder(Applications or program files)+"4D v19 R3"+Folder separator+"4D Volume Desktop.app"
$buildApp.settings.SignApplication.MacSignature:=False
$buildApp.settings.SignApplication.AdHocSign:=False

$buildApp.settings.Licenses.ArrayLicenseMac.Item.push(Get 4D folder(Licenses folder)+"R-4UUD190UUS001XXXXXXXXXX.license4D")
$buildApp.settings.Licenses.ArrayLicenseMac.Item.push(Get 4D folder(Licenses folder)+"R-4DDP190UUS001XXXXXXXXXX.license4D")

$status:=$buildApp.build()
```

## Sign, Archive, Notarise, Staple Application

```4d
var $signApp : cs.SignApp

$credentials:=New object
$credentials.username:="keisuke.miyako@4d.com"  //apple ID
$credentials.password:="@keychain:altool"  //app specific password or keychain label; must be literal to use listProviders()

$signApp:=cs.SignApp.new($credentials)

$buildApp.build()

$app:=$buildApp.getPlatformDestinationFolder().folder("Final Application").folder($buildApp.settings.BuildApplicationName+".app")

$statusus:=$signApp.sign($app)

$status:=$signApp.archive($app)

If ($status.success)
	$status:=$signApp.notarize($status.file)
End if 
```
