# Import CommonHelper
$script:dscResourcesFolderFilePath = Split-Path $PSScriptRoot -Parent
$script:commonHelperFilePath = Join-Path -Path $script:dscResourcesFolderFilePath -ChildPath 'CommonHelper.psm1'
Import-Module -Name $script:commonHelperFilePath


function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Path
    )

    $returnValue = @{
        Ensure   = 'Absent'
        Path     = $Path
        Contents = $null
    }
    # check file exists
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Write-Verbose ('File "{0}" not found.' -f $Path)
        $returnValue.Ensure = 'Absent'
    }
    else {
        $returnValue.Ensure = 'Present'

        $Item = Get-Item -LiteralPath $Path

        if ($Item.Length -gt 2048) {
            Write-Warning ('The file size is over 2 KB, so reading is canceled.')
        }
        else {
            $returnValue.Contents = (Get-NewContent -LiteralPath $Path -Raw)
        }
    }

    $returnValue
} # end of Get-TargetResource


function Set-TargetResource {
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [string]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter()]
        [AllowEmptyString()]
        [string]
        $Contents = '',

        [Parameter()]
        [ValidateSet('utf8', 'utf8NoBOM', 'utf8BOM', 'utf32', 'unicode', 'bigendianunicode', 'ascii', 'sjis', 'Default')]
        [string]
        $Encoding = 'utf8NoBOM',

        [Parameter()]
        [ValidateSet('CRLF', 'LF')]
        [string]
        $NewLine = 'CRLF'
    )


    # Ensure = 'Absent'
    if ($Ensure -eq 'Absent') {
        if (Test-Path -LiteralPath $Path -PathType Leaf) {
            Write-Verbose ("Removing File '{0}'" -f $Path)
            Remove-Item -LiteralPath $Path
        }
    }
    else {
        # Ensure = 'Present'

        # Create parent directory if not exist
        $ParentFolder = Split-Path -Path $Path -Parent -ErrorAction SilentlyContinue
        if ($ParentFolder -and (-not (Test-Path -Path $ParentFolder -PathType Container))) {
            $null = New-Item -Path $ParentFolder -ItemType Directory -Force -ErrorAction Stop
        }

        # Create empty file when the Contents parameter is not specified
        if ([string]::IsNullOrEmpty($Contents)) {
            $null = New-Item -Path $Path -ItemType File -Force
        }
        else {
            #Output text file
            Write-Verbose ("Creating File '{0}'" -f $Path)
            $Contents | Set-NewContent -Path $Path -Encoding $Encoding -NoNewline -Force -ErrorAction Stop
        }
    }
} # end of Set-TargetResource


function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [string]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter()]
        [AllowEmptyString()]
        [string]
        $Contents = '',

        [Parameter()]
        [ValidateSet('utf8', 'utf8NoBOM', 'utf8BOM', 'utf32', 'unicode', 'bigendianunicode', 'ascii', 'sjis', 'Default')]
        [string]
        $Encoding = 'utf8NoBOM',

        [Parameter()]
        [ValidateSet('CRLF', 'LF')]
        [string]
        $NewLine = 'CRLF'
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Write-Verbose ('The File {0} is not exist.' -f $Path)
        return ($Ensure -eq 'Absent')
    }
    elseif ($Ensure -eq 'Absent') {
        Write-Verbose ('The File {0} is exist. Test FAILED' -f $Path)
        return $false
    }
    else {
        $CurrentFile = Get-Item -LiteralPath $Path

        $Encoder = Get-Encoding -Encoding $Encoding -ErrorAction Stop
        $ContentBytes = $Contents | Convert-NewLine -NewLine $NewLine | ForEach-Object {
            if (($Encoding -eq 'utf8') -or ($Encoding -eq 'utf8NoBOM')) {
                $Encoder.GetBytes($_)
            }
            else {
                # Append BOM
                $Encoder.GetPreamble() + $Encoder.GetBytes($_)
            }
        }

        # Test Length
        if ($CurrentFile.Length -ne $ContentBytes.Length) {
            Write-Verbose ('File size is not matched. Test FAILED.')
            return $false
        }
        elseif ($ContentBytes.Length -eq 0) {
            Write-Verbose ('File size is matched (zero). Test PASSED.')
            return $true
        }

        # Test Hash
        try {
            $MemoryStream = [System.IO.MemoryStream]::New($ContentBytes)

            $ContentsHash = Get-FileHash -InputStream $MemoryStream -Algorithm SHA1
            $CurrentFileHash = Get-FileHash -LiteralPath $Path -Algorithm SHA1

            $TestResult = $CurrentFileHash.Hash -eq $ContentsHash.Hash
            if (-not $TestResult) {
                Write-Verbose ('File hash is not matched. Test FAILED.')
                return $false
            }
            else {
                Write-Verbose ('File hash is matched. Test PASSED.')
                return $true
            }
        }
        catch {
            Write-Error -Exception $_.Exception
        }
        finally {
            if ($null -ne $MemoryStream) {
                $MemoryStream.Close()
            }
        }
    }

    return $true
} # end of Test-TargetResource
