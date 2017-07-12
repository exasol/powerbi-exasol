// Use this file to write queries to test your data connector
let
    Server = "10.60.120.16..19:8563",
    Source = Exasol.Database(Server),
    sys_Schema =  Source{[Name = "TB",Kind="Schema"]}[Data]
in
    sys_Schema