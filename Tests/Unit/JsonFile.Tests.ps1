
# Begin Testing
Describe 'Tests for JsonFile' {

    BeforeAll {
        # Import TestHelper
        $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
        Import-Module (Join-Path $script:moduleRoot '\DSCResources\JsonFile\JsonFile.psm1') -Force
        Import-Module (Join-Path $PSScriptRoot '\TestHelper\TestHelper.psm1') -Force
        $global:TestData = Join-Path $PSScriptRoot '\TestData'
    }

    # Begin Testing
    InModuleScope 'JsonFile' {
        #region Set variables for testing
        $ExistMock = 'Exist.Json'
        $NonExistMock = 'NonExist.Json'

        $MockJsonFile1 = @'
    {
        "String": "StringValue",
        "Integer": 12345,
        "Boolean": true,
        "Array": [
            "ArrayValue1",
            "ArrayValue2",
            "ArrayValue3"
        ],
        "Dictionary": {
            "DicKey1": "DicValue1",
            "DicKey2": "DicValue2"
        },
        "SubDictionary": {
            "SubDicKey1": {
                "SubSubKey1": "SubSubValue1",
                "SubSubKey2": "SubSubValue2"
            },
            "SubDicKey2": true
        }
    }
'@
        #endregion Set variables for testing

        #region Tests for Get-TargetResource
        Describe 'JsonFile/Get-TargetResource' {

            BeforeAll {
                $MockJsonFile1 | Out-File -FilePath (Join-Path $TestDrive $ExistMock) -Encoding utf8 -Force
            }

            Context 'Ensure = Present' {

                It 'Get exist Key Value Pair (string)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Path  = $jsonPath
                        Key   = 'String'
                        Value = 'StringValue'
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Present'
                    $result.Path | Should -Be $getParam.Path
                    $result.Key | Should -Be $getParam.Key
                    $result.Value | Should -Be '"StringValue"'
                }

                It 'Get exist Key Value Pair (int)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Path  = $jsonPath
                        Key   = 'Integer'
                        Value = '12345'
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Present'
                    $result.Path | Should -Be $getParam.Path
                    $result.Key | Should -Be $getParam.Key
                    $result.Value | Should -Be '12345'
                }

                It 'Get exist Key Value Pair (bool case 1)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Path  = $jsonPath
                        Key   = 'Boolean'
                        Value = 'true'
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Present'
                    $result.Path | Should -Be $getParam.Path
                    $result.Key | Should -Be $getParam.Key
                    $result.Value | Should -BeExactly 'true'
                }

                It 'Get exist Key Value Pair (bool case 2)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Path  = $jsonPath
                        Key   = 'Boolean'
                        Value = 'True'
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Present'
                    $result.Path | Should -Be $getParam.Path
                    $result.Key | Should -Be $getParam.Key
                    $result.Value | Should -BeExactly 'true'
                }

                It 'Get exist Key Value Pair (bool case 3)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Path  = $jsonPath
                        Key   = 'Boolean'
                        Value = $true
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Present'
                    $result.Path | Should -Be $getParam.Path
                    $result.Key | Should -Be $getParam.Key
                    $result.Value | Should -Be 'true'
                }

                It 'Get exist Key Value Pair (bool like string)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Path  = $jsonPath
                        Key   = 'Boolean'
                        Value = '"true"'
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Absent'
                    $result.Path | Should -Be $getParam.Path
                    $result.Key | Should -Be $getParam.Key
                    $result.Value | Should -Be 'true'
                }

                It 'Get exist Key Value Pair (Array)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Path  = $jsonPath
                        Key   = 'Array'
                        Value = (@('ArrayValue1', 'ArrayValue2', 'ArrayValue3') | ConvertTo-Json)
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Present'
                    $result.Path | Should -Be $getParam.Path
                    $result.Key | Should -Be $getParam.Key
                    $result.Value | Should -Be '["ArrayValue1","ArrayValue2","ArrayValue3"]'
                }

                It 'Get exist Key Value Pair (Dictionary)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Path  = $jsonPath
                        Key   = 'Dictionary'
                        Value = (@{DicKey1 = "DicValue1"; DicKey2 = "DicValue2"} | ConvertTo-Json)
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Present'
                    $result.Path | Should -Be $getParam.Path
                    $result.Key | Should -Be $getParam.Key
                    $result.Value | Should -Be '{"DicKey1":"DicValue1","DicKey2":"DicValue2"}'
                }

                It 'Get exist Key Value Pair (SubDictionary)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Path  = $jsonPath
                        Key   = 'SubDictionary/SubDicKey1'
                        Value = (@{SubSubKey1 = "SubSubValue1"; SubSubKey2 = "SubSubValue2"} | ConvertTo-Json)
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Present'
                    $result.Path | Should -Be $getParam.Path
                    $result.Key | Should -Be $getParam.Key
                    $result.Value | Should -Be '{"SubSubKey1":"SubSubValue1","SubSubKey2":"SubSubValue2"}'
                }

                It 'Get exist Key Value Pair (Mode = "ArrayElement")' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Path  = $jsonPath
                        Key   = 'Array'
                        Value = '"ArrayValue2"'
                        Mode  = 'ArrayElement'
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Present'
                    $result.Path | Should -Be $getParam.Path
                    $result.Key | Should -Be $getParam.Key
                    $result.Value | Should -Be '["ArrayValue1","ArrayValue2","ArrayValue3"]'
                }
            }

            Context 'Ensure = Absent' {

                It 'Should return Absent when Json file was not found' {
                    $jsonPath = (Join-Path $TestDrive $NonExistMock)
                    $getParam = @{
                        Path  = $jsonPath
                        Key   = 'String'
                        Value = 'foo'
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Absent'
                }

                It 'Should return Absent when the specified key was not found in JSON' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Path  = $jsonPath
                        Key   = 'foo'
                        Value = 'foo'
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Absent'
                }

                It 'Should return Absent when the key value was not matched' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Path  = $jsonPath
                        Key   = 'String'
                        Value = '"not match"'
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Absent'
                    $result.Path | Should -Be $getParam.Path
                    $result.Key | Should -Be $getParam.Key
                    $result.Value | Should -Be '"StringValue"'
                }

                It 'Should return Absent when the key value was not matched (SubDictionary)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Path  = $jsonPath
                        Key   = 'SubDictionary/SubDicKey2'
                        Value = '"not match"'
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Absent'
                    $result.Path | Should -Be $getParam.Path
                    $result.Key | Should -Be $getParam.Key
                    $result.Value | Should -Be 'true'
                }
            }


            Context 'TextEncoding' {
                It 'Get exist Key Value Pair (UTF-8)' {
                    $jsonPath = (Join-Path $TestData 'utf8_crlf.json')
                    $getParam = @{
                        Path     = $jsonPath
                        Key      = 'test'
                        Value    = '"あいうえお"'
                        Encoding = 'utf8'
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Present'
                    $result.Path | Should -Be $getParam.Path
                    $result.Key | Should -Be $getParam.Key
                    $result.Value | Should -Be '"あいうえお"'
                }

                It 'Get exist Key Value Pair (Unicode)' {
                    $jsonPath = (Join-Path $TestData 'unicode_crlf.json')
                    $getParam = @{
                        Path     = $jsonPath
                        Key      = 'test'
                        Value    = '"あいうえお"'
                        Encoding = 'unicode'
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Present'
                    $result.Path | Should -Be $getParam.Path
                    $result.Key | Should -Be $getParam.Key
                    $result.Value | Should -Be '"あいうえお"'
                }

                It 'Get exist Key Value Pair (bigendianunicode)' {
                    $jsonPath = (Join-Path $TestData 'bigendianunicode_crlf.json')
                    $getParam = @{
                        Path     = $jsonPath
                        Key      = 'test'
                        Value    = '"あいうえお"'
                        Encoding = 'bigendianunicode'
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Present'
                    $result.Path | Should -Be $getParam.Path
                    $result.Key | Should -Be $getParam.Key
                    $result.Value | Should -Be '"あいうえお"'
                }
            }
        }
        #endregion Tests for Get-TargetResource

        #region Tests for Test-TargetResource
        Describe 'JsonFile/Test-TargetResource' {

            BeforeAll {
                $MockJsonFile1 | Out-File -FilePath (Join-Path $TestDrive $ExistMock) -Encoding utf8 -Force
            }

            Context 'Ensure = Present' {

                It 'Should return $true when the key value pair is matched' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'Boolean'
                        Value  = 'true'
                    }

                    Test-TargetResource @getParam | Should -Be $true
                }

                It 'Should return $false when the key value pair is not matched' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'Boolean'
                        Value  = 'false'
                    }

                    Test-TargetResource @getParam | Should -Be $false
                }

                It 'Should return $false when the key is missing' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'Foo'
                        Value  = 'foo'
                    }

                    Test-TargetResource @getParam | Should -Be $false
                }

                It 'Should return $false when the Json not exist' {
                    $jsonPath = (Join-Path $TestDrive $NonExistMock)
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'String'
                        Value  = 'foo'
                    }

                    Test-TargetResource @getParam | Should -Be $false
                }
            }


            Context 'Ensure = Absent' {

                It 'Should return $true when the Json not exist' {
                    $jsonPath = (Join-Path $TestDrive $NonExistMock)
                    $getParam = @{
                        Ensure = 'Absent'
                        Path   = $jsonPath
                        Key    = 'String'
                        Value  = 'foo'
                    }

                    Test-TargetResource @getParam | Should -Be $true
                }


                It 'Should return $true when the key is missing' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Absent'
                        Path   = $jsonPath
                        Key    = 'Foo'
                        Value  = 'foo'
                    }

                    Test-TargetResource @getParam | Should -Be $true
                }

                It 'Should return $true when the key value pair is not matched' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Absent'
                        Path   = $jsonPath
                        Key    = 'Boolean'
                        Value  = 'false'
                    }

                    Test-TargetResource @getParam | Should -Be $true
                }


                It 'Should return $false when the key value pair is matched' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Absent'
                        Path   = $jsonPath
                        Key    = 'Boolean'
                        Value  = 'true'
                    }

                    Test-TargetResource @getParam | Should -Be $false
                }
            }
        }
        #endregion Tests for Test-TargetResource


        #region Tests for Set-TargetResource
        Describe 'JsonFile/Set-TargetResource' {


            BeforeEach {
                $MockJsonFile1 | Out-File -FilePath (Join-Path $TestDrive $ExistMock) -Encoding utf8 -Force
            }

            AfterEach {
                Remove-Item (Join-Path $TestDrive $ExistMock) -Force
            }

            Context 'Ensure = Present' {

                It 'Create new Json file when the file not exist' {
                    $jsonPath = (Join-Path $TestDrive 'MockJsonX.Json')
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'KeyX'
                        Value  = 'ValueX'
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw

                    Test-Path -LiteralPath $jsonPath | Should -Be $true
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.KeyX | Should -Be 'ValueX'
                }

                It 'Create new Json file when the file not exist (Missing parent directory)' {
                    $jsonPath = (Join-Path $TestDrive '\Parent Folder\MockJsonX.Json')
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'KeyX'
                        Value  = 'ValueX'
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw

                    Test-Path -LiteralPath $jsonPath | Should -Be $true
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.KeyX | Should -Be 'ValueX'
                }

                It 'Add Key Value Pair to Json when the key not exist (string)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'StringZ'
                        Value  = 'ValueZ'
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.StringZ | Should -Be 'ValueZ'
                }

                It 'Add Key Value Pair to Json when the key not exist (int)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'IntZ'
                        Value  = 56789
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.IntZ | Should -BeOfType [int]
                    $result.IntZ | Should -Be 56789
                }

                It 'Add Key Value Pair to Json when the key not exist (bool case 1)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'Bool1'
                        Value  = 'false'
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.Bool1 | Should -BeOfType [bool]
                    $result.Bool1 | Should -Be $false
                }

                It 'Add Key Value Pair to Json when the key not exist (bool case 2)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'Bool2'
                        Value  = 'FALSE'
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.Bool2 | Should -BeOfType [bool]
                    $result.Bool2 | Should -Be $false
                }

                It 'Add Key Value Pair to Json when the key not exist (bool case 3)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'Bool3'
                        Value  = $true
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.Bool3 | Should -BeOfType [bool]
                    $result.Bool3 | Should -Be $true
                }

                It 'Add Key Value Pair to Json when the key not exist (bool like string)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'Bool4'
                        Value  = '"true"'
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.Bool4 | Should -BeExactly 'true'
                }

                It 'Add Key Value Pair to Json when the key not exist (Array)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'ArrayZ'
                        Value  = '[true, 123, "str"]'
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.ArrayZ.Count | Should -Be 3
                    $result.ArrayZ[0] | Should -Be $true
                    $result.ArrayZ[1] | Should -Be 123
                    $result.ArrayZ[2] | Should -Be "str"
                }


                It 'Add Key Value Pair to Json when the key not exist (Dictionary)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'DicZ'
                        Value  = (@{k1 = $true; k2 = 345; k3 = 'ABC'} | ConvertTo-Json)
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.DicZ.k1 | Should -Be $true
                    $result.DicZ.k2 | Should -Be 345
                    $result.DicZ.k3 | Should -Be "ABC"
                }

                It 'Add Key Value Pair to Json when the key not exist (SubDictionary)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'DicZ/DicY'
                        Value  = (@{k1 = $true; k2 = 345; k3 = 'ABC'} | ConvertTo-Json)
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.DicZ.DicY.k1 | Should -Be $true
                    $result.DicZ.DicY.k2 | Should -Be 345
                    $result.DicZ.DicY.k3 | Should -Be "ABC"
                }

                It 'Add Array element to Json when the key not exist (Mode = "ArrayElement")' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'ArrayX'
                        Value  = '"ArrayElementX"'
                        Mode   = 'ArrayElement'
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    ($result.ArrayX -is [Array]) | Should -Be $true
                    $result.ArrayX[0] | Should -Be 'ArrayElementX'
                }

                It 'Modify exist Key Value Pair' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'String'
                        Value  = 'ModValue'
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.String | Should -Be 'ModValue'
                }

                It 'Modify exist Key Value Pair (SubDictionary)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'SubDictionary/SubDicKey1'
                        Value  = (@{k1 = $true; k2 = 345; k3 = 'ABC'} | ConvertTo-Json)
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.SubDictionary.SubDicKey1.k1 | Should -Be $true
                    $result.SubDictionary.SubDicKey1.k2 | Should -Be 345
                    $result.SubDictionary.SubDicKey1.k3 | Should -Be "ABC"
                }

                It 'Add element to exist Array Value (Mode = "ArrayElement")' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'Array'
                        Value  = '345'
                        Mode   = "ArrayElement"
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    ($result.Array -is [Array]) | Should -Be $true
                    $result.Array[3] | Should -Be 345
                }

                It 'Add element to exist Value (Mode = "ArrayElement")' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Present'
                        Path   = $jsonPath
                        Key    = 'SubDictionary/SubDicKey2'
                        Value  = '345'
                        Mode   = "ArrayElement"
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.SubDictionary.SubDicKey2.Count | Should -Be 2
                    $result.SubDictionary.SubDicKey2[0] | Should -Be $true
                    $result.SubDictionary.SubDicKey2[1] | Should -Be 345
                }
            }

            Context 'Ensure = Absent' {

                It 'Remove Key in JSON' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Absent'
                        Path   = $jsonPath
                        Key    = 'String'
                        Value  = 'foo'
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result | Get-Member -MemberType NoteProperty | Where-Object {$_.Name -eq 'String'} | Should -Be $null
                }

                It 'Remove Key in JSON  (SubDictionary)' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Absent'
                        Path   = $jsonPath
                        Key    = 'SubDictionary/SubDicKey2'
                        Value  = 'foo'
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.SubDictionary | Get-Member -MemberType NoteProperty | Where-Object {$_.Name -eq 'SubDicKey2'} | Should -Be $null
                }

                It 'Remove array element in JSON  (Mode = "ArrayElement")' {
                    $jsonPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Ensure = 'Absent'
                        Path   = $jsonPath
                        Key    = 'Array'
                        Value  = 'ArrayValue1'
                        Mode   = 'ArrayElement'
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    ($result.Array -is [Array]) | Should -Be $true
                    $result.Array.Count | Should -Be 2
                    $result.Array[0] | Should -Be 'ArrayValue2'
                    $result.Array[1] | Should -Be 'ArrayValue3'
                }
            }

            Context 'TextEncoding' {

                It 'Create new Json file specified encoding (UTF-8)' {
                    $jsonPath = (Join-Path $TestDrive 'utf8.Json')
                    $getParam = @{
                        Ensure   = 'Present'
                        Path     = $jsonPath
                        Key      = 'test'
                        Value    = '"あいうえお"'
                        Encoding = 'utf8'
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw

                    Test-Path -LiteralPath $jsonPath | Should -Be $true
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.test | Should -Be 'あいうえお'

                    (Get-TestEncoding -Path $jsonPath).BodyName | Should -Be 'utf-8'
                    Test-BOM -Path $jsonPath | Should -Be $null #NoBOM
                }

                It 'Create new Json file specified encoding (UTF-8 with BOM)' {
                    $jsonPath = (Join-Path $TestDrive 'utf8bom.Json')
                    $getParam = @{
                        Ensure   = 'Present'
                        Path     = $jsonPath
                        Key      = 'test'
                        Value    = '"あいうえお"'
                        Encoding = 'utf8BOM'
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw

                    Test-Path -LiteralPath $jsonPath | Should -Be $true
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.test | Should -Be 'あいうえお'

                    (Get-TestEncoding -Path $jsonPath).BodyName | Should -Be 'utf-8'
                    Test-BOM -Path $jsonPath | Should -Be 'utf8BOM'
                }


                It 'Create new Json file specified encoding (unicode)' {
                    $jsonPath = (Join-Path $TestDrive 'unicode_crlf.Json')
                    $getParam = @{
                        Ensure   = 'Present'
                        Path     = $jsonPath
                        Key      = 'test'
                        Value    = '"あいうえお"'
                        Encoding = 'unicode'
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw

                    Test-Path -LiteralPath $jsonPath | Should -Be $true
                    $result = Get-Content -Path $jsonPath -Encoding unicode -raw | ConvertFrom-Json
                    $result.test | Should -Be 'あいうえお'

                    (Get-TestEncoding -Path $jsonPath).BodyName | Should -Be 'utf-16'
                }

                It 'Create new Json file specified encoding (BigEndianUnicode)' {
                    $jsonPath = (Join-Path $TestDrive 'BigEndianUnicode_crlf.Json')
                    $getParam = @{
                        Ensure   = 'Present'
                        Path     = $jsonPath
                        Key      = 'test'
                        Value    = '"あいうえお"'
                        Encoding = 'BigEndianUnicode'
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw

                    Test-Path -LiteralPath $jsonPath | Should -Be $true
                    $result = Get-Content -Path $jsonPath -Encoding BigEndianUnicode -raw | ConvertFrom-Json
                    $result.test | Should -Be 'あいうえお'

                    (Get-TestEncoding -Path $jsonPath).BodyName | Should -Be 'utf-16BE'
                }
            }


            Context 'NewLine Code' {

                It 'Create new Json file specified new line code (CRLF)' {
                    $jsonPath = (Join-Path $TestDrive 'utf8.Json')
                    $getParam = @{
                        Ensure  = 'Present'
                        Path    = $jsonPath
                        Key     = 'test'
                        Value   = '"test"'
                        NewLine = 'CRLF'
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw

                    Test-Path -LiteralPath $jsonPath | Should -Be $true
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.test | Should -Be 'test'

                    Test-NewLineCode -Path $jsonPath | Should -Be 'CRLF'
                }

                It 'Create new Json file specified new line code (LF)' {
                    $jsonPath = (Join-Path $TestDrive 'utf8.Json')
                    $getParam = @{
                        Ensure  = 'Present'
                        Path    = $jsonPath
                        Key     = 'test'
                        Value   = '"test"'
                        NewLine = 'LF'
                    }

                    { Set-TargetResource @getParam } | Should -Not -Throw

                    Test-Path -LiteralPath $jsonPath | Should -Be $true
                    $result = Get-Content -Path $jsonPath -Encoding utf8 -raw | ConvertFrom-Json
                    $result.test | Should -Be 'test'

                    Test-NewLineCode -Path $jsonPath | Should -Be 'LF'
                }

            }
        }
        #endregion Tests for Set-TargetResource
    }
}
