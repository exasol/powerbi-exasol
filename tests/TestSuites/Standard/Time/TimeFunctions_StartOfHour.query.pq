(parameter) => 
let
    T2 = Table.AddColumn(parameter[taxi_table], "soh", each Time.StartOfHour([LPEP_PICKUP_DATETIME])),
    T_Sorted = Table.Sort(T2, "RECORDID") 
in
    T_Sorted
