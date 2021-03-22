let
    Source = Exasol.Database("{server}", "Yes", null),
    ADVENTUREWORKSDW2014_Schema = Source{[Name="ADVENTUREWORKSDW2014",Kind="Schema"]}[Data],
    vDMPrep_View = ADVENTUREWORKSDW2014_Schema{[Name="vDMPrep",Kind="View"]}//[Data]
in
    vDMPrep_View