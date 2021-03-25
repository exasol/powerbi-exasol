
        let
    Server = "{server}",
    //args = "LOGMODE=""COMMDEBUG"",EXALOGFILE=""C:\tmp\odbclogfilepowerbi.txt""",
    args = "LOGMODE=COMMDEBUG,EXALOGFILE=C:\tmp\odbclogfilepowerbi.txt",
    optionsRecord = [
    extraOdbcArgs = args
    ],

    Source = Exasol.Database(Server, "Yes", "select * from [ADVENTUREWORKSDW2014].[DimProduct] LIMIT 5 ;", optionsRecord)//,
            //Source = Exasol.Database(Server,"Yes",null,null)//,
            //myDb = Source,
            //mySchema =  Source{[Name = "ADVENTUREWORKSDW2014",Kind="Schema"]}[Data]
        in
            Source