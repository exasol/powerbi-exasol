(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RECORDID","LPEP_DROPOFF_DATETIME"}),
    T3 = Table.Sort(T2, {"RECORDID"}),
    T4 = Table.AddColumn(T3, "SOW", each DateTime.ToText(Date.StartOfWeek([LPEP_DROPOFF_DATETIME]))),
    T5 = Table.AddColumn(T4, "EOY", each DateTime.ToText(Date.EndOfYear([LPEP_DROPOFF_DATETIME]))),
    T6 = Table.AddColumn(T5, "EOQ", each DateTime.ToText(Date.EndOfQuarter([LPEP_DROPOFF_DATETIME]))),
    T7 = Table.AddColumn(T6, "EOM", each DateTime.ToText(Date.EndOfMonth([LPEP_DROPOFF_DATETIME]))),
    T8 = Table.AddColumn(T7, "EOW", each DateTime.ToText(Date.EndOfWeek([LPEP_DROPOFF_DATETIME]))),
    T9 = Table.AddColumn(T8, "EOD", each DateTime.ToText(Date.EndOfDay([LPEP_DROPOFF_DATETIME]))),
    TA = Table.FirstN(T9, 4)
in
    TA