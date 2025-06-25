let
    Source = Exasol.Database("demodb.exasol.com", "Yes"),
    EXASOL_POWERBI_2025_Schema = Source{[Name="EXASOL_POWERBI_2025",Kind="Schema"]}[Data],
    TAXITRIPS_Table = EXASOL_POWERBI_2025_Schema{[Name="TAXITRIPS",Kind="Table"]}[Data],
    TAXIZONES_Table = EXASOL_POWERBI_2025_Schema{[Name="TAXIZONES",Kind="Table"]}[Data]
in
    [taxi_table= TAXITRIPS_Table, zone_table = TAXIZONES_Table]
// Example:
// let
//     Source = Sql.Database("your_server_name", "your_dabase_name"),
//     NycTaxiGreen_Table = Source{[Schema="your_schema_name",Item="NycTaxiGreen"]}[Data],
//     TaxiZoneLookup_Table =  Source{[Schema="your_schema_name",Item="TaxiZoneLookup"]}[Data]
// in
//     [taxi_table = NycTaxiGreen_Table, zone_table = TaxiZoneLookup_Table]
