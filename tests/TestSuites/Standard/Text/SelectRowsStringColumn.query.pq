(parameter) =>
let
    SelectRows = Table.SelectRows(parameter[zone_table], each [BOROUGH] = "Queens"),
    SelectColumns = Table.SelectColumns(SelectRows, { "BOROUGH", "LOCATIONID" }),
    Sort = Table.Sort(SelectColumns, {"LOCATIONID"}),
    FirstN = Table.FirstN(Sort, 2)
in
    FirstN
