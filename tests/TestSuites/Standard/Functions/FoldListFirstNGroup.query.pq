(parameter) => 
let
    Sorted = Table.Sort(parameter[taxi_table], {"LPEP_PICKUP_DATETIME", Order.Ascending}),
    FirstNRecords = Table.FirstN(Sorted, 10),
    Grouped = Table.Group(FirstNRecords, {"PULOCATIONID"},  {"total_TRIP_DISTANCE", each List.Sum([TRIP_DISTANCE])})
in
    Grouped
