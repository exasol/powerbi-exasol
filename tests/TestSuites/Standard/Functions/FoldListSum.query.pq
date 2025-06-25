(parameter) => 
let
	SelectColumns = Table.Group(parameter[taxi_table], {}, {{"Sum", each Number.Round(List.Sum([TRIP_DISTANCE]), 8), type number}}),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN