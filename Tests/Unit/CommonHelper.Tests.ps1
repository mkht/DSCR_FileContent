#Requires -Modules @{ ModuleName="Pester"; ModuleVersion="5.3.1"; MaximumVersion="5.99.99" }

# Begin Testing
Describe 'Tests for CommonHelper' {

    BeforeAll {
        # Import TestHelper
        $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
        Import-Module (Join-Path $script:moduleRoot '\DSCResources\CommonHelper.psm1') -Force
        Import-Module (Join-Path $PSScriptRoot '\TestHelper\TestHelper.psm1') -Force
        $global:TestData = Join-Path $PSScriptRoot '\TestData'

        #region Set variables for testing
        $SingleLineString = "Hello PowerShell!"
        $MultiLineStringCRLF = "Hello PowerShell!`r`nThis is 2nd Line"
        $MultiLineStringLF = "Hello PowerShell!`nThis is 2nd Line"
        #endregion Set variables for testing
    }

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
                { $null = Convert-NewLine -InputObject $SingleLineString -NewLine 'CRLF' } | Should -Not -Throw
                { $null = Convert-NewLine -InputObject $SingleLineString -NewLine 'LF' } | Should -Not -Throw
                { $null = Convert-NewLine -InputObject $SingleLineString -NewLine 'foo' } | Should -Throw
            }
        }
    }

    Describe 'Get-Encoding' {

        It '"utf8" to utf8 without bom' {
            $Enc = Get-Encoding -Encoding "utf8"
            $Enc | Should -BeOfType [System.Text.Encoding]
            $Enc.BodyName | Should -BeExactly "utf-8"
            $Enc.GetPreamble() | Should -Be $null   #NoBOM
        }

        It '"utf8NoBOM" to utf8 without bom' {
            $Enc = Get-Encoding -Encoding "utf8NoBOM"
            $Enc | Should -BeOfType [System.Text.Encoding]
            $Enc.BodyName | Should -BeExactly "utf-8"
            $Enc.GetPreamble() | Should -Be $null   #NoBOM
        }

        It '"utf8BOM" to utf8 with bom' {
            $Enc = Get-Encoding -Encoding "utf8BOM"
            $Enc | Should -BeOfType [System.Text.Encoding]
            $Enc.BodyName | Should -BeExactly "utf-8"
            $Enc.GetPreamble() | Should -Be @(239, 187, 191)
        }

        It '"Default" to Default' {
            $Enc = Get-Encoding -Encoding "Default"
            $Enc | Should -BeOfType [System.Text.Encoding]
            $Enc.BodyName | Should -BeExactly ([System.Text.Encoding]::Default.BodyName)
        }

        It '"utf32" to utf32' {
            $Enc = Get-Encoding -Encoding "utf32"
            $Enc | Should -BeOfType [System.Text.Encoding]
            $Enc.BodyName | Should -BeExactly 'utf-32'
        }

        It '"unicode" to unicode' {
            $Enc = Get-Encoding -Encoding "unicode"
            $Enc | Should -BeOfType [System.Text.Encoding]
            $Enc.BodyName | Should -BeExactly 'utf-16'
        }

        It '"bigendianunicode" to bigendianunicode' {
            $Enc = Get-Encoding -Encoding "bigendianunicode"
            $Enc | Should -BeOfType [System.Text.Encoding]
            $Enc.BodyName | Should -BeExactly 'utf-16BE'
        }

        It '"ascii" to ascii' {
            $Enc = Get-Encoding -Encoding "ascii"
            $Enc | Should -BeOfType [System.Text.Encoding]
            $Enc.BodyName | Should -BeExactly 'us-ascii'
        }

        It '"sjis" to "shift-jis"' {
            $Enc = Get-Encoding -Encoding "sjis"
            $Enc | Should -BeOfType [System.Text.Encoding]
            $Enc.CodePage | Should -Be 932
        }

        It 'Throw exception if the input is undefined string' {
            { Get-Encoding -Encoding "foo" } | Should -Throw
        }
    }
}
