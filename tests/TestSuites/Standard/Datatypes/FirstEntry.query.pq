(parameter) => 
let
    Sort = Table.Sort(parameter[taxi_table], {"RECORDID"}),
    FirstN = Table.FirstN(Sort, 1)
in
    FirstN