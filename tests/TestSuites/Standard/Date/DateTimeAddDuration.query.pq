(parameter) => 
let
    Columns = [
        AddDay = each [LPEP_PICKUP_DATETIME] + #duration(1,0,0,0),
        AddHour = each [LPEP_PICKUP_DATETIME] + #duration(0,1,0,0),
        AddMinute = each [LPEP_PICKUP_DATETIME] + #duration(0,0,1,0),
        AddSecond = each [LPEP_PICKUP_DATETIME] + #duration(0,0,0,1),
        AddAll = each [LPEP_PICKUP_DATETIME] + #duration(1,1,1,1.25),
        Subtract = each [LPEP_PICKUP_DATETIME] - #duration(1,1,1,1.25)
    ],
    AddColumns = List.Accumulate(Record.FieldNames(Columns), parameter[taxi_table],
        (state, current) => Table.AddColumn(state, current, Record.Field(Columns, current))),
    Sorted = Table.Sort(AddColumns,{"TOTAL_AMOUNT", Order.Descending}),
    FirstN = Table.FirstN(Sorted,5)
in
    FirstN