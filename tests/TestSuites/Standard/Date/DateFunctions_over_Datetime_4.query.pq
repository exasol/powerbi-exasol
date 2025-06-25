(parameter) => 
let
    T2 = Table.SelectColumns(parameter[taxi_table],{"LPEP_PICKUP_DATETIME"}),
    T3 = Table.SelectRows(T2, each [LPEP_PICKUP_DATETIME] = #datetime(2023, 02, 26, 18, 57, 00))
in
    T3