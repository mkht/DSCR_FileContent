
# Begin Testing
Describe 'Tests for TextFile' {

    BeforeAll {
        # Import TestHelper
        $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
        Import-Module (Join-Path $script:moduleRoot '\DSCResources\TextFile\TextFile.psm1') -Force
        Import-Module (Join-Path $PSScriptRoot '\TestHelper\TestHelper.psm1') -Force
        $global:TestData = Join-Path $PSScriptRoot '\TestData'
    }

    InModuleScope 'TextFile' {
        #region Set variables for testing
        $ExistMock = 'Exist.txt'
        $NonExistMock = 'NonExist.txt'

        $MockContent = @'
{
  "test": "あいうえお"
}

'@
        #endregion Set variables for testing

        #region Tests for Get-TargetResource
        Describe 'TextFile/Get-TargetResource' {

            Context 'File exists' {

                It 'Return Present with content when the size of content is smaller than 2048 bytes' {
                    $MockContent1 = 'some text'
                    $MockContent1 | Out-File -FilePath (Join-Path $TestDrive $ExistMock) -Encoding utf8 -Force -NoNewline

                    $textPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Path = $textPath
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Present'
                    $result.Path | Should -Be $textPath
                    $result.Contents | Should -Be $MockContent1
                }

                It 'Return Present with content when the size of content is equal 2048 bytes' {
                    $MockContent2 = ((1..2045) | ForEach-Object {[char]54}) -join ''
                    $MockContent2 | Out-File -FilePath (Join-Path $TestDrive $ExistMock) -Encoding utf8 -Force -NoNewline

                    $textPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Path = $textPath
                    }

                    $result = Get-TargetResource @getParam
                    $result.Ensure | Should -Be 'Present'
                    $result.Path | Should -Be $textPath
                    $result.Contents | Should -Be $MockContent2
                }

                It 'Return Present without content when the size of content is bigger than 2048 bytes' {
                    $MockContent3 = ((1..2046) | ForEach-Object {[char]54}) -join ''
                    $MockContent3 | Out-File -FilePath (Join-Path $TestDrive $ExistMock) -Encoding utf8 -Force -NoNewline

                    $textPath = (Join-Path $TestDrive $ExistMock)
                    $getParam = @{
                        Path = $textPath
                    }

                    $result = Get-TargetResource @getParam -WarningAction SilentlyContinue
                    $result.Ensure | Should -Be 'Present'
                    $result.Path | Should -Be $textPath
                    $result.Contents | Should -Be $null
                }

                Context 'File not exists' {

                    It 'Return Absent' {
                        $textPath = (Join-Path $TestDrive $NonExistMock)
                        $getParam = @{
                            Path = $textPath
                        }

                        $result = Get-TargetResource @getParam
                        $result.Ensure | Should -Be 'Absent'
                        $result.Path | Should -Be $textPath
                        $result.Contents | Should -Be $null
                    }
                }
            }
            #endregion Tests for Get-TargetResource

            #region Tests for Test-TargetResource
            Describe 'TextFile/Test-TargetResource' {

                Context 'Ensure = Present' {

                    It 'Should return $false when the file not exist' {
                        $TestDataPath = (Join-Path $TestData $NonExistMock)

                        $testParam = @{
                            Ensure = 'Present'
                            Path   = $TestDataPath
                        }

                        Test-TargetResource @testParam | Should -Be $false
                    }

                    It 'Should return $true when the file exist (empty file)' {
                        $null = New-Item -Path (Join-Path $TestDrive $ExistMock) -Force
                        $TestDataPath = (Join-Path $TestDrive $ExistMock)

                        $testParam = @{
                            Ensure = 'Present'
                            Path   = $TestDataPath
                        }

                        Test-TargetResource @testParam | Should -Be $true
                    }

                    It 'Should return $true when the file exist, same size and same hash (utf8 / CRLF)' {
                        $TestDataPath = (Join-Path $TestData 'utf8_crlf.json')

                        $testParam = @{
                            Ensure   = 'Present'
                            Path     = $TestDataPath
                            Contents = $MockContent
                            Encoding = 'utf8'
                            NewLine  = 'CRLF'
                        }

                        Test-TargetResource @testParam | Should -Be $true
                    }

                    It 'Should return $true when the file exist, same size and same hash (utf8 / LF)' {
                        $TestDataPath = (Join-Path $TestData 'utf8_lf.json')

                        $testParam = @{
                            Ensure   = 'Present'
                            Path     = $TestDataPath
                            Contents = $MockContent
                            Encoding = 'utf8'
                            NewLine  = 'LF'
                        }

                        Test-TargetResource @testParam | Should -Be $true
                    }

                    It 'Should return $true when the file exist, same size and same hash (utf8BOM / CRLF)' {
                        $TestDataPath = (Join-Path $TestData 'utf8bom_crlf.json')

                        $testParam = @{
                            Ensure   = 'Present'
                            Path     = $TestDataPath
                            Contents = $MockContent
                            Encoding = 'utf8BOM'
                            NewLine  = 'CRLF'
                        }

                        Test-TargetResource @testParam | Should -Be $true
                    }

                    It 'Should return $true when the file exist, same size and same hash (unicode / CRLF)' {
                        $TestDataPath = (Join-Path $TestData 'unicode_crlf.json')

                        $testParam = @{
                            Ensure   = 'Present'
                            Path     = $TestDataPath
                            Contents = $MockContent
                            Encoding = 'unicode'
                            NewLine  = 'CRLF'
                        }

                        Test-TargetResource @testParam | Should -Be $true
                    }

                    It 'Should return $true when the file exist, same size and same hash (bigendianunicode / CRLF)' {
                        $TestDataPath = (Join-Path $TestData 'bigendianunicode_crlf.json')

                        $testParam = @{
                            Ensure   = 'Present'
                            Path     = $TestDataPath
                            Contents = $MockContent
                            Encoding = 'bigendianunicode'
                            NewLine  = 'CRLF'
                        }

                        Test-TargetResource @testParam | Should -Be $true
                    }

                    It 'Should return $true when the file exist, same size and same hash (sjis / CRLF)' {
                        $TestDataPath = (Join-Path $TestData 'sjis_crlf.json')

                        $testParam = @{
                            Ensure   = 'Present'
                            Path     = $TestDataPath
                            Contents = $MockContent
                            Encoding = 'sjis'
                            NewLine  = 'CRLF'
                        }

                        Test-TargetResource @testParam | Should -Be $true
                    }

                    It 'Should return $false when the file exist, but different size' {
                        $TestDataPath = (Join-Path $TestData 'utf8_crlf.json')
                        $TestContent = 'small'

                        $testParam = @{
                            Ensure   = 'Present'
                            Path     = $TestDataPath
                            Contents = $TestContent
                        }

                        Test-TargetResource @testParam | Should -Be $false
                    }

                    It 'Should return $false when the file exist, same size, but different hash' {
                        $TestDataPath = (Join-Path $TestData 'utf8_crlf.json')  #35 bytes
                        $TestContent = ((1..35) | ForEach-Object {[char]54}) -join '' #35 bytes

                        $testParam = @{
                            Ensure   = 'Present'
                            Path     = $TestDataPath
                            Contents = $TestContent
                        }

                        Test-TargetResource @testParam | Should -Be $false
                    }
                }


                Context 'Ensure = Absent' {

                    It 'Should return $true when the file not exist' {
                        $txtPath = (Join-Path $TestDrive $NonExistMock)
                        $testParam = @{
                            Ensure = 'Absent'
                            Path   = $txtPath
                        }

                        Test-TargetResource @testParam | Should -Be $true
                    }

                    It 'Should return $false when the file exist' {
                        $null = New-Item -Path (Join-Path $TestDrive $ExistMock) -Force
                        $txtPath = (Join-Path $TestDrive $ExistMock)

                        $testParam = @{
                            Ensure = 'Absent'
                            Path   = $txtPath
                        }

                        Test-TargetResource @testParam | Should -Be $false
                    }
                }
            }
            #endregion Tests for Test-TargetResource


            #region Tests for Set-TargetResource
            Describe 'TextFile/Set-TargetResource' {

                Context 'Ensure = Present' {

                    It 'Create new file when the file not exist (empty file)' {
                        $txtPath = (Join-Path $TestDrive 'empty.txt')

                        $setParam = @{
                            Ensure = 'Present'
                            Path   = $txtPath
                        }

                        { Set-TargetResource @setParam } | Should -Not -Throw

                        Test-Path -LiteralPath $txtPath | Should -Be $true
                        (Get-Item -LiteralPath $txtPath).Length | Should -Be 0
                    }

                    It 'Overwrite exist file' {
                        'exist file ' | Out-File -FilePath (Join-Path $TestDrive 'exist.txt') -Force
                        $txtPath = (Join-Path $TestDrive 'exist.txt')
                        Test-Path -LiteralPath $txtPath | Should -Be $true

                        $setParam = @{
                            Ensure = 'Present'
                            Path   = $txtPath
                        }

                        { Set-TargetResource @setParam } | Should -Not -Throw

                        Test-Path -LiteralPath $txtPath | Should -Be $true
                        (Get-Item -LiteralPath $txtPath).Length | Should -Be 0
                    }

                    It 'Create txt file (utf8 / CRLF)' {
                        $TestDataPath = (Join-Path $TestData 'utf8_crlf.json')

                        $fileName = [System.Guid]::NewGuid().toString()
                        $txtPath = (Join-Path $TestDrive $fileName)

                        $setParam = @{
                            Ensure   = 'Present'
                            Path     = $txtPath
                            Contents = $MockContent
                            Encoding = 'Utf8'
                            NewLine  = 'CRLF'
                        }

                        { Set-TargetResource @setParam } | Should -Not -Throw

                        Test-Path -LiteralPath $txtPath | Should -Be $true
                        (Get-FileHash $txtPath).Hash -eq (Get-FileHash $TestDataPath).Hash | Should -Be $true
                    }

                    It 'Create txt file (utf8 / LF)' {
                        $TestDataPath = (Join-Path $TestData 'utf8_lf.json')

                        $fileName = [System.Guid]::NewGuid().toString()
                        $txtPath = (Join-Path $TestDrive $fileName)

                        $setParam = @{
                            Ensure   = 'Present'
                            Path     = $txtPath
                            Contents = $MockContent
                            Encoding = 'utf8'
                            NewLine  = 'LF'
                        }

                        { Set-TargetResource @setParam } | Should -Not -Throw

                        Test-Path -LiteralPath $txtPath | Should -Be $true
                        (Get-FileHash $txtPath).Hash -eq (Get-FileHash $TestDataPath).Hash | Should -Be $true
                    }

                    It 'Create txt file (utf8BOM / CRLF)' {
                        $TestDataPath = (Join-Path $TestData 'utf8bom_crlf.json')

                        $fileName = [System.Guid]::NewGuid().toString()
                        $txtPath = (Join-Path $TestDrive $fileName)

                        $setParam = @{
                            Ensure   = 'Present'
                            Path     = $txtPath
                            Contents = $MockContent
                            Encoding = 'utf8BOM'
                            NewLine  = 'CRLF'
                        }

                        { Set-TargetResource @setParam } | Should -Not -Throw

                        Test-Path -LiteralPath $txtPath | Should -Be $true
                        (Get-FileHash $txtPath).Hash -eq (Get-FileHash $TestDataPath).Hash | Should -Be $true
                    }

                    It 'Create txt file (unicode / CRLF)' {
                        $TestDataPath = (Join-Path $TestData 'unicode_crlf.json')

                        $fileName = [System.Guid]::NewGuid().toString()
                        $txtPath = (Join-Path $TestDrive $fileName)

                        $setParam = @{
                            Ensure   = 'Present'
                            Path     = $txtPath
                            Contents = $MockContent
                            Encoding = 'unicode'
                            NewLine  = 'CRLF'
                        }

                        { Set-TargetResource @setParam } | Should -Not -Throw

                        Test-Path -LiteralPath $txtPath | Should -Be $true
                        (Get-FileHash $txtPath).Hash -eq (Get-FileHash $TestDataPath).Hash | Should -Be $true
                    }

                    It 'Create txt file (bigendianunicode / CRLF)' {
                        $TestDataPath = (Join-Path $TestData 'bigendianunicode_crlf.json')

                        $fileName = [System.Guid]::NewGuid().toString()
                        $txtPath = (Join-Path $TestDrive $fileName)

                        $setParam = @{
                            Ensure   = 'Present'
                            Path     = $txtPath
                            Contents = $MockContent
                            Encoding = 'bigendianunicode'
                            NewLine  = 'CRLF'
                        }

                        { Set-TargetResource @setParam } | Should -Not -Throw

                        Test-Path -LiteralPath $txtPath | Should -Be $true
                        (Get-FileHash $txtPath).Hash -eq (Get-FileHash $TestDataPath).Hash | Should -Be $true
                    }

                    It 'Create txt file (sjis / CRLF)' {
                        $TestDataPath = (Join-Path $TestData 'sjis_crlf.json')

                        $fileName = [System.Guid]::NewGuid().toString()
                        $txtPath = (Join-Path $TestDrive $fileName)

                        $setParam = @{
                            Ensure   = 'Present'
                            Path     = $txtPath
                            Contents = $MockContent
                            Encoding = 'sjis'
                            NewLine  = 'CRLF'
                        }

                        { Set-TargetResource @setParam } | Should -Not -Throw

                        Test-Path -LiteralPath $txtPath | Should -Be $true
                        (Get-FileHash $txtPath).Hash -eq (Get-FileHash $TestDataPath).Hash | Should -Be $true
                    }

                    It 'Create new txt file when the file not exist (Missing parent directory)' {
                        $txtPath = (Join-Path $TestDrive '\Parent Folder\test.txt')
                        $setParam = @{
                            Ensure   = 'Present'
                            Path     = $txtPath
                            Contents = $MockContent
                        }

                        { Set-TargetResource @setParam } | Should -Not -Throw
                        Test-Path -LiteralPath $txtPath | Should -Be $true
                    }
                }


                Context 'Ensure = Absent' {

                    It 'Remove file when the file exist' {
                        $fileName = [System.Guid]::NewGuid().toString()
                        $txtPath = (Join-Path $TestDrive $fileName)
                        'exist' | Out-File -FilePath $txtPath -Force
                        Test-Path -LiteralPath $txtPath | Should -Be $true

                        $setParam = @{
                            Ensure = 'Absent'
                            Path   = $txtPath
                        }

                        { Set-TargetResource @setParam } | Should -Not -Throw
                        Test-Path -LiteralPath $txtPath | Should -Be $false
                    }

                    It 'Should not throw even if the file not exist' {
                        $txtPath = (Join-Path $TestDrive $NonExistMock)
                        Test-Path -LiteralPath $txtPath | Should -Be $false

                        $setParam = @{
                            Ensure = 'Absent'
                            Path   = $txtPath
                        }

                        { Set-TargetResource @setParam } | Should -Not -Throw
                        Test-Path -LiteralPath $txtPath | Should -Be $false
                    }
                }
            }
            #endregion Tests for Set-TargetResource
        }
    }
}
