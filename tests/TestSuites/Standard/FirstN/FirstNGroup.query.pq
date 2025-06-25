(parameter) => 
let
    Sorted = Table.Sort(parameter[zone_table], {"LOCATIONID"}),
    Grouped = Table.Group(Sorted, {"SERVICE_ZONE"}, {}),
    FirstN = Table.FirstN(Grouped,3),
    SelectColumns = Table.SelectColumns(Grouped, "SERVICE_ZONE")
in
    SelectColumns