$modulePath = $PSScriptRoot
$subModulePath = @(
    '\DSCResources\CommonHelper.psm1',
    '\DSCResources\IniFile\IniFile.psm1',
    '\DSCResources\JsonFile\JsonFile.psm1',
    '\DSCResources\TextFile\TextFile.psm1'
)

$subModulePath.ForEach( {
        Import-Module (Join-Path $modulePath $_)
    })
