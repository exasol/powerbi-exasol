let
    Server = "{server}",
    SchemaName ="{schemaname}",
    TableName = "{tablename}",
    ColumnName = "{columnname}",
    Source = Exasol.Database(Server, "Yes", null),
    SelectedSchema = Source{[Name=SchemaName,Kind="Schema"]}[Data],
    SelectedTable = SelectedSchema{[Name=TableName,Kind="Table"]}[Data],
    SelectedColumn = Table.Column(SelectedTable,ColumnName),
    FirstValue = SelectedColumn{{row}}, //0-based
    TypeOfValue = Value.Type(FirstValue),
    TypeNN = Type.NonNullable(TypeOfValue),
    //this is enough in powerbi itself and neatly displays the number in this case, but only if it's a single value! not in a table.
    //but in the sdk we got to provide type -> text ourselves, you can find this code in the diagnostics.pqm file so rest assured it's water tight (used by the power bi devs themselves)
    base = TypeOfValue,
    //this comes out of the official trace code (Diagnostics.pqm)
    TypeText =                      
                                    if base = type anynonnull then
                                        "anynonnull"
                                    else if base = type binary then
                                        "binary"
                                    else if base = type date then
                                        "date"
                                    else if base = type datetime then
                                        "datetime"
                                    else if base = type datetimezone then
                                        "datetimezone"
                                    else if base = type duration then
                                        "duration"
                                    else if base = type logical then
                                        "logical"
                                    else if base = type none then
                                        "none"
                                    else if base = type null then
                                        "null"
                                    else if base = type number then
                                        "number"
                                    else if base = type text then
                                        "text"
                                    else if base = type time then
                                        "time"
                                    else if base = type type then
                                        "type"
                                    else /* Abstract types: */ if base = type function then
                                        "function"
                                    else if base = type table then
                                        "table"
                                    else if base = type record then
                                        "record"
                                    else if base = type list then
                                        "list"
                                    else
                                        "any /*Actually unknown type*/"

in
    TypeText
    //TypeOfValue