//%attributes = {"invisible":true}
/*

TEST passing of user params to On Startup

*/

$project:=File:C1566(Get 4D folder:C485(Database folder:K5:14)+\
"Projects"+Folder separator:K24:12+\
"stub"+Folder separator:K24:12+"Project"+Folder separator:K24:12+\
"stub.4DProject"; fk platform path:K87:2)

$userParams:=New object:C1471

$userParams.project:=$project.path
$userParams.options:=New object:C1471
$userParams.options.targets:=New collection:C1472("x86_64_generic"; "arm64_macOS_lib")
$userParams.options.typeInference:="locals"
$userParams.options.defaultTypeForNumeric:=Is real:K8:4
$userParams.options.defaultTypeForButtons:=Is longint:K8:6
$userParams.options.generateSymbols:=True:C214
$userParams.options.generateTypingMethods:="reset"
$userParams.options.components:=New collection:C1472

$userParam:=$app.encodeObject($userParams)

SET DATABASE PARAMETER:C642(User param value:K37:94; $userParam)

RESTART 4D:C1292