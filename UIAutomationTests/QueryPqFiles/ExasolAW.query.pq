//local exasol VM AW SCHEMA
let
    Server = "192.168.56.101:8563",
    Source = Exasol.Database(Server,"Yes"),
    myDb = Source,
    mySchema =  Source{[Name = "ADVENTUREWORKSDW2014",Kind="Schema"]}[Data]
in
    mySchema
