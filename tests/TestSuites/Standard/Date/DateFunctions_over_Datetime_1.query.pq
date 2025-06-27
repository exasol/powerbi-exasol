(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RECORDID","LPEP_DROPOFF_DATETIME"}),
    T3 = Table.Sort(T2, {"RECORDID"}),
    T4 = Table.AddColumn(T3, "Y", each Date.Year([LPEP_DROPOFF_DATETIME])),
    T5 = Table.AddColumn(T4, "M", each Date.Month([LPEP_DROPOFF_DATETIME])),
    T6 = Table.AddColumn(T5, "D", each Date.Day([LPEP_DROPOFF_DATETIME])),
    T7 = Table.AddColumn(T6, "QOY", each Date.QuarterOfYear([LPEP_DROPOFF_DATETIME])),
    T8 = Table.AddColumn(T7, "WOY", each Date.WeekOfYear([LPEP_DROPOFF_DATETIME])),
    T9 = Table.AddColumn(T8, "DOY", each Date.DayOfYear([LPEP_DROPOFF_DATETIME])),
    TA = Table.FirstN(T9, 4)
in
    TA