DSCR_FileContent
====

PowerShell DSC Resource to create TEXT / INI / JSON files.

## Install
You can install resource from [PowerShell Gallery](https://www.powershellgallery.com/packages/DSCR_FileContent/).
```Powershell
Install-Module -Name DSCR_FileContent -Scope AllUsers
```

### Dependencies
Also, this module depends with [PSAdvancedJsonCmdlet](https://www.powershellgallery.com/packages/PSAdvancedJsonCmdlet/) module.  
It will be installed through PowerShell Gallery automatically, but you can also install explicitly.
```Powershell
Install-Module -Name PSAdvancedJsonCmdlet -Scope AllUsers
```

----
## DSC Resources

### TextFile
PowerShell DSC Resource to create text file.

#### Properties
+ [string] **Ensure** (Write):
    + Specify the file exists or not.
    + The default value is `Present`. (`Present` | `Absent`)

+ [string] **Path** (Key):
    + The path of the file.

+ [string] **Contents** (Write):
    + The contents of file.

+ [string] **Encoding** (Write):
    + You can choose text encoding for the file.
    + `UTF8NoBOM` (default) / `UTF8BOM` / `utf32` / `unicode` / `bigendianunicode` / `ascii` / `sjis`

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
    + `UTF8NoBOM` (default) / `UTF8BOM` / `utf32` / `unicode` / `bigendianunicode` / `ascii` / `sjis`

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
    + A slash delimiter can be used to specify a dictionary subkey. (See Example2)

+ [string] **Value** (Key):
    + The value corresponding to the key.
    + The value of this parameter must be a JSON formatted string.

+ [string] **Encoding** (Write):
    + You can choose text encoding for the JSON file.
    + `UTF8NoBOM` (default) / `UTF8BOM` / `utf32` / `unicode` / `bigendianunicode` / `ascii` / `sjis`

+ [string] **NewLine** (Write):
    + You can choose new line code for the JSON file.
    + CRLF (default) / LF

+ [bool] **UseLegacy** (Write):
    + From `3.0.0`, This module uses Newtonsoft.Json based JSON serializer provided by [PSAdvancedJsonCmdlet](https://www.powershellgallery.com/packages/PSAdvancedJsonCmdlet) instead of PowerShell built-in cmdlets.
    + If `UseLegacy` specifies as `$true`, It will use built-in cmdlets.
    + Default value is `$false`.

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
  "StringValue": "Apple",
  "BoolValue": true,
  "ArrayValue": [
    true,
    123,
    "banana"
  ]
}
```

+ **Example 2**
```Powershell
Configuration Example2 {
    Import-DscResource -ModuleName DSCR_FileContent
    JsonFile Dictionary {
        Path = 'C:\Test2.json'
        Key = 'KeyA'
        Value = '{"Ame":false,"Gura":true}'
    }
    JsonFile SubDictionary {
        Path = 'C:\Test2.json'
        Key = 'KeyB/SubKeyB'
        Value = 'Ina'
    }
    #If the key name contains a slash, please escape it with a backslash
    JsonFile SubDictionaryWithSlash {
        Path = 'C:\Test2.json'
        Key = 'KeyB/Sub\/\/Key'
        Value = 'Kiara'
    }
}
```

The result of executing the above configuration, the following JSON file will output to `C:\Test2.json`
```json
{
  "KeyA": {
    "Ame": false,
    "Gura": true
  },
  "KeyB": {
    "SubKeyB": {
      "Ina": true,
      "Calli": true
    },
    "Sub//Key": "Kiara"
  }
}
```

----
## Functions

### Get-IniFile
Load ini file and convert to the dictionary object

+ **Syntax**
```PowerShell
Get-IniFile [-Path] <string> [-Encoding { <utf8> | <utf8BOM> | <utf32> | <unicode> | <bigendianunicode> | <ascii> | <sjis> | <Default> }]
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
### 3.0.2
+ [JsonFile] Fixed an issue where JSON containing dictionaries within array elements was not correctly parsed.
+ Revised the structure of the test code
+ Added automated test execution using GitHub Actions Workflow

### 3.0.1
+ [JsonFile] Fixed an issue that the arrays with a single element mistakenly treated as a single value.

### 3.0.0
+ Changed JSON parser from PowerShell built-in cmdlets to [PSAdvancedJsonCmdlet](https://www.powershellgallery.com/packages/PSAdvancedJsonCmdlet) module.  
  This change improves handling for non-compliant JSON format. (e.g., JSON with comments) and consistency of behavior between PS 7 and PS 5.1.
+ The minimum supported version of PowerShell changed from `5.0` to `5.1`.

### 2.4.2
+ Fixed an issue that line feeds may not be added correctly when an array of strings is input to `Set-NewContent` from the pipeline.

### 2.4.1
+ Export new functions `Convert-NewLine` & `Set-NewContent`

### 2.3.0
+ [JsonFile] Subkeys of dictionary can now be specified as keys using slash delimiter.
+ [JsonFile] Fix some security issues.

### 2.2.0
+ Add `sjis` (Japanese Shift_JIS) encoding support.
+ Improve compatibility with PowerShell 7. (Since this version, supports PS7)

### 2.1.1
 + [IniFile] Fixed an issue where extra blank lines might be inserted in the first line of ini file.

### 2.1.0
 + The functions `ConvertTo-IniString`, `Set-IniKey`, `Remove-IniKey` accept not only `[System.Collections.Specialized.OrderedDictionary]` but also `[hashtable]` input types.
 + [IniFile] Add a blank line to the beginning of sections.
 + [IniFile] Improved performance when dealing with large files.
 + Misc fixes.

### 2.0.0
 + [JsonFile] Fixed an issue that Get-TargetResource throws an exception when the array contains NULL. 
 + [JsonFile] Fixed an issue that empty string and NULL could not be set. [#4](https://github.com/mkht/DSCR_FileContent/issues/4)
 + [JsonFile] Improved to preserve key order when modifying JSON file.
 + [JsonFile] Fixed issue that creating a child key may fail when the parent key has value. [#3](https://github.com/mkht/DSCR_FileContent/issues/3) 
 + [JsonFile] (***BREAKING CHANGES***) Changes the behavior when specifying a value that bool or bool parsable to the `Value` parameter. (See [#2](https://github.com/mkht/DSCR_FileContent/issues/2))
 + Add unit tests for helper functions.

### 1.0.3
 + Fixed an issue where character at the end of line may not be output correctly when `CRLF` is specified for NewLine.

### 1.0.1
 + Fixed regression issue.

### 1.0.0
 + Add `TextFile` resource.
 + DSCR_FileContent is integrated module of [DSCR_IniFile](https://github.com/mkht/DSCR_IniFile) and [DSCR_JsonFile](https://github.com/mkht/DSCR_JsonFile).
