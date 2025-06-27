(parameter) =>
let
    Sorted = Table.Sort(parameter[taxi_table],{"FARE_AMOUNT", Order.Descending}),
    Columns = [            
        AdditionInteger = each[PULOCATIONID] + 90, 
        SubtractionInteger = each [PULOCATIONID] - 90,
        MultiplicationInteger = each [PULOCATIONID] * 90,
        DivisionInteger = each Number.Round(([PULOCATIONID] / 90), 8),
        AdditionFloat = each[FARE_AMOUNT] + 90,
        SubtractionFloat = each [FARE_AMOUNT] - 90,
        MultiplicationFloat = each Number.Round([FARE_AMOUNT] * 90.0, 8),
        DivisionFloat = each Number.Round(([FARE_AMOUNT] / 90.0), 8)
    ],
    AddColumns = List.Accumulate(Record.FieldNames(Columns), Sorted,
        (state, current) => Table.AddColumn(state, current, Record.Field(Columns, current))),
    SelectRows = Table.SelectRows(AddColumns, each [PULOCATIONID] = 193),
    SelectColumns = Table.SelectColumns(SelectRows, Record.FieldNames(Columns)),
    FirstN = Table.FirstN(SelectColumns, 1) 
in
    FirstN