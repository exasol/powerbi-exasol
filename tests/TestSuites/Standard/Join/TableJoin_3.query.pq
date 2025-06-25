(parameter) => let
    taxi_table = parameter[taxi_table],
    zone_table = parameter[zone_table],
    t1070 = Table.RenameColumns(taxi_table, {{"VENDORID", "t1.VENDORID"}, {"TRIP_DISTANCE", "t1.TRIP_DISTANCE"}, {"FARE_AMOUNT", "t1.FARE_AMOUNT"}, {"PULOCATIONID", "t1.PULOCATIONID"}, {"PAYMENT_TYPE", "t1.PAYMENT_TYPE"}}),
    t1071 = Table.RenameColumns(zone_table, {{"LOCATIONID", "t0.LOCATIONID"}, {"BOROUGH", "t0.BOROUGH"}, {"TAXIZONE", "t0.TAXIZONE"}}),
    t1379 = Table.Join(t1070, {"t1.PULOCATIONID"}, t1071, {"t0.LOCATIONID"}, JoinKind.LeftOuter, null),
    t1136 = Table.SelectRows(t1379, (t1135) => (List.Contains({"Bronx"}, t1135[t0.BOROUGH]) or t1135[t0.BOROUGH] = null) and (List.Contains({1}, Int64.From(t1135[t1.VENDORID])) or t1135[t1.VENDORID] = null)),
    t1142 = Table.Group(t1136, {"t1.TRIP_DISTANCE", "t1.FARE_AMOUNT", "t1.PAYMENT_TYPE"}, {}),
    t1146 = Table.Sort(t1142, {{(t1143) => t1143[t1.TRIP_DISTANCE], Order.Ascending}, {(t1144) => t1144[t1.PAYMENT_TYPE], Order.Ascending}, {(t1145) => t1145[t1.FARE_AMOUNT], Order.Ascending}}),
    t1147 = Table.SelectColumns(t1146, {"t1.TRIP_DISTANCE", "t1.FARE_AMOUNT", "t1.PAYMENT_TYPE"}),
    FirstN = Table.FirstN(t1147, 5)
in
    FirstN
