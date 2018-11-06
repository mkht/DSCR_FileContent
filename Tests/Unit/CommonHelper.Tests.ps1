# Begin Testing
Describe 'Tests for CommonHelper' {

    BeforeAll {
        # Import TestHelper
        $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
        Import-Module (Join-Path $script:moduleRoot '\DSCResources\TextFile\TextFile.psm1') -Force
        Import-Module (Join-Path $PSScriptRoot '\TestHelper\TestHelper.psm1') -Force
        $global:TestData = Join-Path $PSScriptRoot '\TestData'
    }

    InModuleScope 'CommonHelper' {
        #region Set variables for testing
        $SingleLineString = "Hello PowerShell!"
        $MultiLineStringCRLF = "Hello PowerShell!`r`nThis is 2nd Line"
        $MultiLineStringLF = "Hello PowerShell!`nThis is 2nd Line"
        #endregion Set variables for testing

        #region Tests for Get-TargetResource
        Describe 'Convert-NewLine' {

            Context 'NewLine = "CRLF"' {

                It 'Input Single line string, Returns Single line string' {
                    Convert-NewLine -InputObject $SingleLineString -NewLine 'CRLF' | Should -BeExactly $SingleLineString
                }

                It 'Input multi line CRLF string, Returns same CRLF string' {
                    Convert-NewLine -InputObject $MultiLineStringCRLF -NewLine 'CRLF' | Should -BeExactly $MultiLineStringCRLF
                }

                It 'Input multi line LF string, Returns CRLF converted string' {
                    Convert-NewLine -InputObject $MultiLineStringLF -NewLine 'CRLF' | Should -BeExactly $MultiLineStringCRLF
                }

            }

            Context 'NewLine = "LF"' {

                It 'Input Single line string, Returns Single line string' {
                    Convert-NewLine -InputObject $SingleLineString -NewLine 'LF' | Should -BeExactly $SingleLineString
                }

                It 'Input multi line LF string, Returns same LF string' {
                    Convert-NewLine -InputObject $MultiLineStringLF -NewLine 'LF' | Should -BeExactly $MultiLineStringLF
                }

                It 'Input multi line CRLF string, Returns LF converted string' {
                    Convert-NewLine -InputObject $MultiLineStringCRLF -NewLine 'LF' | Should -BeExactly $MultiLineStringLF
                }
            }

            Context 'Parameter validation' {

                It 'Input from pipeline' {
                    ($MultiLineStringLF | Convert-NewLine -NewLine 'CRLF') | Should -BeExactly $MultiLineStringCRLF
                }

                It 'Allow empty string input' {
                    Convert-NewLine -InputObject [string]::Empty -NewLine 'CRLF' | Should -BeExactly [string]::Empty
                }

                It 'Positional parameter' {
                    Convert-NewLine $SingleLineString 'CRLF' | Should -BeExactly $SingleLineString
                }

                It 'Default NewLine is CRLF' {
                    Convert-NewLine -InputObject $MultiLineStringLF | Should -BeExactly $MultiLineStringCRLF
                }

                It 'Values allowed for parameter NewLine are CRLF or LF' {
                    {$null = Convert-NewLine -InputObject $SingleLineString -NewLine 'CRLF'} | Should -Not -Throw
                    {$null = Convert-NewLine -InputObject $SingleLineString -NewLine 'LF'} | Should -Not -Throw
                    {$null = Convert-NewLine -InputObject $SingleLineString -NewLine 'foo'} | Should -Throw
                }
            }
        }

        Describe 'Get-PSEncoding' {

            It '"utf8" to "utf8"' {
                Get-PSEncoding -Encoding "utf8" | Should -BeExactly "utf8"
            }

            It '"utf8NoBOM" to "utf8"' {
                Get-PSEncoding -Encoding "utf8NoBOM" | Should -BeExactly "utf8"
            }

            It '"utf8BOM" to "utf8"' {
                Get-PSEncoding -Encoding "utf8BOM" | Should -BeExactly "utf8"
            }

            It '"Default" to "Default"' {
                Get-PSEncoding -Encoding "Default" | Should -BeExactly "Default"
            }

            It '"utf32" to "utf32"' {
                Get-PSEncoding -Encoding "utf32" | Should -BeExactly "utf32"
            }

            It '"unicode" to "unicode"' {
                Get-PSEncoding -Encoding "unicode" | Should -BeExactly "unicode"
            }

            It '"bigendianunicode" to "bigendianunicode"' {
                Get-PSEncoding -Encoding "bigendianunicode" | Should -BeExactly "bigendianunicode"
            }

            It '"ascii" to "ascii"' {
                Get-PSEncoding -Encoding "ascii" | Should -BeExactly "ascii"
            }

            It 'Throws exception when the input is undefined string' {
                {Get-PSEncoding -Encoding "foo"} | Should -Throw
            }
        }
    }
}
