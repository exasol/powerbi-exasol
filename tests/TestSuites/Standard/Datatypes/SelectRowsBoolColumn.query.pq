(parameter) =>
let
    SelectRows = Table.SelectRows(parameter[taxi_table], each [STORE_AND_FWD_FLAG] = true),
    SelectColumns = Table.SelectColumns(SelectRows, { "LPEP_DROPOFF_DATETIME", "DOLOCATIONID" }),
    Sort = Table.Sort(SelectColumns, {"DOLOCATIONID"}),
    FirstN = Table.FirstN(Sort, 2)
in
    FirstN