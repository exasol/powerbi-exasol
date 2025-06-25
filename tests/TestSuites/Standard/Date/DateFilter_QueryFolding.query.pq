(parameter) =>
let
    T1 = Table.SelectRows(parameter[taxi_table], each ([PULOCATIONID] = 75 or [DOLOCATIONID] = 170) and (DateTime.Date([LPEP_PICKUP_DATETIME]) = #date(2023, 2, 23))),
    T2 = Table.SelectColumns(T1,{"RECORDID", "LPEP_PICKUP_DATETIME", "LPEP_DROPOFF_DATETIME", "PULOCATIONID", "DOLOCATIONID"}),
    T3 = Table.Sort(T2, {"RECORDID"})
in
    T3