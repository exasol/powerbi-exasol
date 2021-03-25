
        let
    Server = "{server}",
    //args = "LOGMODE=""COMMDEBUG"",EXALOGFILE=""C:\tmp\odbclogfilepowerbi.txt""",
    args = "LOGMODE=COMMDEBUG,EXALOGFILE=C:\tmp\odbclogfilepowerbi.txt",
    optionsRecord = [
    extraOdbcArgs = null
    ],

    Source = Exasol.Database(Server, "Yes", null, optionsRecord)//,
            //Source = Exasol.Database(Server,"Yes",null,null)//,
            //myDb = Source,
            //mySchema =  Source{[Name = "ADVENTUREWORKSDW2014",Kind="Schema"]}[Data]
        in
            Source