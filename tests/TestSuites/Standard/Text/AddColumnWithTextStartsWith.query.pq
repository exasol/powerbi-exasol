(parameter) =>
let
    AddedColumn = Table.AddColumn(parameter[zone_table], "Startswith", each Text.StartsWith([TAXIZONE], "West")),
    SelectRows = Table.SelectRows(AddedColumn, each [TAXIZONE] = "Westchester Village/Unionport")
in
    SelectRows