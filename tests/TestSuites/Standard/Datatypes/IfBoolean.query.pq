(parameter) =>
let
    AddColumns = Table.AddColumn(parameter[taxi_table], "Column", each if [STORE_AND_FWD_FLAG] = true then true else false),
    SelectColumns = Table.SelectColumns(AddColumns, { "Column" }),
    SelectRows = Table.SelectRows(SelectColumns, each [Column] = false),
    Sort = Table.Sort(SelectRows, each [Column]),
    FirstN = Table.FirstN(Sort, 1){0}
in
    FirstN