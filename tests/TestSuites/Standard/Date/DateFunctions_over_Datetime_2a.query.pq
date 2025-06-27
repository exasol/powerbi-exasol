(parameter) =>
let    
    T2 = Table.SelectColumns(parameter[taxi_table], {"RECORDID","LPEP_DROPOFF_DATETIME"}),
    T3 = Table.Sort(T2, {"RECORDID"}),
    T4 = Table.AddColumn(T3, "SOY", each Date.StartOfYear([LPEP_DROPOFF_DATETIME])),
    T5 = Table.AddColumn(T4, "SOQ", each Date.StartOfQuarter([LPEP_DROPOFF_DATETIME])),
    T6 = Table.AddColumn(T5, "SOM", each Date.StartOfMonth([LPEP_DROPOFF_DATETIME])),
    T7 = Table.AddColumn(T6, "SOD", each Date.StartOfDay([LPEP_DROPOFF_DATETIME])),
    T8 = Table.FirstN(T7, 4)
in
    T8