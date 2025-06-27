(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RECORDID","LPEP_DROPOFF_DATETIME"}),
    T3 = Table.Sort(T2, {"RECORDID"}),
    T4 = Table.AddColumn(T3, "Y+1", each DateTime.ToText(Date.AddYears([LPEP_DROPOFF_DATETIME], 1))),
    T5 = Table.AddColumn(T4, "Q+1", each DateTime.ToText(Date.AddQuarters([LPEP_DROPOFF_DATETIME], 1))),
    T6 = Table.AddColumn(T5, "M+1", each DateTime.ToText(Date.AddMonths([LPEP_DROPOFF_DATETIME], 1))),
    T7 = Table.AddColumn(T6, "W+1", each DateTime.ToText(Date.AddWeeks([LPEP_DROPOFF_DATETIME], 1))),
    T8 = Table.AddColumn(T7, "D+1", each DateTime.ToText(Date.AddDays([LPEP_DROPOFF_DATETIME], 1))),
    T9 = Table.FirstN(T8, 4)
in
    T9