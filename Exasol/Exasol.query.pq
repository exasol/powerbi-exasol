// Use this file to write queries to test your data connector
let
    Server = "192.168.120.11..20:8563",
    Source = Exasol.Database(Server),
    mySchema =  Source{[Name = "TPCH",Kind="Schema"]}[Data]
in
    mySchema
