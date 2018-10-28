$output = 'C:\DSCMOF'

Configuration TextTest
{
    Import-DscResource -ModuleName DSCR_FileContent
    Node localhost
    {
        TextFile TextTest {
            Ensure   = 'Present'
            Path     = "C:\sample.txt"
            Contents = 'sample text'
            Encoding = 'utf8NoBOM'   #utf8 without bom
            NewLine  = 'CRLF'
        }
    }
}

TextTest -OutputPath $output
Start-DscConfiguration -Path  $output -Verbose -wait
Remove-DscConfigurationDocument -Stage Current, Previous, Pending -Force
