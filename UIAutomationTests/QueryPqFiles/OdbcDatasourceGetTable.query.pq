
let
    Server = "{server}",
    SchemaName ="{schemaname}",
    TableName = "{tablename}",
    Source = Exasol.Database(Server, "Yes"),
    SelectedSchema = Source{[Name=SchemaName,Kind="Schema"]}[Data],
    SelectedTable = SelectedSchema{[Name=TableName,Kind="Table"]}[Data]//,

//tableSchemaviaTS = Table.Schema(SelectedTable)
in
//ts
   SelectedTable