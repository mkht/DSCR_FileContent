# Import CommonHelper
$script:dscResourcesFolderFilePath = Split-Path $PSScriptRoot -Parent
$script:commonHelperFilePath = Join-Path -Path $script:dscResourcesFolderFilePath -ChildPath 'CommonHelper.psm1'
Import-Module -Name $script:commonHelperFilePath


#region Get-TargetResource
function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet("Present", "Absent")]
        [string]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter(Mandatory = $true)]
        [string]
        $Key,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $Value,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Value', 'ArrayElement')]
        [string]
        $Mode = 'Value',

        [Parameter(Mandatory = $false)]
        [ValidateSet('utf8', 'utf8NoBOM', 'utf8BOM', 'utf32', 'unicode', 'bigendianunicode', 'ascii', 'Default')]
        [string]
        $Encoding = 'utf8NoBOM',

        [Parameter(Mandatory = $false)]
        [ValidateSet('CRLF', 'LF')]
        [string]
        $NewLine = 'CRLF'
    )

    $Result = @{
        Ensure = 'Present'
        Path   = $Path
        Key    = $null
        Value  = $null
    }

    $ValueObject = $null
    $tmp = try {
        ConvertFrom-Json -InputObject $Value -ErrorAction Ignore
    }
    catch {}

    if ($null -eq $tmp) {
        if ([bool]::TryParse($Value, [ref]$null)) {
            $ValueObject = [bool]::Parse($Value)
        }
        elseif ($Value -eq 'null') {
            $ValueObject = $null
        }
        else {
            $ValueObject = $Value
        }
    }
    elseif ($tmp.GetType().Name -eq 'PSCustomObject') {
        $ValueObject = ConvertTo-HashTable -InputObject $tmp
    }
    else {
        $ValueObject = $tmp
    }

    # check file exists
    if (-not (Test-Path $Path -PathType Leaf)) {
        Write-Verbose ('File "{0}" not found.' -f $Path)
        $Result.Ensure = 'Absent'
    }
    else {
        # Read JSON
        $Json = try {
            $PSEncoder = Get-PSEncoding -Encoding $Encoding
            Get-Content -Path $Path -Raw -Encoding $PSEncoder | ConvertFrom-Json -ErrorAction Ignore
        }
        catch {}

        if (-not $Json) {
            Write-Verbose ("Couldn't read {0}" -f $Path)
            $Result.Ensure = 'Absent'
        }

        else {
            $JsonHash = ConvertTo-HashTable -InputObject $Json

            $KeyHierarchy = $Key -split '/'
            $tHash = $JsonHash
            for ($i = 0; $i -lt $KeyHierarchy.Count; $i++) {
                $local:tKey = $KeyHierarchy[$i]

                if (($null -eq $tHash.GetType().GetMethod('Contains')) -or (-not $tHash.Contains($tKey))) {
                    Write-Verbose ('The key "{0}" is not found' -f $tKey)
                    $Result.Ensure = 'Absent'
                    break
                }

                if ($i -gt ($KeyHierarchy.Count - 2)) {
                    $Result.Key = $Key
                    $Result.Value = ConvertTo-Json -InputObject $tHash.$tKey -Compress

                    switch ($Mode) {
                        'Value' {
                            if (-not (Compare-MyObject $tHash.$tKey $ValueObject)) {
                                Write-Verbose 'The Value of Key is not matched'
                                $Result.Ensure = 'Absent'
                            }
                        }

                        'ArrayElement' {
                            if ($tHash.$tKey -is [Array]) {
                                $contains = $false
                                $tHash.$tKey | % {
                                    if (Compare-MyObject $_ $ValueObject) {
                                        $contains = $true
                                        return
                                    }
                                }

                                if (-not $contains) {
                                    Write-Verbose 'The Value of Key is not matched'
                                    $Result.Ensure = 'Absent'
                                }
                            }
                            else {
                                Write-Verbose 'The Value of Key is not matched'
                                $Result.Ensure = 'Absent'
                            }
                        }
                    }

                    break
                }
                else {
                    $tHash = $tHash.$tKey
                }
            }
        }
    }

    $Result
}
#endregion Get-TargetResource


#region Test-TargetResource
function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet("Present", "Absent")]
        [string]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter(Mandatory = $true)]
        [string]
        $Key,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $Value,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Value', 'ArrayElement')]
        [string]
        $Mode = 'Value',

        [Parameter(Mandatory = $false)]
        [ValidateSet('utf8', 'utf8NoBOM', 'utf8BOM', 'utf32', 'unicode', 'bigendianunicode', 'ascii', 'Default')]
        [string]
        $Encoding = 'utf8NoBOM',

        [Parameter(Mandatory = $false)]
        [ValidateSet('CRLF', 'LF')]
        [string]
        $NewLine = 'CRLF'
    )

    [bool]$result = (Get-TargetResource @PSBoundParameters).Ensure -eq $Ensure

    if ($result) {Write-Verbose 'The test passed'}
    else {Write-Verbose 'The test failed'}

    return $result
}
#endregion Test-TargetResource


#region Set-TargetResource
function Set-TargetResource {
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet("Present", "Absent")]
        [string]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter(Mandatory = $true)]
        [string]
        $Key,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $Value,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Value', 'ArrayElement')]
        [string]
        $Mode = 'Value',

        [Parameter(Mandatory = $false)]
        [ValidateSet('utf8', 'utf8NoBOM', 'utf8BOM', 'utf32', 'unicode', 'bigendianunicode', 'ascii', 'Default')]
        [string]
        $Encoding = 'utf8NoBOM',

        [Parameter(Mandatory = $false)]
        [ValidateSet('CRLF', 'LF')]
        [string]
        $NewLine = 'CRLF'
    )

    $PSEncoder = Get-PSEncoding -Encoding $Encoding

    $ValueObject = $null
    $tmp = try {
        ConvertFrom-Json -InputObject $Value -ErrorAction Ignore
    }
    catch {}

    if ($null -eq $tmp) {
        if ([bool]::TryParse($Value, [ref]$null)) {
            $ValueObject = [bool]::Parse($Value)
        }
        elseif ($Value -eq 'null') {
            $ValueObject = $null
        }
        else {
            $ValueObject = $Value
        }
    }
    elseif ($tmp.GetType().Name -eq 'PSCustomObject') {
        $ValueObject = ConvertTo-HashTable -InputObject $tmp
    }
    else {
        $ValueObject = $tmp
    }

    $JsonHash = $null
    if (Test-Path -Path $Path -PathType Leaf) {
        $JsonHash = try {
            $Json = Get-Content -Path $Path -Raw -Encoding $PSEncoder | ConvertFrom-Json -ErrorAction Ignore
            if ($Json) {
                ConvertTo-HashTable -InputObject $Json
            }
        }
        catch {}
    }

    # Ensure = "Absent"
    if ($Ensure -eq 'Absent') {
        if ($JsonHash) {
            $KeyHierarchy = $Key -split '/'
            $expression = '$JsonHash'
            for ($i = 0; $i -lt $KeyHierarchy.Count; $i++) {
                if ($i -ne ($KeyHierarchy.Count - 1)) {
                    $expression += ('.{0}' -f $KeyHierarchy[$i])
                }
                else {
                    if (Invoke-Expression -Command $expression) {
                        switch ($Mode) {
                            'Value' {
                                Write-Verbose ('The key "{0}" will be removed' -f $KeyHierarchy[$i])
                                $expression += (".Remove('{0}')" -f $KeyHierarchy[$i])
                            }
                            'ArrayElement' {
                                $tmpex = $expression + (".{0}" -f $KeyHierarchy[$i])
                                $v = Invoke-Expression -Command $tmpex
                                if ($v -is [Array]) {
                                    $script:newValue = $v | Where-Object {-not (Compare-MyObject $_ $ValueObject)}
                                    if ($null -eq $script:newValue) {
                                        Write-Verbose ('The key "{0}" will be removed' -f $KeyHierarchy[$i])
                                        $expression += (".Remove('{0}')" -f $KeyHierarchy[$i])
                                    }
                                    else {
                                        Write-Verbose ('The key "{0}" will be modified' -f $KeyHierarchy[$i])
                                        $expression += ('.{0} = @($script:newValue)' -f $KeyHierarchy[$i])
                                    }
                                }
                                else {
                                    Write-Verbose ('The key "{0}" will be removed' -f $KeyHierarchy[$i])
                                    $expression += (".Remove('{0}')" -f $KeyHierarchy[$i])
                                }
                            }
                        }
                    }
                }
            }

            Invoke-Expression -Command $expression
        }
    }
    else {
        # Ensure = "Present"
        if ($null -eq $JsonHash) {
            $JsonHash = @{}
        }

        # Workaroud for ConvertTo-Json bug
        # https://github.com/PowerShell/PowerShell/issues/3153
        if ($ValueObject -is [Array]) {
            $ValueObject = $ValueObject.SyncRoot
        }

        $KeyHierarchy = $Key -split '/'
        $tHash = $JsonHash
        for ($i = 0; $i -lt $KeyHierarchy.Count; $i++) {
            if ($i -lt ($KeyHierarchy.Count - 1)) {

                if (-not $tHash.Contains($KeyHierarchy[$i])) {
                    $tHash.($KeyHierarchy[$i]) = @{}
                }
                elseif (-not ($tHash.($KeyHierarchy[$i]) -as [hashtable])) {
                    $tHash.($KeyHierarchy[$i]) = @{}
                }

                $tHash = $tHash.($KeyHierarchy[$i])
            }
            else {
                switch ($Mode) {
                    'Value' {
                        $tHash.($KeyHierarchy[$i]) = $ValueObject
                    }

                    'ArrayElement' {
                        if ($tHash.($KeyHierarchy[$i]) -is [Array]) {
                            if ($tHash.($KeyHierarchy[$i]) | Where-Object { -not (Compare-MyObject $_ $ValueObject)}) {
                                Write-Verbose ('The key "{0}" will be modified' -f $KeyHierarchy[$i])
                                $tHash.($KeyHierarchy[$i]) += $ValueObject
                            }
                        }
                        elseif ($tHash.Contains($KeyHierarchy[$i])) {
                            $newValue = @($tHash.($KeyHierarchy[$i]), $ValueObject)
                            Write-Verbose ('The key "{0}" will be modified' -f $KeyHierarchy[$i])
                            $tHash.($KeyHierarchy[$i]) = $newValue
                        }
                        else {
                            Write-Verbose ('The key "{0}" will be modified' -f $KeyHierarchy[$i])
                            $tHash.($KeyHierarchy[$i]) = @($ValueObject)
                        }
                    }
                }

                break
            }
        }
    }

    # Create directory if not exist
    $ParentFolder = Split-Path -Path $Path -Parent -ErrorAction SilentlyContinue
    if ($ParentFolder -and (-not (Test-Path -Path $ParentFolder -PathType Container))) {
        $null = New-Item -Path $ParentFolder -ItemType Directory -Force -ErrorAction Stop
    }

    # Save Json file
    if (('utf8', 'utf8NoBOM') -eq $Encoding) {
        ConvertTo-Json -InputObject $JsonHash -Depth 100 | Format-Json | Out-String | Convert-NewLine -NewLine $NewLine | ForEach-Object { [System.Text.Encoding]::UTF8.GetBytes($_) } | Set-Content -Path $Path -Encoding Byte -NoNewline -Force -ErrorAction Stop
        Write-Verbose ('Json file "{0}" has been saved' -f $Path)
    }
    else {
        ConvertTo-Json -InputObject $JsonHash -Depth 100 | Convert-NewLine -NewLine $NewLine | Set-Content -Path $Path -Encoding $PSEncoder -NoNewline -Force -ErrorAction Stop
        Write-Verbose ('The key "{0}" will be modified' -f $KeyHierarchy[$i])
        Write-Verbose ('Json file "{0}" has been saved' -f $Path)
    }
}
#endregion Set-TargetResource


#region ConvertTo-HashTable
function ConvertTo-HashTable {

    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [AllowNull()]
        [PSObject]
        $InputObject
    )

    if ($InputObject -isnot [System.Management.Automation.PSCustomObject]) {
        return $InputObject
    }

    $Output = [ordered]@{}
    $InputObject.psobject.properties | Where-Object {$_.MemberType -eq 'NoteProperty'} | ForEach-Object {


        if ($_.Value -is [System.Management.Automation.PSCustomObject]) {
            $Output[$_.Name] = ConvertTo-HashTable -InputObject $_.Value
        }
        elseif ($_.Value -is [Array]) {
            $Output[$_.Name] = @($_.Value | ForEach-Object {ConvertTo-HashTable -InputObject $_})
        }
        else {
            $Output[$_.Name] = $_.Value
        }
    }

    $Output
}
#endregion ConvertTo-HashTable


#region Compare-Hashtable
function Compare-Hashtable {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true)]
        [Hashtable]$Left,

        [Parameter(Mandatory = $true)]
        [Hashtable]$Right
    )

    $Result = $true

    if ($Left.Keys.Count -ne $Right.keys.Count) {
        $Result = $false
    }

    $Left.Keys | ForEach-Object {

        if (-not $Result) {
            return
        }

        if (-not (Compare-MyObject -Left $Left[$_] -Right $Right[$_])) {
            $Result = $false
        }
    }

    $Result
}
#endregion Compare-Hashtable


#region Compare-MyObject
function Compare-MyObject {
    [CmdletBinding()]
    [OutputType([bool])]
    Param(
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [Object]$Left,

        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [Object]$Right
    )

    $Result = $true

    if (($null -eq $Left) -or ($null -eq $Right)) {
        $Result = ($null -eq $Left) -and ($null -eq $Right)
    }
    elseif (($Left -as [HashTable]) -and ($Right -as [HashTable])) {
        if (-not (Compare-Hashtable $Left $Right)) {
            $Result = $false
        }
    }
    elseif ($Left.GetType().FullName -ne $Right.GetType().FullName) {
        $Result = $false
    }
    elseif ($Left.Count -ne $Right.Count) {
        $Result = $false
    }
    elseif ($Left.Count -gt 1) {
        $Result = Compare-Array $Left $Right
    }
    else {
        if (Compare-Object $Left $Right -CaseSensitive) {
            $Result = $false
        }
    }

    $Result
}
#endregion Compare-MyObject


#region Compare-Array
function Compare-Array {
    [CmdletBinding()]
    [OutputType([bool])]
    Param(
        [Parameter(Mandatory = $true)]
        [Object[]]$Left,

        [Parameter(Mandatory = $true)]
        [Object[]]$Right
    )

    $Result = $true

    if ($Left.Count -ne $Right.Count) {
        return $false
    }
    else {
        for ($i = 0; $i -lt $Left.Count; $i++) {
            if (-not (Compare-MyObject $Left[$i] $Right[$i])) {
                $Result = $false
                break
            }
        }
    }

    $Result

}
#endregion Compare-Array


#region Format-Json
# Original code obtained from https://github.com/PowerShell/PowerShell/issues/2736
# Formats JSON in a nicer format than the built-in ConvertTo-Json does.
function Format-Json {
    param
    (
        [Parameter(Mandatory, ValueFromPipeline)]
        [String]
        $json
    )

    $indent = 0;
    $result = ($json -Split '\n' |
            % {
            if ($_ -match '[\}\]]') {
                # This line contains  ] or }, decrement the indentation level
                $indent--
            }
            $line = (' ' * $indent * 2) + $_.TrimStart().Replace(':  ', ': ')
            if ($_ -match '[\{\[]') {
                # This line contains [ or {, increment the indentation level
                $indent++
            }
            $line
        }) -Join "`n"

    # Unescape Html characters (<>&')
    $result.Replace('\u0027', "'").Replace('\u003c', "<").Replace('\u003e', ">").Replace('\u0026', "&")

}
#endregion Format-Json


Export-ModuleMember -Function *-TargetResource
