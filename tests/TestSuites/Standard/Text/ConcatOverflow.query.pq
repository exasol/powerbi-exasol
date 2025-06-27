(parameter) => 
let
    Sorted = Table.Sort(parameter[zone_table], {"LOCATIONID"}),
    T1 = Table.AddColumn(Sorted, "CONCAT", each [TAXIZONE] & [SERVICE_ZONE]),
    T2 = Table.SelectColumns(T1, {"CONCAT"})
in
    T2