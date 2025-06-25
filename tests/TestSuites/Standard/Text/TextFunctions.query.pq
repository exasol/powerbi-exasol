(parameter) =>
let
    Sort = Table.Sort(parameter[zone_table], {"LOCATIONID"}),
    Columns = [
        Contains = each Text.Contains([TAXIZONE], "ton") ,
        StartsWith = each Text.StartsWith([TAXIZONE], "Was"),
        EndsWith = each Text.EndsWith([TAXIZONE], "th")
        
    ],
    SelectRows = List.Accumulate(Record.FieldNames(Columns), Sort,
        (state, current) => Table.SelectRows(state, Record.Field(Columns, current))),
    SelectColumns = Table.SelectColumns(SelectRows, { "TAXIZONE" }),
    Buffer = Table.Buffer(SelectColumns)
in
    Buffer