(parameter) =>
let
    Sorted = Table.Sort(parameter[zone_table], {{"LOCATIONID", Order.Ascending}}),
    Grouped = Table.Group(Sorted, {"SERVICE_ZONE"}, {{"Any", each List.First([LOCATIONID]), type number}}),
    SortedGrouped = Table.Sort(Grouped, {{"SERVICE_ZONE", Order.Ascending}}),
    FirstN = Table.FirstN(SortedGrouped, 5),
    SelectColumns = Table.SelectColumns(FirstN, {"SERVICE_ZONE"})
in
    SelectColumns
