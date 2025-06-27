(parameter) =>
let
    AddColumns = Table.AddColumn(parameter[taxi_table], "Column", each [STORE_AND_FWD_FLAG]),
    //new table, pick just the new column as a new table
    SelectColumns = Table.SelectColumns(AddColumns, { "Column" }),
    //new table, select only the false rows
    SelectRows = Table.SelectRows(SelectColumns, each [Column] = false),
    FirstN = Table.FirstN(SelectRows, 1){0}
in
    FirstN