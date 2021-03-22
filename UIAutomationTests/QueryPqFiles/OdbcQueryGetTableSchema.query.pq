
let
    Server = "{server}",
    Source = Exasol.Database(Server, "Yes", "SELECT * FROM [{schemaname}].[{tablename}]"),
    tableSchemaviaTS = Table.Schema(Source)
in
//ts
   tableSchemaviaTS

