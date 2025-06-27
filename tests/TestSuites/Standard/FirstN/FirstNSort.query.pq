(parameter) => 
let
    Sorted = Table.Sort(parameter[zone_table], {{(t) => t[SERVICE_ZONE], Order.Ascending}}),
    FirstN = Table.FirstN(Sorted,5),
    SelectColumns = Table.SelectColumns(FirstN, "SERVICE_ZONE")
in
    SelectColumns
