(parameter) => 
let
        Grouped = Table.Group(Sorted, {"SERVICE_ZONE"}, {}),
        Sorted = Table.Sort(parameter[zone_table], {{(t) => t[SERVICE_ZONE], Order.Ascending}}),
        FirstN = Table.FirstN(Sorted,3),
        SelectColumns = Table.SelectColumns(FirstN, "SERVICE_ZONE")
    in
        SelectColumns
