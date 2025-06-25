(parameter) =>
let
    AddColumn = Table.AddColumn(parameter[taxi_table], "Column", each [TOTAL_AMOUNT] + [VENDORID]),
    SelectColumns = Table.SelectColumns(AddColumn, { "Column" }),
    GroupedRows = Table.Group(parameter[taxi_table], {}, {{"Column", each Number.Round(List.Sum([TOTAL_AMOUNT]), 2), type number}})
in
    GroupedRows