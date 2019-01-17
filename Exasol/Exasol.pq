// This file contains the Exasol Connector logic
[version = "1.0.0"]
section Exasol;


EnableTraceOutput = false; // for Development and Troubleshooting

// Load common library functions
// 
Extension.LoadFunction = (name as text) =>
    let
        binary = Extension.Contents(name),
        asText = Text.FromBinary(binary)
    in
        Expression.Evaluate(asText, #shared);

// Diagnostics module contains multiple functions. We can take the ones we need.
Diagnostics = Extension.LoadFunction("Diagnostics.pqm");
Diagnostics.LogValue = if (EnableTraceOutput) then Diagnostics[LogValue] else (prefix, value) => value; 


[DataSource.Kind="Exasol", Publish="Exasol.Publish"]
shared Exasol.Database = Value.ReplaceType(ExasolImpl, ExasolType);

ExasolType = type function (
    server as (type text meta [
        Documentation.FieldCaption = "Connection String",
        Documentation.FieldDescription = "Exasol Connection String, e.g. 192.168.80.11..15:8563",
        Documentation.SampleValues = {"192.168.80.11..15:8563"}
    ]),
    encrypted as (type text meta [
        Documentation.FieldCaption = "Encrypted",
        Documentation.FieldDescription = "If set to Yes, connection will be encrpyted",
        Documentation.AllowedValues = { "Yes", "No" },
        Documentation.DefaultValue = { "No" }
    ]) 
    
    ) 
    as table meta [
        Documentation.Name = "Exasol",
        Documentation.LongDescription = "Exasol",
        Documentation.Icon = Extension.Contents("Exasol32.png")
    ];

ExasolImpl = (server as text,encrypted as text) as table =>
    let
        _encrypt = if encrypted = "Yes" then "Y" else "N",
        ConnectionString =
        [
            DRIVER = "EXASolution Driver",
            EXAHOST = server,
            ENCRYPTION = _encrypt
            //,LOGMODE = "DEFAULT"
            //,EXALOGFILE = "D:\tmp\odbclogfilepowerbi.txt"
        ],
        OdbcDataSource = Odbc.DataSource(ConnectionString, [
            AstVisitor = [
                        LimitClause = (skip, take) =>
                            if skip = 0 and take = null then
                                ...
                            else
                                if skip = 0 then
                                    let

                                    in 

                                    [
                                        Text = Text.Format("LIMIT #{0}", { take }),
                                        Location = "AfterQuerySpecification"
                                    ]
                                else
                                    let
                                        
                                    in
                                        [
 
                                            Text = Text.Format("LIMIT #{0} OFFSET #{1}", { take, skip }),
                                            Location = "AfterQuerySpecification"
                                        ]
            ],
            // Fixing Unicode issue by mapping the Exasol VARCHAR and CHAR Datatypes to SQL_WVARCHAR and SQL_WCHAR
            SQLColumns = (catalogName, schemaName, tableName, columnName, source) =>
                let
                    OdbcSqlType.VARCHAR = 12,
                    OdbcSqlType.CHAR = 1,
                    OdbcSqlType.SQL_WVARCHAR = -9,
                    OdbcSqlType.SQL_WCHAR = -8,

                    FixDataType = (dataType) =>
                        if dataType = OdbcSqlType.VARCHAR then
                            OdbcSqlType.SQL_WVARCHAR
                        else if dataType = OdbcSqlType.CHAR then
                            OdbcSqlType.SQL_WCHAR
                        else
                            dataType,
                    FixDataTypeName = (dataTypeName) =>
                        if dataTypeName = "VARCHAR" then
                            "SQL_WVARCHAR"
                         else if dataTypeName = "VARCHAR" then
                            "SQL_WCHAR"
                        else
                            dataTypeName,
                    Transform = Table.TransformColumns(source, { { "DATA_TYPE", FixDataType }, { "TYPE_NAME", FixDataTypeName } })
                in
                    Transform,
            SQLGetTypeInfo = (types as table) as table =>
               let
                   newTypes = #table(
                       {
                           "TYPE_NAME", "DATA_TYPE", "COLUMN_SIZE", "LITERAL_PREFIX", "LITERAL_SUFFIX", "CREATE_PARAMS", "NULLABLE", "CASE_SENSITIVE", "SEARCHABLE", "UNSIGNED_ATTRIBUTE", "FIXED_PREC_SCALE", "AUTO_UNIQUE_VALUE", "LOCAL_TYPE_NAME", "MINIMUM_SCALE", "MAXIMUM_SCALE", "SQL_DATA_TYPE", "SQL_DATETIME_SUB", "NUM_PREC_RADIX", "INTERVAL_PRECISION"
                        },
                        // we add a new entry for each type we want to add, the following entries are needed so that Power BI is able to handle Unicode characters
                        {
                            {
                                "SQL_WCHAR", -8, 2000, "'", "'", "max length", 1, 1, 3, null, 0, null, "SQL_WCHAR", null, null, -8, null, null, null
                            },
                            {
                                "SQL_WVARCHAR", -9, 2000000, "'", "'", "max length", 1, 1, 3, null, 0, null, "SQL_WVARCHAR", null, null, -9, null, null, null
                            }

                        }),
                    append = Table.Combine({types, newTypes})
                in
                    append,            
            HierarchicalNavigation = true,
            HideNativeQuery = true,
            ClientConnectionPooling = true,
            SqlCapabilities = [
                Sql92Conformance = 8 /* SQL_SC_SQL92_FULL */,
                //GroupByCapabilities = 2 /*SQL_GB_GROUP_BY_CONTAINS_SELECT = 0x0002*/,
                FractionalSecondsScale = 3 ,
                SupportsNumericLiterals = true,
                SupportsStringLiterals = true,
                SupportsOdbcDateLiterals = true,
                SupportsOdbcTimestampLiterals = true
            ],
            SQLGetFunctions = [
                    SQL_API_SQLBINDPARAMETER = false
            ]
            ,
            SQLGetInfo = [
                SQL_SQL92_PREDICATES = 0x00001F07,
                SQL_AGGREGATE_FUNCTIONS = 0x7F,
                SQL_SQL92_RELATIONAL_JOIN_OPERATORS = 0x0000037F,
                SQL_CONVERT_FUNCTIONS = 0x00000002, //  Tell Power BI that Exasol only knows Casts so no CONVERT functions are generated
                SQL_CONVERT_VARCHAR = 0x0082F1FF,   // Tell Power BI that Exasol also is able to convert SQL_WVARCHAR, additional fix for Unicode characters (Exasol ODBC returns 0x0002F1FF)
                SQL_CONVERT_CHAR = 0x0022F1FF    // Tell Power BI that Exasol also is able to convert SQL_WCHAR, additional fix for Unicode characters (Exasol ODBC returns 0x0002F1FF)
                ]
        ]),
        Database = OdbcDataSource{[Name = "EXA_DB"]}[Data]
    in
        Database;

// Data Source Kind description
Exasol = [
    Description = "Exasol",
	TestConnection = (dataSourcePath) => 
        let
            json = Json.Document(dataSourcePath),
            server = json[server],   // connection string
			encrypted = json[encrypted]
        in
            { "Exasol.Database", server, encrypted },
    Authentication = [
        // Key = [],
        UsernamePassword = []
        // Windows = [],
        //Implicit = []
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
Exasol.Publish = [
    Category = "Database",
    SupportsDirectQuery = true,
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "http://www.exasol.com/",
    SourceImage = Exasol.Icons,
    SourceTypeImage = Exasol.Icons
];

Exasol.Icons = [
    Icon16 = { Extension.Contents("Exasol16.png"), Extension.Contents("Exasol20.png"), Extension.Contents("Exasol24.png"), Extension.Contents("Exasol32.png") },
    Icon32 = { Extension.Contents("Exasol32.png"), Extension.Contents("Exasol40.png"), Extension.Contents("Exasol48.png"), Extension.Contents("Exasol64.png") }
];
