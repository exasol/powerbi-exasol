(parameter) =>
let
    Columns = [
            ABS = each Number.Abs([FARE_AMOUNT]) ,
            ACOS = each Number.Acos([FARE_AMOUNT] / [FARE_AMOUNT]),
            ASIN = each Number.Asin([FARE_AMOUNT] / [FARE_AMOUNT]),
            ATAN = each Number.Atan([FARE_AMOUNT]),
            CEILING = each Number.RoundUp([FARE_AMOUNT]),
            COS = each Number.Cos([FARE_AMOUNT]),
            EXP = each Number.Exp([FARE_AMOUNT]),
            FLOOR = each Number.RoundDown([FARE_AMOUNT]),
            LOG = each Number.Log([PULOCATIONID]),
            LOG10 = each Number.Round(Number.Log10([PULOCATIONID]), 12),
            POWER = each Number.Power([FARE_AMOUNT] / [FARE_AMOUNT], 3),
            ROUND = each Number.Round([FARE_AMOUNT]),
            ROUNDDIGITS = each Number.Round([FARE_AMOUNT], 1),
            SIGN = each Number.Sign([FARE_AMOUNT]),
            SQRT = each Number.Sqrt([FARE_AMOUNT]),
            TAN = each Number.Tan([FARE_AMOUNT])
        ],
    Sorted = Table.Sort(parameter[taxi_table], {"RECORDID"}),
    AddColumns = List.Accumulate(Record.FieldNames(Columns), Sorted,
        (state, current) => Table.AddColumn(state, current, Record.Field(Columns, current))),
    SelectRows = Table.SelectRows(AddColumns, each [PULOCATIONID] = 170),
    SelectColumns = Table.SelectColumns(SelectRows, Record.FieldNames(Columns)),
    FirstN = Table.FirstN(SelectColumns, 1)
in
    FirstN