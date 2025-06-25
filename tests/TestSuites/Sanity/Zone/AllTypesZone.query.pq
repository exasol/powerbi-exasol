(parameter) =>
let
    Sort = Table.Sort(parameter[zone_table], {"LOCATIONID"})
in
    Sort