$output = 'C:\DSCMOF'

Configuration JsonTest
{
    Import-DscResource -ModuleName DSCR_FileContent
    Node localhost
    {
        JsonFile JsonTest {
            Ensure   = "Present"
            Path     = "C:\JsonTest.json"
            Key      = 'TestKey'
            Value    = '[true, 123, "Hello"]'  # JSON formatted string
            Encoding = 'utf8NoBOM'   #utf8 without bom
            NewLine  = 'CRLF'
        }
    }
}

JsonTest -OutputPath $output
Start-DscConfiguration -Path  $output -Verbose -wait
Remove-DscConfigurationDocument -Stage Current, Previous, Pending -Force

# Expect Output
<#
{
  "TestKey": [
    true,
    123,
    "Hello"
  ]
}
#>
