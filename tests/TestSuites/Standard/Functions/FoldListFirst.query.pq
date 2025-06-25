(parameter) => 
let
	SelectColumns = Table.Group(parameter[taxi_table], {"PULOCATIONID"}, {{"First", each List.First([TRIP_DISTANCE]), type number}}),
    Sort = Table.Sort(SelectColumns,{"PULOCATIONID", Order.Descending}),
    FirstN = Table.FirstN(Sort, 1)
in
    FirstN