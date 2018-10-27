$output = 'C:\IniTest\MOF'

Configuration IniTest
{
    Import-DscResource -ModuleName DSCR_IniFile
    Node localhost
    {
        cIniFile IniTest
        {
            Ensure = "Present"  #create key
            Path = "C:\IniTest.ini"
            Key = 'TestKey'
            Value = 'TestValue'
            Section = ''    #no section
            Encoding = 'UTF8'
        }

        cIniFile IniTest2
        {
            Ensure = "Absent"   #remove key
            Path = "C:\IniTest.ini"
            Key = 'MissingKey'
            Section = 'Section'
            Encoding = 'UTF8'
        }
    }
}

IniTest -OutputPath $output
Start-DscConfiguration -Path  $output -Verbose -wait

