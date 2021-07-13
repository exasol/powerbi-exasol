let
     Source = Exasol.Database("DSN={DSN}", "Yes"),

    MT = Source{[Name="MORETESTS",Kind="Schema"]}[Data]

in
    MT

