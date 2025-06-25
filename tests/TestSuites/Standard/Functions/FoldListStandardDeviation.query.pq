(parameter) =>
let
	t = Table.Group(parameter[taxi_table], {}, {{"Standard Deviation", each List.StandardDeviation([FARE_AMOUNT]), type number}})
in
	t