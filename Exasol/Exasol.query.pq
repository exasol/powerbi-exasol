// Use this file to write queries to test your data connector
let
    Server = "192.168.157.51..57:8563",
    Source = Exasol.Database(Server,"Yes"),
    myDb = Source
     //mySchema =  Source{[Name = "RETAIL",Kind="Schema"]}[Data]
in
    myDb
