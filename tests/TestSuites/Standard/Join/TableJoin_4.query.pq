(parameter) => let
    taxi_table = parameter[taxi_table],
    zone_table = parameter[zone_table],
	tc = Table.PrefixColumns(taxi_table, "t0"),
    tp = Table.PrefixColumns(zone_table, "t1"),
    joined = Table.Join(tp, {"t1.LOCATIONID"}, tc, {"t0.PULOCATIONID"}, JoinKind.LeftOuter, null),
    added = Table.AddColumn(joined, "t1.LOCATIONID_copy", (temp1) => temp1[t1.LOCATIONID]),
    selected = Table.SelectColumns(added, {"t1.LOCATIONID", "t1.LOCATIONID_copy"}),
    sorted = Table.Sort(selected, {"t1.LOCATIONID"}),
    FirstN = Table.FirstN(sorted, 5)
in
    FirstN