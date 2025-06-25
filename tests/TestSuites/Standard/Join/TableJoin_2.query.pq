(parameter) => let
    taxi_table = parameter[taxi_table],
    zone_table = parameter[zone_table],
    t1129 = Table.RenameColumns(taxi_table, {{"VENDORID", "t1.VENDORID"}, {"TRIP_DISTANCE", "t1.TRIP_DISTANCE"}, {"FARE_AMOUNT", "t1.FARE_AMOUNT"}, {"PULOCATIONID", "t1.PULOCATIONID"}, {"PAYMENT_TYPE", "t1.PAYMENT_TYPE"}}),
    t1130 = Table.RenameColumns(zone_table, {{"LOCATIONID", "t0.LOCATIONID"}, {"BOROUGH", "t0.BOROUGH"}, {"TAXIZONE", "t0.TAXIZONE"}}),
    t1131 = Table.Join(t1129, {"t1.PULOCATIONID"}, t1130, {"t0.LOCATIONID"}, JoinKind.LeftOuter, null),
    t1134 = Table.SelectRows(t1131, (t1133) => Value.Equals(t1133[t0.BOROUGH], "Bronx") and Value.NullableEquals(Int64.From(t1133[t1.VENDORID]), 1)),
    t1139 = Table.Group(t1134, {"t1.PAYMENT_TYPE"}, {{"a0", (t1135) => List.Count(List.Select(t1135[t1.VENDORID], each _ <> null))}}),
    t1140 = Table.SelectColumns(t1139, {"t1.PAYMENT_TYPE", "a0"}),
    FirstN = Table.FirstN(t1140, 5)
in
    FirstN