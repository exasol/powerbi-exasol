(parameter) =>
let
    Sorted = Table.Sort(parameter[taxi_table], {"RECORDID"}),
    T2 = Table.SelectColumns(Sorted, {"PULOCATIONID","LPEP_PICKUP_DATETIME"}),
    T3 = Table.Sort(T2, {"PULOCATIONID"}),
    T4 = Table.AddColumn(T3, "Diff1", each [LPEP_PICKUP_DATETIME] - #datetime(1999,1,5,0,0,0)),
    T5 = Table.AddColumn(T4, "Diff2", each [LPEP_PICKUP_DATETIME] - #datetime(2007,2,6,0,0,0)),
    T6 = Table.AddColumn(T5, "Diff3", each [LPEP_PICKUP_DATETIME] - #datetime(2007,9,5,0,0,0)),
    TA = Table.FirstN(T6, 4)
in
    TA