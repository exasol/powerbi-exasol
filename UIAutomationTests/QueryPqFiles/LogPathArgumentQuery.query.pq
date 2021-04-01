let
    Source = Exasol.Database("{server}", "Yes","select * from [ADVENTUREWORKSDW2014].[DimProduct] LIMIT 5 ;","{absoluteLogPath}")

in
    Source