(parameter) =>
let
    AddColumns = Table.AddColumn(parameter[taxi_table], "Custom", each Number.Round(([PAYMENT_TYPE] * [FARE_AMOUNT]), 2)),
    SelectColumns = Table.SelectColumns(AddColumns, { "LPEP_PICKUP_DATETIME", "Custom" }),
    Sort = Table.Sort(SelectColumns, { { "LPEP_PICKUP_DATETIME", Order.Ascending } }),
    FirstN = Table.FirstN(Sort, 2)
in
    FirstN