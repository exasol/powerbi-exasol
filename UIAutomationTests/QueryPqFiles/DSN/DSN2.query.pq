let
    Source = Exasol.Database("dsn='{DSN}'", "Yes"),

    MT = Source{[Name="MORETESTS",Kind="Schema"]}[Data]

in
    MT
