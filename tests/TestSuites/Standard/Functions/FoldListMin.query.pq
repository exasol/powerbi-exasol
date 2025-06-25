(parameter) => 
let
	SelectColumns = Table.Group(parameter[taxi_table], {}, {{"Minimum", each List.Min([TRIP_DISTANCE]), type number}}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN