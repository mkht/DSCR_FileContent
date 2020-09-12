Enum Encoding {
    Default
    utf8
    utf8NoBOM
    utf8BOM
    utf32
    unicode
    bigendianunicode
    ascii
    sjis
}


function Convert-NewLine {
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [AllowEmptyString()]
        [string]
        $InputObject,

        [Parameter(Position = 1)]
        [ValidateSet('CRLF', 'LF')]
        [string]
        $NewLine = 'CRLF'

    )

    if ($NewLine -eq 'LF') {
        $InputObject.Replace("`r`n", "`n")
    }
    else {
        $InputObject -replace "(?<!\r)\n", "`r`n"
    }
}


function Get-Encoding {
    [OutputType([System.text.Encoding])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [Encoding]
        $Encoding
    )

    switch ($Encoding) {
        'utf8' {
            [System.Text.UTF8Encoding]::new($false) #NoBOM
            break
        }
        'utf8NoBOM' {
            [System.Text.UTF8Encoding]::new($false) #NoBOM
            break
        }
        'utf8BOM' {
            [System.Text.UTF8Encoding]::new($true) #WithBOM
            break
        }
        'utf32' {
            [System.Text.Encoding]::UTF32
            break
        }
        'unicode' {
            [System.Text.Encoding]::Unicode
            break
        }
        'bigendianunicode' {
            [System.Text.Encoding]::BigEndianUnicode
            break
        }
        'ascii' {
            [System.Text.Encoding]::ASCII
            break
        }
        'sjis' {
            [System.Text.Encoding]::GetEncoding(932)
            break
        }
        Default {
            [System.Text.Encoding]::Default
        }
    }
}

function Get-NewContent {
    [CmdletBinding(DefaultParameterSetName = 'Array')]
    [OutputType([string[]], ParameterSetName = 'Array')]
    [OutputType([string], ParameterSetName = 'Raw')]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('LiteralPath', 'PSPath')]
        [string[]]$Path,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Encoding]$Encoding = 'default',

        [Parameter(ParameterSetName = 'Raw')]
        [switch]$Raw
    )

    Process {
        $NativeEncoding = Get-Encoding $Encoding

        foreach ($item in $Path) {
            try {
                if ($PSCmdlet.ParameterSetName -eq 'Array') {
                    [System.IO.File]::ReadAllLines($Path, $NativeEncoding)
                }
                elseif ($PSCmdlet.ParameterSetName -eq 'Raw') {
                    [System.IO.File]::ReadAllText($Path, $NativeEncoding)
                }
            }
            catch {
                Write-Error -Exception $_.Exception
            }
        }
    }
}

function Set-NewContent {
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('LiteralPath', 'PSPath')]
        [string[]]$Path,

        [Parameter(Mandatory, Position = 1, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [AllowEmptyString()]
        [string]$Value,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Encoding]$Encoding = 'utf8',

        [Parameter()]
        [ValidateSet('CRLF', 'LF')]
        [string]$NewLine = 'CRLF',

        [Parameter()]
        [switch]$NoNewLine,

        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [switch]$PassThru
    )

    Process {
        $NativeEncoding = Get-Encoding $Encoding

        if ($PSVersionTable.PSVersion.Major -ge 6) {
            $Value | Convert-NewLine -NewLine $NewLine |`
                Set-Content -LiteralPath $Path -Value $Value -NoNewline:$NoNewLine -Force:$Force -PassThru:$PassThru -Encoding $NativeEncoding
        }
        else {
            if ($Encoding -eq 'utf8BOM') {
                $Value | Convert-NewLine -NewLine $NewLine |`
                    Set-Content -LiteralPath $Path -Value $Value -NoNewline:$NoNewLine -Force:$Force -PassThru:$PassThru -Encoding utf8
            }
            else {
                $Value | Convert-NewLine -NewLine $NewLine |`
                    ForEach-Object { $NativeEncoding.GetBytes($_) } |`
                    Set-Content -LiteralPath $Path -Value $Value -NoNewline:$NoNewLine -Force:$Force -PassThru:$PassThru -Encoding Byte
            }
        }
    }
}

Export-ModuleMember -Function @(
    'Convert-NewLine',
    'Get-Encoding',
    'Get-NewContent',
    'Set-NewContent'
)
