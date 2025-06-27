(parameter) => 
let
    Sorted = Table.Sort(parameter[taxi_table], {"RECORDID"}),
    SelectColumns = Table.SelectColumns(Sorted, {"LPEP_PICKUP_DATETIME"}),
    WhereAlwaysTrue = Table.SelectRows(SelectColumns, each [LPEP_PICKUP_DATETIME] <= #datetime(2023, 2, 3, 1, 0, 0.0)),
    FirstN = Table.FirstN(WhereAlwaysTrue, 1)
in
    FirstN