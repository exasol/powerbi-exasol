(parameter) =>
let
    t = Table.Group(
        parameter[taxi_table],
        {},
        {{"Standard Deviation", each Number.Round(List.StandardDeviation([FARE_AMOUNT]), 6), type number}}
    )
in
    t