(parameter) =>
let
    Sorted = Table.Sort(parameter[taxi_table], {"RECORDID"}),
    Columns = [
                TimestampToDateCast = each Date.From([LPEP_PICKUP_DATETIME]),
                TimestampToStringCast = each Text.From([LPEP_DROPOFF_DATETIME],"en-US"),
                FloatToIntegerCast =    each Int64.From([TRIP_DISTANCE]),
                FloatToStringCast =     each Text.From(Number.Round([FARE_AMOUNT], 2)),
                IntegerToFloatCast =    each Double.From([PULOCATIONID]),
                IntegerToStringCast =   each Text.From([PASSENGER_COUNT]),
                BooleanToStringCast =   each Text.From([STORE_AND_FWD_FLAG])
            ],
    AddColumns = List.Accumulate(Record.FieldNames(Columns), Sorted,
        (state, current) => Table.AddColumn(state, current, Record.Field(Columns, current))),
    SelectRows = Table.SelectRows(AddColumns, each [PULOCATIONID] = 75),
    SelectColumns = Table.SelectColumns(SelectRows, Record.FieldNames(Columns)),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN