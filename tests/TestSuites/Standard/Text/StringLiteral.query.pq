(parameter) =>
let
    Sort = Table.Sort(parameter[zone_table], {"LOCATIONID"}),
    SelectRows = Table.SelectRows(Sort, each [TAXIZONE] = "Westchester Village/Unionport"),
    SelectColumns = Table.SelectColumns(SelectRows, { "TAXIZONE" })
in
    SelectColumns