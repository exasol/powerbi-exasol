(parameter) =>
let
    SelectColumns = Table.SelectColumns(parameter[taxi_table], { "LPEP_DROPOFF_DATETIME" }),
    Sort = Table.Sort(SelectColumns, {{(t1008) => if t1008[LPEP_DROPOFF_DATETIME] <> null then t1008[LPEP_DROPOFF_DATETIME] else DateTime.From(- 2), Order.Ascending}, {(t1009) => if t1009[LPEP_DROPOFF_DATETIME] = null then 0 else 1, Order.Ascending}})
in
    Sort
