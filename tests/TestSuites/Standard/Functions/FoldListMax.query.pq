(parameter) => 
let
	SelectColumns = Table.Group(parameter[taxi_table], {}, {{"Maximum", each List.Max([TRIP_DISTANCE]), type number}}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN