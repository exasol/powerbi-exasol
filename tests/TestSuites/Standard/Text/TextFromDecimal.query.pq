(parameter) => 
let
   T2 = Table.Sort(parameter[taxi_table], "TOTAL_AMOUNT"),
   T3 = Table.FirstN(T2, 1),
   T4 = Table.AddColumn(T3, "textFromInt", each Text.From([VENDORID])),
   T5 = Table.AddColumn(T4, "textFromDecimal", each Text.From([TOTAL_AMOUNT]))
in
   T5
