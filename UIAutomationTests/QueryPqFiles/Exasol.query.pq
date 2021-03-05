//local exasol VM TEST SCHEMA
let
    Server = "{server}",
    Source = Exasol.Database(Server,"Yes"),
    myDb = Source,
    mySchema =  Source{[Name = "TEST",Kind="Schema"]}[Data]
in
    mySchema
