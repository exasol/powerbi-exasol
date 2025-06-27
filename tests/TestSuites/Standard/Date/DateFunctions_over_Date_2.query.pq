(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RECORDID","LPEP_PICKUP_DATETIME"}),
    T3 = Table.Sort(T2, {"RECORDID"}),
    T4 = Table.AddColumn(T3, "SOY", each DateTime.ToText(Date.StartOfYear([LPEP_PICKUP_DATETIME]))),
    T5 = Table.AddColumn(T4, "SOQ", each DateTime.ToText(Date.StartOfQuarter([LPEP_PICKUP_DATETIME]))),
    T6 = Table.AddColumn(T5, "SOM", each DateTime.ToText(Date.StartOfMonth([LPEP_PICKUP_DATETIME]))),
    T7 = Table.AddColumn(T6, "SOW", each DateTime.ToText(Date.StartOfWeek([LPEP_PICKUP_DATETIME]))),
    T8 = Table.AddColumn(T7, "SOD", each DateTime.ToText(Date.StartOfDay([LPEP_PICKUP_DATETIME]))),
    T9 = Table.AddColumn(T8, "EOY", each DateTime.ToText(Date.EndOfYear([LPEP_PICKUP_DATETIME]))),
    TA = Table.AddColumn(T9, "EOQ", each DateTime.ToText(Date.EndOfQuarter([LPEP_PICKUP_DATETIME]))),
    TB = Table.AddColumn(TA, "EOM", each DateTime.ToText(DateTime.From(Date.EndOfMonth([LPEP_PICKUP_DATETIME])))),
    TC = Table.AddColumn(TB, "EOW", each DateTime.ToText(Date.EndOfWeek([LPEP_PICKUP_DATETIME]))),
    TD = Table.AddColumn(TC, "EOD", each DateTime.ToText(Date.EndOfDay([LPEP_PICKUP_DATETIME]))),
    TE = Table.FirstN(TD, 4)
in
    TE