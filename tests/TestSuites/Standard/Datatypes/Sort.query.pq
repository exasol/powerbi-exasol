(parameter) =>
let
    ColumnNames = { "VENDORID", "LPEP_PICKUP_DATETIME", "STORE_AND_FWD_FLAG", "TRIP_DISTANCE" },
    Tests = List.Accumulate(ColumnNames, [], (state, current) => 
        let 
            Result =
                let
                    Sort = Table.Sort(parameter[taxi_table], current),
                    RowCount = Table.RowCount(Sort)
                in
                    RowCount,
            AddField =  Record.AddField(state, current, Result)
        in
            AddField)
in
    Tests