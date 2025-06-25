(parameter) => 
let
	SelectColumns = Table.Group(parameter[taxi_table], {}, {{"Count", each List.Count([TRIP_DISTANCE]), type number}}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN