(parameter) => 
let
    Sorted = Table.Sort(parameter[taxi_table], {"RECORDID"}),
    TablePickupDateTimeCast = Table.AddColumn(Sorted, "casted_LPEP_PICKUP_DATETIME", each Text.From([LPEP_PICKUP_DATETIME],"en-US")),
    TableDropoffDateTimeCast = Table.AddColumn(TablePickupDateTimeCast, "casted_LPEP_DROPOFF_DATETIME", each Text.From([LPEP_DROPOFF_DATETIME],"en-US")),
    TableSelect = Table.SelectColumns(
        TableDropoffDateTimeCast,
        {
            "LPEP_PICKUP_DATETIME",
            "LPEP_DROPOFF_DATETIME",
            "casted_LPEP_PICKUP_DATETIME",
            "casted_LPEP_DROPOFF_DATETIME"
        }
    ),
    FirstN = Table.FirstN(TableSelect, 1)
in
    FirstN