# Import CommonHelper
$script:dscResourcesFolderFilePath = Split-Path $PSScriptRoot -Parent
$script:commonHelperFilePath = Join-Path -Path $script:dscResourcesFolderFilePath -ChildPath 'CommonHelper.psm1'
Import-Module -Name $script:commonHelperFilePath


Enum Ensure {
    Absent
    Present
}

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


function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [string]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $Key,

        [Parameter()]
        [AllowEmptyString()]
        [string]
        $Value = '',

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $Section = '_ROOT_',

        [Parameter()]
        [string]
        [ValidateSet('utf8', 'utf8NoBOM', 'utf8BOM', 'utf32', 'unicode', 'bigendianunicode', 'ascii', 'Default')]
        $Encoding = 'utf8NoBOM',

        [Parameter()]
        [ValidateSet('CRLF', 'LF')]
        [string]
        $NewLine = 'CRLF'
    )

    if (-not $Section) { $Section = '_ROOT_' }
    [string]$tmpValue = ''

    # check file exists
    if (-not (Test-Path $Path -PathType Leaf)) {
        Write-Verbose ('File "{0}" not found.' -f $Path)
        $Ensure = [Ensure]::Absent
    }
    else {
        #Load ini file
        $Ini = Get-IniFile -Path $Path -Encoding $Encoding

        # if $key is empty, only check section
        if (-not $Key) {
            if ($Ini.$Section) {
                Write-Verbose ('Desired Section found ([{0}])' -f $Section)
                $Ensure = [Ensure]::Present
            }
            else {
                Write-Verbose ('Desired Section NOT found ([{0}])' -f $Section)
                $Ensure = [Ensure]::Absent
            }
        }
        # check section and key exists
        elseif ($Ini.$Section.Contains($Key)) {
            # check value
            Write-Verbose ('Current KVP (Key:"{0}"; Value:"{1}"; Section:"{2}")' -f $Key, $tmpValue, $Section)
            $Ensure = [Ensure]::Present
            $tmpValue = $Ini.$Section.$Key
        }
        else {
            Write-Verbose ('Desired Key or Section not found.')
            $Ensure = [Ensure]::Absent
        }
    }

    $returnValue = @{
        Ensure  = $Ensure
        Path    = $Path
        Key     = $Key
        Value   = $tmpValue
        Section = $PSBoundParameters.Section
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

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $Key,

        [Parameter()]
        [AllowEmptyString()]
        [string]
        $Value = '',

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $Section = '_ROOT_',

        [Parameter()]
        [ValidateSet('utf8', 'utf8NoBOM', 'utf8BOM', 'utf32', 'unicode', 'bigendianunicode', 'ascii', 'Default')]
        [string]
        $Encoding = 'utf8NoBOM',

        [Parameter()]
        [ValidateSet('CRLF', 'LF')]
        [string]
        $NewLine = 'CRLF'
    )

    $PSEncoder = Get-PSEncoding -Encoding $Encoding

    if (-not $Section) { $Section = '_ROOT_' }

    # Ensure = 'Absent'
    if ($Ensure -eq [Ensure]::Absent) {
        if (Test-Path $Path) {
            Write-Verbose ("Remove Key:{0}; Section:{1} from '{2}'" -f $Key, $Section, $Path)
            $content = Get-IniFile -Path $Path -Encoding $Encoding | Remove-IniKey -Key $Key -Section $Section -PassThru | ConvertTo-IniString

            #Output Ini file
            if (('utf8', 'utf8NoBOM') -eq $Encoding) {
                $content | Out-String | Convert-NewLine -NewLine $NewLine | ForEach-Object { [System.Text.Encoding]::UTF8.GetBytes($_) } | Set-Content -Path $Path -Encoding Byte -NoNewline -Force
            }
            else {
                $content | Out-String | Convert-NewLine -NewLine $NewLine | Set-Content -Path $Path -Encoding $PSEncoder -NoNewline -Force
            }
        }
    }
    else {
        # Ensure = 'Present'
        $Ini = [ordered]@{ }
        if (Test-Path $Path) {
            $Ini = Get-IniFile -Path $Path -Encoding $Encoding
        }
        else {
            Write-Verbose ("Create new file '{0}'" -f $Path)
            New-Item $Path -ItemType File -Force
        }
        $content = $Ini | Set-IniKey -Key $Key -Value $Value -Section $Section -PassThru | ConvertTo-IniString

        #Output Ini file
        if (('utf8', 'utf8NoBOM') -eq $Encoding) {
            $content | Out-String | Convert-NewLine -NewLine $NewLine | ForEach-Object { [System.Text.Encoding]::UTF8.GetBytes($_) } | Set-Content -Path $Path -Encoding Byte -NoNewline -Force
        }
        else {
            $content | Out-String | Convert-NewLine -NewLine $NewLine | Set-Content -Path $Path -Encoding $PSEncoder -NoNewline -Force
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

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $Key,

        [Parameter()]
        [AllowEmptyString()]
        [string]
        $Value = '',

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $Section = '_ROOT_',

        [Parameter()]
        [ValidateSet('utf8', 'utf8NoBOM', 'utf8BOM', 'utf32', 'unicode', 'bigendianunicode', 'ascii', 'Default')]
        [string]
        $Encoding = 'utf8NoBOM',

        [Parameter()]
        [ValidateSet('CRLF', 'LF')]
        [string]
        $NewLine = 'CRLF'
    )

    if (-not $Section) { $Section = '_ROOT_' }

    $Ret = ($Ensure -eq [Ensure]::Present)


    if (-not (Test-Path -Path $Path -PathType Leaf)) {
        $Ret = !$Ret
    }
    else {
        $ini = Get-IniFile -Path $Path -Encoding $Encoding

        if ($ini.$Section) {
            # if $key is empty, only check whether section is exist or not
            if (-not $Key) {
                $Ret = $Ret
            }
            elseif ($ini.$Section.Contains($Key)) {
                if ($Value -ceq $ini.$Section.$Key) {
                    $Ret = $Ret
                }
                else {
                    $Ret = $false
                }
            }
            else {
                $Ret = !$Ret
            }
        }
        else {
            $Ret = !$Ret
        }
    }

    if ($Ret) {
        Write-Verbose ('Test Passed. Nothing needs to do')
    }
    else {
        Write-Verbose 'Test NOT Passed.'
    }

    return $Ret
} # end of Test-TargetResource


<#
.SYNOPSIS
Load ini file and convert to the dictionary object

.PARAMETER Path
The path of the ini file.

.PARAMETER Encoding
You can specify the encoding of the ini file.

.OUTPUTS
[System.Collections.Specialized.OrderedDictionary]

.EXAMPLE
PS> Get-IniFile -Path C:\sample.ini

.NOTES
General notes
#>
function Get-IniFile {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        # Set Target full path to INI
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline)]
        [validateScript( { Test-Path $_ })]
        [Alias('File')]
        [string]
        $Path,

        # specify file encoding
        [Parameter()]
        [Encoding]
        $Encoding = 'utf8NoBOM'
    )

    process {
        # Write-Verbose ('Loading file from {0}' -f $Path)
        $PSEncoder = Get-PSEncoding -Encoding $Encoding
        $Content = Get-Content -Path $Path -Encoding $PSEncoder
        $CurrentSection = '_ROOT_'
        [System.Collections.Specialized.OrderedDictionary]$IniHash = [ordered]@{ }
        $IniHash.Add($CurrentSection, [ordered]@{ })

        foreach ($line in $Content) {
            $line = $line.Trim()
            if ($line -match '^;') {
                # Write-Verbose ('Comment')
                $line = ($line.split(';')[0]).Trim()
            }

            if ($line -match '^\[(.+)\]') {
                # Section
                $CurrentSection = $Matches[1]
                if (-not $IniHash.Contains($CurrentSection)) {
                    # Write-Verbose ('Add Section. Section: {0}' -f $Matches[1])
                    $IniHash.Add($CurrentSection, [ordered]@{ })
                }
            }
            elseif ($line -match '=') {
                #KeyValuePair
                $idx = $line.IndexOf('=')
                [string]$key = $line.Substring(0, $idx)
                [string]$value = $line.Substring($idx + 1)
                # Write-Verbose ('Add KVP. Key: {0}, Value: {1}, Section: {2}' -f $key,$value,$CurrentSection)
                $IniHash.$CurrentSection.$key = $value
            }
        }
        $IniHash
    }
}


<#
.SYNOPSIS
Convert dictionary to ini expression string

.PARAMETER InputObject
[System.Collections.Specialized.OrderedDictionary]
The Ordered Dictionary you wish to convert to a string.

.OUTPUTS
[string[]]

.EXAMPLE
PS> $Dictionary = [ordered]@{ Section1 = @{ Key1 = 'Value1'; Key2 = 'Value2' } }
PS> ConvertTo-IniString -InputObject $Dictionary
[Section1]
Key1=Value1
Key2=Value2
#>
function ConvertTo-IniString {
    [CmdletBinding()]
    [OutputType([string[]])]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline)]
        [ValidateScript( {
                if (($_ -as [System.Collections.Specialized.OrderedDictionary]) -or ($_ -as [hashtable])) {
                    $true
                }
                else {
                    throw 'The value type of InputObject should be "System.Collections.Specialized.OrderedDictionary" or "System.Collections.Hashtable"'
                }
            })]
        $InputObject
    )

    Process {
        $IniString = New-Object 'System.Collections.Generic.List[System.String]'

        $HasRootSection = if ($InputObject -as [System.Collections.Specialized.OrderedDictionary]) {
            $InputObject.Contains('_ROOT_')
        }
        else {
            $InputObject.ContainsKey('_ROOT_')
        }
        if ($HasRootSection) {
            if ($InputObject.'_ROOT_' -as [hashtable]) {
                $private:Keys = $InputObject.'_ROOT_'
                $Keys.Keys.ForEach( {
                        $IniString.Add(('{0}={1}' -f $_, $Keys.$_))
                    })
                $IniString.Add([string]::Empty)
            }
        }

        foreach ($Section in $InputObject.keys) {
            if (-not ($Section -eq '_ROOT_')) {
                if ($InputObject.$Section -as [hashtable]) {
                    $IniString.Add(('[{0}]' -f $Section))
                    $private:Keys = $InputObject.$Section
                    $Keys.Keys.ForEach( {
                            $IniString.Add(('{0}={1}' -f $_, $Keys.$_))
                        })
                    $IniString.Add([string]::Empty)
                }
            }
        }
        $IniString.ToArray()
    }
}


<#
.SYNOPSIS
Set a key value pair to the dictionary.

.PARAMETER InputObject
[System.Collections.Specialized.OrderedDictionary]

.PARAMETER Key
[string]
The key name

.PARAMETER Value
[string]
The value of the key

.PARAMETER Section
[string]
The name of the section to which the key belongs.
If the key doesn't need to belong section, you don't need specify this parameter.

.PARAMETER PassThru
[switch]
If specified, This function will output modified dictionary.

.OUTPUTS
[System.Collections.Specialized.OrderedDictionary]

.EXAMPLE
PS> $Dictionary = [ordered]@{ Section1 = @{ Key1 = 'Value1'; Key2 = 'Value2' } }
PS> $Dictionary | Set-IniKey -Key 'Key2' -Value 'ModValue2' -Section 'Section1' -PassThru | ConvertTo-IniString
[Section1]
Key1=Value1
Key2=ModValue2
#>
function Set-IniKey {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline)]
        [System.Collections.Specialized.OrderedDictionary]
        $InputObject,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Key,

        [Parameter()]
        [AllowEmptyString()]
        [string]$Value = '',

        [Parameter()]
        [string]$Section = '_ROOT_',

        [Parameter()]
        [switch]$PassThru
    )

    Process {
        if ($InputObject.Contains($Section)) {
            if ($Key) {
                if ($InputObject.$Section.Contains($Key)) {
                    Write-Verbose ("Update value. Key:'{0}'; Value:'{1}'; Section:'{2}'" -f $key, $Value, $Section)
                    $InputObject.$Section.$Key = $Value
                }
                else {
                    Write-Verbose ("Set value. Key:'{0}'; Value:'{1}'; Section:'{2}'" -f $key, $Value, $Section)
                    $InputObject.$Section.Add($Key, $Value)
                }
            }
        }
        else {
            $InputObject.Add($Section, [System.Collections.Specialized.OrderedDictionary]@{ })
            if ($Key) {
                Write-Verbose ("Set value. Key:'{0}'; Value:'{1}'; Section:'{2}'" -f $key, $Value, $Section)
                $InputObject.$Section.Add($Key, $Value)
            }
        }

        if ($PassThru) {
            $InputObject
        }
    }
}


<#
.SYNOPSIS
Remove a key value pair from dictionary.

.PARAMETER InputObject
[System.Collections.Specialized.OrderedDictionary]

.PARAMETER Key
[string]
The key name

.PARAMETER Section
[string]
The name of the section to which the key belongs.
If the key doesn't need to belong section, you don't need specify this parameter.

.PARAMETER PassThru
[switch]
If specified, This function will output modified dictionary.

.OUTPUTS
[System.Collections.Specialized.OrderedDictionary]

.EXAMPLE
PS> $Dictionary = [ordered]@{ Section1 = @{ Key1 = 'Value1'; Key2 = 'Value2' } }
PS> $Dictionary | Remove-IniKey -Key 'Key2' -Section 'Section1' -PassThru | ConvertTo-IniString
[Section1]
Key1=Value1
#>
function Remove-IniKey {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param
    (
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline)]
        [System.Collections.Specialized.OrderedDictionary]
        $InputObject,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Key,

        [Parameter()]
        [string]$Section = '_ROOT_',

        [Parameter()]
        [switch]$PassThru
    )

    Process {
        if ($InputObject.Contains($Section)) {
            if ($Key) {
                if ($InputObject.$Section.Contains($Key)) {
                    $InputObject.$Section.Remove($key)

                    # when all key is removed, also remove section
                    if ($InputObject.$Section.Count -le 0) {
                        $InputObject.Remove($Section)
                    }
                }
            }

            # if key is empty, remove section and all of child keys
            else {
                $InputObject.Remove($Section)
            }
        }

        if ($PassThru) {
            $InputObject
        }
    }
}


Export-ModuleMember -Function @(
    'Get-TargetResource',
    'Set-TargetResource',
    'Test-TargetResource',
    'Get-IniFile',
    'ConvertTo-IniString',
    'Set-IniKey',
    'Remove-IniKey'
)
