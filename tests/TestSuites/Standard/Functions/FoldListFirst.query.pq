(parameter) =>
let
    Sorted = Table.Sort(
        parameter[taxi_table],
        {{"PULOCATIONID", Order.Descending}, {"TRIP_DISTANCE", Order.Ascending}}
    ),
    SelectColumns = Table.Group(Sorted, {"PULOCATIONID"}, {
        {"First", each List.First([TRIP_DISTANCE]), type number}
    }),
    FinalSort = Table.Sort(SelectColumns, {"PULOCATIONID", Order.Descending}),
    FirstN = Table.FirstN(FinalSort, 1)
in
    FirstN