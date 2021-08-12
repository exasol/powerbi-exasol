
let
    Server = "192.168.1.47:8563",
    SchemaName ="MORETESTS",
    TableName = "TEXTCONVERSION",
    Source = Exasol.Database(Server, "Yes"),
    SelectedSchema = Source{[Name=SchemaName,Kind="Schema"]}[Data],
    SelectedTable = SelectedSchema{[Name=TableName,Kind="Table"]}[Data]//,

//tableSchemaviaTS = Table.Schema(SelectedTable)
in
//ts
   SelectedTable