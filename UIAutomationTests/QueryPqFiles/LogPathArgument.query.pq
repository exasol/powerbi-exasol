let
    Source = Exasol.Database("{server}", "Yes",null,"{absoluteLogPath}"),
    ADVENTUREWORKSDW2014_Schema = Source{[Name="ADVENTUREWORKSDW2014",Kind="Schema"]}[Data]

in
    ADVENTUREWORKSDW2014_Schema