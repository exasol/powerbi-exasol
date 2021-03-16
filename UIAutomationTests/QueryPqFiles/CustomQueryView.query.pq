let
    Server = "{server}",
    queryResult = Exasol.Database(Server,"Yes", "select * from [ADVENTUREWORKSDW2014].[vDMPrep] LIMIT 5 ;")//,

in
    queryResult
