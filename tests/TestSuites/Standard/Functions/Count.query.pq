(parameter) => 
let
    Count = Table.Group(parameter[taxi_table], { "LPEP_PICKUP_DATETIME" }, { { "Count", each List.Count([LPEP_PICKUP_DATETIME]) } }),
    First = Count{0}
in
    First