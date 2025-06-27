(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"RECORDID","LPEP_PICKUP_DATETIME"}),
    T3 = Table.Sort(T2, {"RECORDID"}),
    T4 = Table.AddColumn(T3, "Y", each Date.Year([LPEP_PICKUP_DATETIME])),
    T5 = Table.AddColumn(T4, "M", each Date.Month([LPEP_PICKUP_DATETIME])),
    T6 = Table.AddColumn(T5, "D", each Date.Day([LPEP_PICKUP_DATETIME])),
    T7 = Table.AddColumn(T6, "QOY", each Date.QuarterOfYear([LPEP_PICKUP_DATETIME])),
    T8 = Table.AddColumn(T7, "WOY", each Date.WeekOfYear([LPEP_PICKUP_DATETIME])),
    T9 = Table.AddColumn(T8, "DOY", each Date.DayOfYear([LPEP_PICKUP_DATETIME])),
    TA = Table.FirstN(T9, 4)
in
    TA