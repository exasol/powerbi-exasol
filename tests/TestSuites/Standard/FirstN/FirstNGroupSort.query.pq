(parameter) => 
let
    Grouped = Table.Group(parameter[zone_table], {"SERVICE_ZONE"}, {}),
    FirstN = Table.FirstN(Grouped,5),
    Sorted = Table.Sort(FirstN, {{(t) => t[SERVICE_ZONE], Order.Ascending}}),
    SelectColumns = Table.SelectColumns(Sorted, "SERVICE_ZONE")
in
    SelectColumns
