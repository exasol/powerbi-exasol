(parameter) => let
    taxi_table = parameter[taxi_table],
    zone_table = parameter[zone_table],
    t1070 = Table.RenameColumns(taxi_table, {{"VENDORID", "t1.VENDORID"}, {"TRIP_DISTANCE", "t1.TRIP_DISTANCE"}, {"FARE_AMOUNT", "t1.FARE_AMOUNT"}, {"PULOCATIONID", "t1.PULOCATIONID"}, {"PAYMENT_TYPE", "t1.PAYMENT_TYPE"}}),
    t1071 = Table.RenameColumns(zone_table, {{"LOCATIONID", "t0.LOCATIONID"}, {"BOROUGH", "t0.BOROUGH"}, {"TAXIZONE", "t0.TAXIZONE"}}),
    t1072 = Table.Join(t1070, {"t1.PULOCATIONID"}, t1071, {"t0.LOCATIONID"}, JoinKind.LeftOuter, null),
    t1075 = Table.SelectRows(t1072, (t1074) => Value.Equals(t1074[t0.BOROUGH], "Bronx") and Value.NullableEquals(Int64.From(t1074[t1.VENDORID]), 1)),
    t1081 = Table.Group(t1075, {"t1.TRIP_DISTANCE", "t1.FARE_AMOUNT", "t1.PAYMENT_TYPE"}, {}),
    t1085 = Table.Sort(t1081, {{(t1082) => t1082[t1.TRIP_DISTANCE], Order.Ascending}, {(t1083) => t1083[t1.PAYMENT_TYPE], Order.Ascending}, {(t1084) => t1084[t1.FARE_AMOUNT], Order.Ascending}}),
    t1086 = Table.SelectColumns(t1085, {"t1.TRIP_DISTANCE", "t1.FARE_AMOUNT", "t1.PAYMENT_TYPE"}),
    FirstN = Table.FirstN(t1086, 5)
in
    FirstN