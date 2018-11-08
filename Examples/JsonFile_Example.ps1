$output = 'C:\DSCMOF'

Configuration JsonExample
{
    Import-DscResource -ModuleName DSCR_FileContent
    Node localhost
    {
        JsonFile Array {
            Ensure = 'Present'
            Path   = 'C:\JsonTest.json'
            Key    = 'ArrayKey'
            Value  = '[true, 123, "Hello"]'  # JSON formatted string
        }

        JsonFile Bool {
            Ensure = 'Present'
            Path   = 'C:\JsonTest.json'
            Key    = 'BoolKey'
            Value  = 'true'
        }

        JsonFile String {
            Ensure = 'Present'
            Path   = 'C:\JsonTest.json'
            Key    = 'StringKey'
            Value  = 'Hello PowerShell!'
        }

        JsonFile Hash {
            Ensure = 'Present'
            Path   = 'C:\JsonTest.json'
            Key    = 'HashKey'
            Value  = '{"key1": true, "key2": 123}'
        }

        JsonFile Null {
            Ensure = 'Present'
            Path   = 'C:\JsonTest.json'
            Key    = 'NullKey'
            Value  = 'null'
        }
    }
}

JsonExample -OutputPath $output
Start-DscConfiguration -Path  $output -Verbose -wait
Remove-DscConfigurationDocument -Stage Current, Previous, Pending -Force

# Expect Output
<#
{
  "ArrayKey": [
    true,
    123,
    "Hello"
  ],
  "BoolKey": true,
  "StringKey": "Hello PowerShell!",
  "HashKey": {
    "key1": true,
    "key2": 123
  },
  "NullKey": null
}
#>
