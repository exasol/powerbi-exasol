(parameter) => 
let
    T2 = Table.AddColumn(parameter[taxi_table], "hour", each Time.Hour([LPEP_PICKUP_DATETIME])),
    T_Sorted = Table.Sort(T2, "RECORDID") 
in
    T_Sorted
