 (parameter) =>
 let
    Sorted = Table.Sort(parameter[taxi_table], {"RECORDID"}),
    Columns = [            
        AddDays = each Date.AddDays([LPEP_PICKUP_DATETIME], 2),
        SubDays = each Date.AddDays([LPEP_PICKUP_DATETIME], -2),
        AddYears = each Date.AddYears([LPEP_PICKUP_DATETIME], 2),
        SubYears = each Date.AddYears([LPEP_PICKUP_DATETIME], -2),
        AddMonths = each Date.AddMonths([LPEP_PICKUP_DATETIME], 2),
        SubMonths = each Date.AddMonths([LPEP_PICKUP_DATETIME], -2),
        AddQuarter = each Date.AddQuarters([LPEP_PICKUP_DATETIME], 2),
        SubQuarter = each Date.AddQuarters([LPEP_PICKUP_DATETIME], -2),
        AddWeeks = each Date.AddWeeks([LPEP_PICKUP_DATETIME], 2),
        SubWeeks = each Date.AddWeeks([LPEP_PICKUP_DATETIME], -2)
    ],
    AddColumns = List.Accumulate(Record.FieldNames(Columns), Sorted,
        (state, current) => Table.AddColumn(state, current, Record.Field(Columns, current))),
    SelectRows = Table.SelectRows(AddColumns, each [PULOCATIONID] = 75),
    SelectColumns = Table.SelectColumns(SelectRows, Record.FieldNames(Columns)),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN

// To Do: This test fails for BigQuery as the time is ignored for date operations.