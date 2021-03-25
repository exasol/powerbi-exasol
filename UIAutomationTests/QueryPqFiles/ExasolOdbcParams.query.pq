
        let
    //write a test for both args records
    //also a test for an empty options record
    //and a test for a null record
    Server = "{server}",
    //args = "LOGMODE=""COMMDEBUG"",EXALOGFILE=""C:\tmp\odbclogfilepowerbi.txt""",
    args = "LOGMODE=COMMDEBUG,EXALOGFILE=C:\tmp\odbclogfilepowerbi.txt",
    optionsRecord = [
    extraOdbcArgs = args
    ],

    Source = Exasol.Database(Server, "Yes", null, optionsRecord)//,
            //Source = Exasol.Database(Server,"Yes",null,null)//,
            //myDb = Source,
            //mySchema =  Source{[Name = "ADVENTUREWORKSDW2014",Kind="Schema"]}[Data]
        in
            Source