let
    Source = Exasol.Database("{server}", "Yes", null),
    ADVENTUREWORKSDW2014_Schema = Source{[Name="ADVENTUREWORKSDW2014",Kind="Schema"]}[Data],
    DimAccount_Table = ADVENTUREWORKSDW2014_Schema{[Name="DimAccount",Kind="Table"]}[Data]
in
    DimAccount_Table