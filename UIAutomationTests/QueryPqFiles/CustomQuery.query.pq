let
    Server = "192.168.56.101:8563",
    queryResult = Exasol.Database(Server,"Yes", "select * from [ADVENTUREWORKSDW2014].[DimProduct] LIMIT 5 ;")//,

in
    queryResult
