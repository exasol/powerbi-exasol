(parameter) =>
let
    T2 = Table.SelectColumns(parameter[taxi_table], {"TOTAL_AMOUNT","PAYMENT_TYPE"}),
    T3 = Table.AddColumn(T2, "PaymentTypeIsEmpty", each Value.NullableEquals([PAYMENT_TYPE],4)),
    T4 = Table.Sort(T3, "TOTAL_AMOUNT"),
    T5 = Table.FirstN(T4,5)
in
    T5