@{

    RootModule           = 'DSCR_FileContent.psm1'

    # Version number of this module.
    ModuleVersion        = '2.4.2'

    # ID used to uniquely identify this module
    GUID                 = '8e9d0992-d96a-4489-8077-a04b1a560c4c'

    # Author of this module
    Author               = 'mkht'

    # Company or vendor of this module
    CompanyName          = ''

    # Description of the functionality provided by this module
    Copyright            = '(c) 2021 mkht. All rights reserved.'

    # Copyright statement for this module
    Description          = 'PowerShell DSC Resource to create TXT / INI / JSON file.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '5.0'

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Functions to export from this module
    FunctionsToExport    = @(
        'Get-IniFile',
        'ConvertTo-IniString',
        'Set-IniKey',
        'Remove-IniKey',
        'Convert-NewLine',
        'Set-NewContent'
    )

    # Cmdlets to export from this module
    CmdletsToExport      = @()

    # Aliases to export from this module
    AliasesToExport      = @()

    # DSC resources to export from this module
    DscResourcesToExport = @(
        'IniFile',
        'JsonFile',
        'TextFile'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags       = ('DesiredStateConfiguration', 'DSC', 'DSCResource', 'INI', 'TXT', 'JSON')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/mkht/DSCR_FileContent/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/mkht/DSCR_FileContent'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''
        } # End of PSData hashtable

    } # End of PrivateData hashtable
}

