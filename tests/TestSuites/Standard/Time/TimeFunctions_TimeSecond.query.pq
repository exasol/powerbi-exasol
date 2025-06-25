(parameter) => 
let
    T_Sorted = Table.Sort(parameter[taxi_table], "RECORDID") ,
    T2 = Table.AddColumn(T_Sorted, "second", each Time.Second([LPEP_PICKUP_DATETIME])),
    T3 = Table.SelectColumns(T2, {"LPEP_PICKUP_DATETIME", "second"})
in
    T3
