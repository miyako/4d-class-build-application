//%attributes = {"invisible":true}
/*

TEST passing of user params to On Startup

*/

$project:="Project/librezept.4DProject"

$userParams:=New object:C1471

$userParams.project:=$project
$userParams.options:=New object:C1471
$userParams.options.targets:=New collection:C1472("x86_64_generic"; "arm64_macOS_lib")
$userParams.options.typeInference:="locals"
$userParams.options.defaultTypeForNumeric:=Is real:K8:4
$userParams.options.defaultTypeForButtons:=Is longint:K8:6
$userParams.options.generateSymbols:=True:C214
$userParams.options.generateTypingMethods:="reset"
$userParams.options.components:=New collection:C1472

$app:=cs:C1710.App.new()

$userParam:=$app.encodeObject($userParams)

SET TEXT TO PASTEBOARD:C523($userParam)

SET DATABASE PARAMETER:C642(User param value:K37:94; $userParam)

RESTART 4D:C1292