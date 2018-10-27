$modulePath = $PSScriptRoot
$subModulePath = @(
    '\DSCResources\IniFile\IniFile.psm1',
    '\DSCResources\JsonFile\JsonFile.psm1',
    '\DSCResources\TxtFile\TxtFile.psm1'
)

$subModulePath.ForEach( {
        Import-Module (Join-Path $modulePath $_)
    })
