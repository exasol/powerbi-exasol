(parameter) => 
let
    T2 = Table.AddColumn(parameter[taxi_table], "minute", each Time.Minute([LPEP_PICKUP_DATETIME])),
    T_Sorted = Table.Sort(T2, "RECORDID") 
in
    T_Sorted