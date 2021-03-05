//local exasol VM AW SCHEMA
let
    Server = "{server}",
    Source = Exasol.Database(Server,"Yes"),
    myDb = Source,
    mySchema =  Source{[Name = "ADVENTUREWORKSDW2014",Kind="Schema"]}[Data]
in
    mySchema
