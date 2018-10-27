#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
Import-Module (Join-Path $script:moduleRoot '\DSCResources\IniFile\IniFile.psm1') -Force
Import-Module (Join-Path $PSScriptRoot '\TestHelper\TestHelper.psm1') -Force
#endregion HEADER

# Begin Testing
InModuleScope 'IniFile' {
    #region Set variables for testing

    $ExistMock = 'Exist.ini'
    $NonExistMock = 'NonExist.ini'

    $MockIniFile1 = @"
Key1=Value1
Key2=Value2
Key3=
[SectionA]
KeySA1=ValueSA1
KeySA2=ValueSA2
[SectionB]

"@

    $MockIniObject1 = [ordered]@{
        _ROOT_   = [ordered]@{
            Key1 = 'Value1'
            Key2 = 'Value2'
            Key3 = ''
        }

        SectionA = [ordered]@{
            KeySA1 = 'ValueSA1'
            KeySA2 = 'ValueSA2'
        }

        SectionB = [ordered]@{}
    }

    #endregion Set variables for testing

    #region Tests for Get-TargetResource
    Describe 'IniFile/Get-TargetResource' {

        Mock Get-IniFile {
            return $MockIniObject1
        }

        Mock Test-Path {$true} -ParameterFilter {$Path -eq $ExistMock}
        Mock Test-Path {$false} -ParameterFilter {$Path -eq $NonExistMock}

        Context 'Ensure = Present' {


            It 'Get exist Key Value Pair, with ROOT section' {
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $ExistMock
                    Key     = 'Key1'
                    Section = ''
                }

                $result = Get-TargetResource @getParam
                $result.Ensure | Should -Be 'Present'
                $result.Path | Should -Be $getParam.Path
                $result.Key | Should -Be $getParam.Key
                $result.Value | Should -Be 'Value1'
                $result.Section | Should -Be ''
            }


            It 'Get exist Key Value Pair, with specified section' {
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $ExistMock
                    Key     = 'KeySA1'
                    Section = 'SectionA'
                }

                $result = Get-TargetResource @getParam
                $result.Ensure | Should -Be 'Present'
                $result.Path | Should -Be $getParam.Path
                $result.Key | Should -Be $getParam.Key
                $result.Value | Should -Be 'ValueSA1'
                $result.Section | Should -Be 'SectionA'
            }


            It 'If $key is empty, only check section' {
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $ExistMock
                    Key     = ''
                    Section = 'SectionA'
                }

                $result = Get-TargetResource @getParam
                $result.Ensure | Should -Be 'Present'
                $result.Path | Should -Be $getParam.Path
                $result.Key | Should -Be $getParam.Key
                $result.Value | Should -Be ''
                $result.Section | Should -Be 'SectionA'
            }
        }

        Context 'Ensure = Absent' {

            It 'Should return Absent when ini file not found' {
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $NonExistMock
                    Key     = 'Key1'
                    Section = ''
                }

                $result = Get-TargetResource @getParam
                $result.Ensure | Should -Be 'Absent'
                $result.Path | Should -Be $getParam.Path
                $result.Key | Should -Be $getParam.Key
                $result.Value | Should -Be ''
                $result.Section | Should -Be ''
            }


            It 'If $key is empty, only check section' {
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $ExistMock
                    Key     = ''
                    Section = 'NOTFOUND'
                }

                $result = Get-TargetResource @getParam
                $result.Ensure | Should -Be 'Absent'
                $result.Path | Should -Be $getParam.Path
                $result.Key | Should -Be $getParam.Key
                $result.Value | Should -Be ''
                $result.Section | Should -Be 'NOTFOUND'
            }


            It 'Should return Absent when the key missing (with ROOT section)' {
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $ExistMock
                    Key     = 'NoKey1'
                    Section = ''
                }

                $result = Get-TargetResource @getParam
                $result.Ensure | Should -Be 'Absent'
                $result.Path | Should -Be $getParam.Path
                $result.Key | Should -Be $getParam.Key
                $result.Value | Should -Be ''
                $result.Section | Should -Be ''
            }

            It 'Should return Absent when the key missing (with specified section)' {
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $ExistMock
                    Key     = 'NoKey1'
                    Section = 'SectionA'
                }

                $result = Get-TargetResource @getParam
                $result.Ensure | Should -Be 'Absent'
                $result.Path | Should -Be $getParam.Path
                $result.Key | Should -Be $getParam.Key
                $result.Value | Should -Be ''
                $result.Section | Should -Be 'SectionA'
            }
        }
    }
    #endregion Tests for Get-TargetResource

    #region Tests for Test-TargetResource
    Describe 'IniFile/Test-TargetResource' {

        Mock Get-IniFile {
            return $MockIniObject1
        }

        Mock Test-Path {$true} -ParameterFilter {$Path -eq $ExistMock}
        Mock Test-Path {$false} -ParameterFilter {$Path -eq $NonExistMock}

        Context 'Ensure = Present' {

            Mock Test-Path {$true}

            It 'Should return $true when the key value pair exist (with ROOT section)' {
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $ExistMock
                    Key     = 'Key1'
                    Value   = 'Value1'
                    Section = ''
                }

                Test-TargetResource @getParam | Should -Be $true
            }


            It 'Should return $true when the key value pair exist (with specified section)' {
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $ExistMock
                    Key     = 'KeySA1'
                    Value   = 'ValueSA1'
                    Section = 'SectionA'
                }

                Test-TargetResource @getParam | Should -Be $true
            }


            It 'Should return $true when the Key param is empty and section exist (not empty section)' {
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $ExistMock
                    Key     = ''
                    Section = 'SectionA'
                }

                Test-TargetResource @getParam | Should -Be $true
            }


            It 'Should return $true when the Key param is empty and section exist (empty section)' {
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $ExistMock
                    Key     = ''
                    Section = 'SectionB'
                }

                Test-TargetResource @getParam | Should -Be $true
            }


            It 'Should return $true when the key value pair exist (Value empty)' {
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $ExistMock
                    Key     = 'Key3'
                    Section = ''
                }

                Test-TargetResource @getParam | Should -Be $true
            }


            It 'Should return $false when ini file not found' {
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $NonExistMock
                    Key     = 'Key1'
                    Section = ''
                }

                Test-TargetResource @getParam | Should -Be $false
            }


            It 'Should return $false when key value pair not exist' {
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $ExistMock
                    Key     = 'KeyX'
                    Value   = 'ValueX'
                    Section = ''
                }

                Test-TargetResource @getParam | Should -Be $false
            }


            It 'Should return $false when the section not exist' {
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $ExistMock
                    Key     = 'Key1'
                    Value   = 'Value1'
                    Section = 'SectionX'
                }

                Test-TargetResource @getParam | Should -Be $false
            }


            It 'Should return $false when key value pair exist but not match value' {
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $ExistMock
                    Key     = 'Key2'
                    Value   = 'ValueX'
                    Section = ''
                }

                Test-TargetResource @getParam | Should -Be $false
            }


            It 'Should return $false when key value pair exist but not match value' {
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $ExistMock
                    Key     = 'Key2'
                    Value   = 'ValueX'
                    Section = ''
                }

                Test-TargetResource @getParam | Should -Be $false
            }
        }


        Context 'Ensure = Absent' {

            It 'Should return $true when key value pair not exist' {
                $getParam = @{
                    Ensure  = 'Absent'
                    Path    = $ExistMock
                    Key     = 'KeyX'
                    Value   = 'ValueX'
                    Section = ''
                }

                Test-TargetResource @getParam | Should -Be $true
            }


            It 'Should return $true when key value pair not exist (specified section)' {
                $getParam = @{
                    Ensure  = 'Absent'
                    Path    = $ExistMock
                    Key     = 'KeyX'
                    Value   = 'ValueX'
                    Section = 'SectionA'
                }

                Test-TargetResource @getParam | Should -Be $true
            }


            It 'Should return $true when the section not exist (not empty section)' {
                $getParam = @{
                    Ensure  = 'Absent'
                    Path    = $ExistMock
                    Key     = 'KeySA1'
                    Value   = 'ValueSA1'
                    Section = 'SectionX'
                }

                Test-TargetResource @getParam | Should -Be $true
            }


            It 'Should return $true when the section not exist (empty section)' {
                $getParam = @{
                    Ensure  = 'Absent'
                    Path    = $ExistMock
                    Key     = ''
                    Section = 'SectionX'
                }

                Test-TargetResource @getParam | Should -Be $true
            }


            It 'Should return $true when the ini file not exist' {
                $getParam = @{
                    Ensure  = 'Absent'
                    Path    = $NonExistMock
                    Key     = 'Key1'
                    Value   = 'Value1'
                    Section = ''
                }

                Test-TargetResource @getParam | Should -Be $true
            }


            It 'Should return $false when key value pair exist (ROOT section)' {
                $getParam = @{
                    Ensure  = 'Absent'
                    Path    = $ExistMock
                    Key     = 'Key1'
                    Value   = 'Value1'
                    Section = ''
                }

                Test-TargetResource @getParam | Should -Be $false
            }


            It 'Should return $false when the key value pair exist (specified section)' {
                $getParam = @{
                    Ensure  = 'Absent'
                    Path    = $ExistMock
                    Key     = 'KeySA2'
                    Value   = 'ValueSA2'
                    Section = 'SectionA'
                }

                Test-TargetResource @getParam | Should -Be $false
            }


            It 'Should return $false when the key value pair exist (empty value)' {
                $getParam = @{
                    Ensure  = 'Absent'
                    Path    = $ExistMock
                    Key     = 'Key3'
                    Section = ''
                }

                Test-TargetResource @getParam | Should -Be $false
            }


            It 'Should return $false when the section exist (empty section)' {
                $getParam = @{
                    Ensure  = 'Absent'
                    Path    = $ExistMock
                    Key     = ''
                    Section = 'SectionB'
                }

                Test-TargetResource @getParam | Should -Be $false
            }
        }
    }
    #endregion Tests for Test-TargetResource


    #region Tests for Set-TargetResource
    Describe 'IniFile/Set-TargetResource' {

        Mock Get-IniFile {
            [ordered]@{
                _ROOT_   = [ordered]@{
                    Key1 = 'Value1'
                    Key2 = 'Value2'
                    Key3 = ''
                }

                SectionA = [ordered]@{
                    KeySA1 = 'ValueSA1'
                    KeySA2 = 'ValueSA2'
                }

                SectionB = [ordered]@{}
            }
        }

        BeforeEach {
            $MockIniFile1 | Out-File -FilePath (Join-Path $TestDrive 'MockIni.ini') -Encoding utf8 -Force
        }

        AfterEach {
            Remove-Item (Join-Path $TestDrive 'MockIni.ini') -Force
        }

        Context 'Ensure = Present' {

            It 'Create new ini file when the file not exist' {
                $path = (Join-Path $TestDrive 'MockIniX.ini')
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $path
                    Key     = 'KeyX'
                    Value   = 'ValueX'
                    Section = ''
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                Test-Path -LiteralPath $path | Should -Be $true
                Get-Content -Path $path -Encoding utf8 | Should -Be 'KeyX=ValueX'
            }

            It 'Create new ini file when the file not exist (create with parent folder)' {
                $path = (Join-Path $TestDrive '\parent folder\MockIniX.ini')
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $path
                    Key     = 'KeyX'
                    Value   = 'ValueX'
                    Section = ''
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                Test-Path -LiteralPath $path | Should -Be $true
                Get-Content -Path $path -Encoding utf8 | Should -Be 'KeyX=ValueX'
            }

            It 'Add Key Value Pair to ini (ROOT section)' {
                $path = (Join-Path $TestDrive 'MockIni.ini')
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $path
                    Key     = 'Key4'
                    Value   = 'Value4'
                    Section = ''
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                $content = Get-Content -Path $path -Encoding utf8
                $content[3] | Should -Be 'Key4=Value4'
            }


            It 'Add Key Value Pair to ini (specified section)' {
                $path = (Join-Path $TestDrive 'MockIni.ini')
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $path
                    Key     = 'KeySA3'
                    Value   = 'ValueSA3'
                    Section = 'SectionA'
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                $content = Get-Content -Path $path -Encoding utf8
                $content[6] | Should -Be 'KeySA3=ValueSA3'
            }

            It 'Add Section and Key Value Pair to ini' {
                $path = (Join-Path $TestDrive 'MockIni.ini')
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $path
                    Key     = 'KeySC1'
                    Value   = 'ValueSC1'
                    Section = 'SectionC'
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                $content = Get-Content -Path $path -Encoding utf8
                $content[7] | Should -Be '[SectionC]'
                $content[8] | Should -Be 'KeySC1=ValueSC1'
            }


            It 'Add only Section to ini' {
                $path = (Join-Path $TestDrive 'MockIni.ini')
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $path
                    Key     = ''
                    Section = 'SectionC'
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                $content = Get-Content -Path $path -Encoding utf8
                $content[7] | Should -Be '[SectionC]'
            }

            It 'Mod Value (ROOT section)' {
                $path = (Join-Path $TestDrive 'MockIni.ini')
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $path
                    Key     = 'Key2'
                    Value   = 'Value2X'
                    Section = ''
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                $content = Get-Content -Path $path -Encoding utf8
                $content[1] | Should -Be 'Key2=Value2X'
            }

            It 'Delete Value (ROOT section)' {
                $path = (Join-Path $TestDrive 'MockIni.ini')
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $path
                    Key     = 'Key2'
                    Section = ''
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                $content = Get-Content -Path $path -Encoding utf8
                $content[1] | Should -Be 'Key2='
            }

            It 'Nothing Changed if test passed' {
                $path = (Join-Path $TestDrive 'MockIni.ini')
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $path
                    Key     = 'Key1'
                    Value   = 'Value1'
                    Section = ''
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                $content = Get-Content -Path $path -Raw -Encoding utf8
                $content | Should -Be $MockIniFile1
            }
        }

        Context 'Ensure = Absent' {

            It 'Nothing to do if ini not found' {
                $path = (Join-Path $TestDrive 'MockIniX.ini')
                $getParam = @{
                    Ensure  = 'Absent'
                    Path    = $path
                    Key     = 'Key1'
                    Section = ''
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                Test-Path -LiteralPath $path | Should -Be $false
            }


            It 'Nothing to do if target key not exist (ROOT section)' {
                $path = (Join-Path $TestDrive 'MockIni.ini')
                $getParam = @{
                    Ensure  = 'Absent'
                    Path    = $path
                    Key     = 'KeyX'
                    Section = ''
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                $content = Get-Content -Path $path -Raw -Encoding utf8
                $content | Should -Be $MockIniFile1
            }

            It 'Nothing to do if target key not exist (specified section)' {
                $path = (Join-Path $TestDrive 'MockIni.ini')
                $getParam = @{
                    Ensure  = 'Absent'
                    Path    = $path
                    Key     = 'Key1'
                    Section = 'SectionA'
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                $content = Get-Content -Path $path -Raw -Encoding utf8
                $content | Should -Be $MockIniFile1
            }


            It 'Nothing to do if target section not exist ()' {
                $path = (Join-Path $TestDrive 'MockIni.ini')
                $getParam = @{
                    Ensure  = 'Absent'
                    Path    = $path
                    Key     = ''
                    Section = 'SectionX'
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                $content = Get-Content -Path $path -Raw -Encoding utf8
                $content | Should -Be $MockIniFile1
            }


            It 'Remove Key (ROOT section)' {
                $path = (Join-Path $TestDrive 'MockIni.ini')
                $getParam = @{
                    Ensure  = 'Absent'
                    Path    = $path
                    Key     = 'Key2'
                    Section = ''
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                $path | Should -Not -FileContentMatch 'Key2'
            }


            It 'Remove Key (specified section)' {
                $path = (Join-Path $TestDrive 'MockIni.ini')
                $getParam = @{
                    Ensure  = 'Absent'
                    Path    = $path
                    Key     = 'KeySA1'
                    Section = 'SectionA'
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                $path | Should -Not -FileContentMatch 'KeySA1'
            }


            It 'Remove Section and all of child keys (not empty section)' {
                $path = (Join-Path $TestDrive 'MockIni.ini')
                $getParam = @{
                    Ensure  = 'Absent'
                    Path    = $path
                    Key     = ''
                    Section = 'SectionA'
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                $path | Should -Not -FileContentMatch 'SectionA'
                $path | Should -Not -FileContentMatch 'KeySA1'
                $path | Should -Not -FileContentMatch 'KeySA2'
            }


            It 'Remove Section (empty section)' {
                $path = (Join-Path $TestDrive 'MockIni.ini')
                $getParam = @{
                    Ensure  = 'Absent'
                    Path    = $path
                    Key     = ''
                    Section = 'SectionB'
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                $path | Should -Not -FileContentMatch 'SectionB'
            }
        }


        Context 'Encoding' {

            It 'Create new INI file NOT specified encoding should be UTF8 without BOM' {
                $path = (Join-Path $TestDrive 'NonSpecified.ini')

                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $path
                    Section = 'Section'
                    Key     = 'Key'
                    Value   = 'あいうえお'
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                Test-Path -LiteralPath $path | Should -Be $true
                $content = Get-Content -Path $path -Encoding utf8
                $content[0] | Should -Be '[Section]'
                $content[1] | Should -Be 'Key=あいうえお'

                (Get-TestEncoding -Path $path).BodyName | Should -Be 'utf-8'
                Test-BOM -Path $path | Should -Be $null #NoBOM
            }

            It 'Create new INI file specified encoding (UTF8NoBOM)' {
                $path = (Join-Path $TestDrive 'UTF8NoBOM.ini')

                $getParam = @{
                    Ensure   = 'Present'
                    Path     = $path
                    Section  = 'Section'
                    Key      = 'Key'
                    Value    = 'あいうえお'
                    Encoding = 'UTF8NoBOM'
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                Test-Path -LiteralPath $path | Should -Be $true
                $content = Get-Content -Path $path -Encoding utf8
                $content[0] | Should -Be '[Section]'
                $content[1] | Should -Be 'Key=あいうえお'

                (Get-TestEncoding -Path $path).BodyName | Should -Be 'utf-8'
                Test-BOM -Path $path | Should -Be $null #NoBOM
            }

            It 'Create new INI file specified encoding (UTF8BOM)' {
                $path = (Join-Path $TestDrive 'UTF8BOM.ini')

                $getParam = @{
                    Ensure   = 'Present'
                    Path     = $path
                    Section  = 'Section'
                    Key      = 'Key'
                    Value    = 'あいうえお'
                    Encoding = 'UTF8BOM'
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                Test-Path -LiteralPath $path | Should -Be $true
                $content = Get-Content -Path $path -Encoding utf8
                $content[0] | Should -Be '[Section]'
                $content[1] | Should -Be 'Key=あいうえお'

                (Get-TestEncoding -Path $path).BodyName | Should -Be 'utf-8'
                Test-BOM -Path $path | Should -Be 'utf8BOM'
            }

            It 'Create new INI file specified encoding (unicode)' {
                $path = (Join-Path $TestDrive 'unicode.ini')

                $getParam = @{
                    Ensure   = 'Present'
                    Path     = $path
                    Section  = 'Section'
                    Key      = 'Key'
                    Value    = 'あいうえお'
                    Encoding = 'unicode'
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                Test-Path -LiteralPath $path | Should -Be $true
                $content = Get-Content -Path $path -Encoding unicode
                $content[0] | Should -Be '[Section]'
                $content[1] | Should -Be 'Key=あいうえお'

                (Get-TestEncoding -Path $path).BodyName | Should -Be 'utf-16'
            }

            It 'Create new INI file specified encoding (BigEndianUnicode)' {
                $path = (Join-Path $TestDrive 'BigEndianUnicode.ini')

                $getParam = @{
                    Ensure   = 'Present'
                    Path     = $path
                    Section  = 'Section'
                    Key      = 'Key'
                    Value    = 'あいうえお'
                    Encoding = 'BigEndianUnicode'
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                Test-Path -LiteralPath $path | Should -Be $true
                $content = Get-Content -Path $path -Encoding BigEndianUnicode
                $content[0] | Should -Be '[Section]'
                $content[1] | Should -Be 'Key=あいうえお'

                (Get-TestEncoding -Path $path).BodyName | Should -Be 'utf-16BE'
            }
        }

        Context 'NewLine Code' {

            It 'Create new INI file specified new line code (CRLF)' {
                $path = (Join-Path $TestDrive 'CRLF.ini')
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $path
                    Section = 'Section'
                    Key     = 'Key'
                    Value   = 'あいうえお'
                    NewLine = 'CRLF'
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                Test-Path -LiteralPath $path | Should -Be $true
                $content = Get-Content -Path $path -Encoding utf8
                $content[0] | Should -Be '[Section]'
                $content[1] | Should -Be 'Key=あいうえお'

                Test-NewLineCode -Path $path | Should -Be 'CRLF'
            }

            It 'Create new INI file specified new line code (LF)' {
                $path = (Join-Path $TestDrive 'LF.ini')
                $getParam = @{
                    Ensure  = 'Present'
                    Path    = $path
                    Section = 'Section'
                    Key     = 'Key'
                    Value   = 'あいうえお'
                    NewLine = 'LF'
                }

                { Set-TargetResource @getParam } | Should -Not -Throw

                Test-Path -LiteralPath $path | Should -Be $true
                $content = Get-Content -Path $path -Encoding utf8
                $content[0] | Should -Be '[Section]'
                $content[1] | Should -Be 'Key=あいうえお'

                Test-NewLineCode -Path $path | Should -Be 'LF'
            }
        }
    }
    #endregion Tests for Set-TargetResource

    #region Tests for Get-IniFile
    Describe 'IniFile/Get-IniFile' {

        BeforeAll {
            $MockIniFile1 | Out-File -FilePath 'TestDrive:\MocIni1.ini' -Encoding ascii -Force
        }

        It 'Should throw if ini file not exist' {

            { Get-IniFile -Path 'TestDrive:\MocIniX.ini' } | Should -Throw
        }

        It 'Read ini file and convert to ordered hash' {

            $result = Get-IniFile -Path 'TestDrive:\MocIni1.ini'

            $result | Should -BeOfType System.Collections.Specialized.OrderedDictionary
            $result.Count | Should -Be 3
            $result._ROOT_.Count | Should -Be 3
            $result._ROOT_.Key1 | Should -Be 'Value1'
            $result._ROOT_.Key2 | Should -Be 'Value2'
            $result._ROOT_.Key3 | Should -Be ''
            $result.SectionA.Count | Should -Be 2
            $result.SectionA.KeySA1 | Should -Be 'ValueSA1'
            $result.SectionA.KeySA2 | Should -Be 'ValueSA2'
            $result.SectionB.Count | Should -Be 0
        }
    }
}
#endregion Tests for Get-IniFile
