let
    Server = "{server}",
    queryResult = Exasol.Database(Server,"Yes", "select * from [ADVENTUREWORKSDW2014].[DimProduct] LIMIT 5 ;")//,

in
    queryResult
