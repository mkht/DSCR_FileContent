DSCR_FileContent
====
[![Build status](https://ci.appveyor.com/api/projects/status/gymscf13kodpy4v9/branch/master?svg=true)](https://ci.appveyor.com/project/mkht/dscr-filecontent/branch/master) [![codecov](https://codecov.io/gh/mkht/DSCR_FileContent/branch/master/graph/badge.svg)](https://codecov.io/gh/mkht/DSCR_FileContent)

PowerShell DSC Resource to create TEXT / INI / JSON files.

## Install
You can install resource from [PowerShell Gallery](https://www.powershellgallery.com/packages/DSCR_FileContent/).
```Powershell
Install-Module -Name DSCR_FileContent
```

----
## DSC Resources

### TextFile
PowerShell DSC Resource to create text file.

#### Properties
+ [string] **Ensure** (Write):
    + Specify the key exists or not.
    + The default value is `Present`. (`Present` | `Absent`)

+ [string] **Path** (Key):
    + The path of the file.

+ [string] **Contents** (Write):
    + The contents of file.

+ [string] **Encoding** (Write):
    + You can choose text encoding for the file.
    + `UTF8NoBOM` (default) / `UTF8BOM` / `utf32` / `unicode` / `bigendianunicode` / `ascii`

+ [string] **NewLine** (Write):
    + You can choose new line code for the file.
    + `CRLF` (default) / `LF`


### Examples
+ **Example 1**
```Powershell
Configuration Example1 {
    Import-DscResource -ModuleName DSCR_FileContent
    TextFile SampleTxt {
        Path = "C:\TestTxt.txt"
        Contents = "This is sample txt"
        Encoding = 'utf8NoBOM'
        NewLine = 'LF'
    }
}
```

### IniFile
PowerShell DSC Resource to create ini file.

#### Properties
+ [string] **Ensure** (Write):
    + Specify the key exists or not.
    + The default value is `Present`. (`Present` | `Absent`)

+ [string] **Path** (Key):
    + The path of the INI file.

+ [string] **Key** (Key):
    + Key element.
    + If you specified key as empty string, IniFile only check the section.

+ [string] **Value** (Write):
    + The value corresponding to the key.
    + If this param not specified, will set empty string.

+ [string] **Section** (Key):
    + The section to which the key belongs.
    + **If the key doesn't need to belong section, you should set the value for an empty string.**

+ [string] **Encoding** (Write):
    + You can choose text encoding for the INI file.
    + `UTF8NoBOM` (default) / `UTF8BOM` / `utf32` / `unicode` / `bigendianunicode` / `ascii`

+ [string] **NewLine** (Write):
    + You can choose new line code for the INI file.
    + `CRLF` (default) / `LF`


### Examples
+ **Example 1**
```Powershell
Configuration Example1 {
    Import-DscResource -ModuleName DSCR_FileContent
    IniFile Apple {
        Path = "C:\Test.ini"
        Section = ""
        Key = "Fruit_A"
        Value = "Apple"
    }
    IniFile Banana {
        Path = "C:\Test.ini"
        Section = ""
        Key = "Fruit_B"
        Value = "Banana"
    }
    IniFile Ant {
        Path = "C:\Test.ini"
        Section = "Animals"
        Key = "Animal_A"
        Value = "Ant"
    }
}
```

The result of executing the above configuration, the following ini file will output to `C:\Test.ini`
```
Fruit_A=Apple
Fruit_B=Banana
[Animals]
Animal_A=Ant
```


### JsonFile
PowerShell DSC Resource to create JSON file.

### Properties
+ [string] **Ensure** (Write):
    + Specify the key exists or not.
    + The default value is `Present`. (`Present` | `Absent`)

+ [string] **Path** (Key):
    + The path of the JSON file.

+ [string] **Key** (Key):
    + Key element.

+ [string] **Value** (Key):
    + The value corresponding to the key.
    + The value of this parameter must be a JSON formatted string.

+ [string] **Encoding** (Write):
    + You can choose text encoding for the JSON file.
    + utf8NoBOM (default) / utf8BOM / utf32 / unicode / bigendianunicode / ascii

+ [string] **NewLine** (Write):
    + You can choose new line code for the JSON file.
    + CRLF (default) / LF

### Examples
+ **Example 1**
```Powershell
Configuration Example1 {
    Import-DscResource -ModuleName DSCR_FileContent
    JsonFile String {
        Path = 'C:\Test.json'
        Key = 'StringValue'
        Value = '"Apple"'
    }
    JsonFile Bool {
        Path = 'C:\Test.json'
        Key = 'BoolValue'
        Value = 'true'
    }
    JsonFile Array {
        Path = 'C:\Test.json'
        Key = "ArrayValue"
        Value = '[true, 123, "banana"]'
    }
}
```

The result of executing the above configuration, the following JSON file will output to `C:\Test.json`
```json
{
  "BoolValue": true,
  "StringValue": "Apple",
  "ArrayValue": [
    true,
    123,
    "banana"
  ]
}
```

----
## Functions

### Get-IniFile
Load ini file and convert to the dictionary object

+ **Syntax**
```PowerShell
Get-IniFile [-Path] <string> [-Encoding { <utf8> | <utf8BOM> | <utf32> | <unicode> | <bigendianunicode> | <ascii> | <Default> }]
```


### ConvertTo-IniString
Convert dictionary object to ini expression string

+ **Syntax**
```PowerShell
ConvertTo-IniString [-InputObject] <System.Collections.Specialized.OrderedDictionary>
```

+ **Example**
```PowerShell
PS> $Dictionary = [ordered]@{ Section1 = @{ Key1 = 'Value1'; Key2 = 'Value2' } }
PS> ConvertTo-IniString -InputObject $Dictionary
[Section1]
Key1=Value1
Key2=Value2
```


### Set-IniKey
Set a key value pair to the dictionary

+ **Syntax**
```PowerShell
Set-IniKey [-InputObject] <System.Collections.Specialized.OrderedDictionary> -Key <string> [-Value <string>] [-Section <string>] [-PassThru]
```

+ **Example**
```PowerShell
PS> $Dictionary = [ordered]@{ Section1 = @{ Key1 = 'Value1'; Key2 = 'Value2' } }
PS> $Dictionary | Set-IniKey -Key 'Key2' -Value 'ModValue2' -Section 'Section1' -PassThru | ConvertTo-IniString
[Section1]
Key1=Value1
Key2=ModValue2
```


### Remove-IniKey
Remove a key value pair from dictionary

+ **Syntax**
```PowerShell
Remove-IniKey [-InputObject] <System.Collections.Specialized.OrderedDictionary> -Key <string> [-Section <string>] [-PassThru]
```

+ **Example**
```PowerShell
PS> $Dictionary = [ordered]@{ Section1 = @{ Key1 = 'Value1'; Key2 = 'Value2' } }
PS> $Dictionary | Remove-IniKey -Key 'Key2' -Section 'Section1' -PassThru | ConvertTo-IniString
[Section1]
Key1=Value1
```

----
## ChangeLog
### 1.0.0
 + Add `TextFile` resource.
 + DSCR_FileContent is integrated module of [DSCR_IniFile](https://github.com/mkht/DSCR_IniFile) and [DSCR_JsonFile](https://github.com/mkht/DSCR_JsonFile).
