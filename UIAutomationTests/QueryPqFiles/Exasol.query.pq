//local exasol VM TEST SCHEMA
let
    Server = "192.168.56.101:8563",
    Source = Exasol.Database(Server,"Yes"),
    myDb = Source,
    mySchema =  Source{[Name = "TEST",Kind="Schema"]}[Data]
in
    mySchema
