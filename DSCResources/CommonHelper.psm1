Enum Encoding {
    Default
    utf8
    utf8NoBOM
    utf8BOM
    utf32
    unicode
    bigendianunicode
    ascii
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


function Get-PSEncoding {
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [Encoding]
        $Encoding
    )

    switch -wildcard ($Encoding) {
        'utf8*' {
            'utf8'
            break
        }
        Default {
            $_.toString()
        }
    }
}

Export-ModuleMember -Function @(
    'Convert-NewLine',
    'Get-PSEncoding'
)
