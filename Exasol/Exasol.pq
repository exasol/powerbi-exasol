// This file contains the Exasol Connector logic
[
    Version = "1.0.6"
]
section Exasol;

EnableTraceOutput = false;

// for Development and Troubleshooting
// Load common library functions
// 
Extension.LoadFunction =
    (name as text) =>
        let
            binary = Extension.Contents(name),
            asText = Text.FromBinary(binary)
        in
            Expression.Evaluate(asText, #shared);

// Diagnostics module contains multiple functions. We can take the ones we need.
Diagnostics = Extension.LoadFunction("Diagnostics.pqm");
Diagnostics.LogValue =
    if (EnableTraceOutput) then
        Diagnostics[LogValue]
    else
        (prefix, value) => value;

[
    DataSource.Kind = "Exasol",
    Publish = "Exasol.Publish"
]
shared Exasol.Database =
    Value.ReplaceType(
        ExasolImpl,
        ExasolType
    );
//UI ( https://docs.microsoft.com/en-us/power-query/handlingdocumentation )
ExasolType =
    type function (server as
        (
            type text
            meta
            [
                Documentation.FieldCaption = "Connection String",
                Documentation.FieldDescription = "Exasol Connection String, e.g. 192.168.80.11..15:8563",
                Documentation.SampleValues = {
                    "192.168.80.11..15:8563"
                }
            ]
        ), encrypted as
        (
            type text
            meta
            [
                Documentation.FieldCaption = "Encrypted",
                Documentation.FieldDescription = "If set to Yes, connection will be encrypted",
                Documentation.AllowedValues = {
                    "Yes",
                    "No"
                },
                Documentation.DefaultValue = {
                    "No"
                }
            ]
        ), optional query as
        (
            type text meta [
                Documentation.FieldCaption = "Query", //Extension.LoadString("Parameter.Query.Caption"),
                Documentation.FieldDescription = "You can enter a custom query here.",
                Documentation.SampleValues = {"SELECT * FROM [SCHEMA].[TABLE] LIMIT 5 ;"},
                Formatting.IsMultiLine = true,
                Formatting.IsCode = true
            ]
        )
        ) as table
    meta
    [
        Documentation.Name = "Exasol",
        Documentation.LongDescription = "Exasol",
        Documentation.Icon = Extension.Contents("Exasol32.png")
    ];
//Implementation
ExasolImpl =
    (server as text, encrypted as text, optional query as text ) as table =>
    //null guard (so older reports created with a previous version won't get reference errors
    let 
    _queryStr = if (query <> null) then query else "",

    Odbc.ConnectionString = [
    DRIVER = "EXASolution Driver",
    EXAHOST = server,
    ENCRYPTION = _encrypt
//,LOGMODE = "DEFAULT"
//,EXALOGFILE = "C:\tmp\odbclogfilepowerbi.txt"
],

            bQuery = if Text.Length(_queryStr) > 0 then
            true else false,
            _encrypt =
                if encrypted = "Yes" then
                    "Y"
                else
                    "N",
            
            //https://docs.microsoft.com/en-us/powerquery-m/odbc-datasource
            OdbcDataSource =
            if bQuery = false then
                Odbc.DataSource(
                    Odbc.ConnectionString,
                    Odbc.DataSource.Options
                ) else null
                ,
            Database = 
            if bQuery = false then
            OdbcDataSource{[Name = "EXA_DB"]}[Data]
            else
            null,

            OdbcQueryResult = 
            if bQuery = true then
                Odbc.Query(
                    Odbc.ConnectionString,
                    _queryStr//,
                    //TODO: create a separate options record for OdbcQuery and explore what's needed there
                    //compare to what's going on with Odbc.DataSource.Options
                    //Odbc.DataSource.Options

                ) else null
                ,

            result =
            if bQuery = false then
            Database
            else
            OdbcQueryResult

            in
            result;

// Data Source Kind description
Exasol = [
    Description = "Exasol",
    TestConnection =
        (dataSourcePath) =>
            let
                json = Json.Document(dataSourcePath),
                server = json[server],
                // connection string
                encrypted = json[encrypted]
            in
                {
                    "Exasol.Database",
                    server,
                    encrypted
                },
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
    ButtonText = {
        Extension.LoadString("ButtonTitle"),
        Extension.LoadString("ButtonHelp")
    },
    LearnMoreUrl = "http://www.exasol.com/",
    SourceImage = Exasol.Icons,
    SourceTypeImage = Exasol.Icons
];
Exasol.Icons = [
    Icon16 = {
        Extension.Contents("Exasol16.png"),
        Extension.Contents("Exasol20.png"),
        Extension.Contents("Exasol24.png"),
        Extension.Contents("Exasol32.png")
    },
    Icon32 = {
        Extension.Contents("Exasol32.png"),
        Extension.Contents("Exasol40.png"),
        Extension.Contents("Exasol48.png"),
        Extension.Contents("Exasol64.png")
    }
];


Odbc.DataSource.Options = [
    AstVisitor = Odbc.DataSource.Options.AstVisitor,
    SQLColumns = Odbc.DataSource.Options.SQLColumns,
    SQLGetTypeInfo = Odbc.DataSource.Options.SQLGetTypeInfo,
    HierarchicalNavigation = true,
    HideNativeQuery = false,
    ClientConnectionPooling = true,
    SqlCapabilities = Odbc.Datasource.Options.SqlCapabilities,
    SQLGetFunctions = Odbc.Datasource.Options.SQLGetFunctions,
    SQLGetInfo = Odbc.Datasource.Options.SQLGetInfo
];
// General information on all the Odbc Datasource options:
// https://docs.microsoft.com/en-us/power-query/odbc

// AstVisitor
// A record containing one or more overrides to control SQL query generation. 
// The most common usage of this field is to provide logic to generate a LIMIT/OFFSET clause for drivers that don't support TOP.
Odbc.DataSource.Options.AstVisitor = 
[
                        LimitClause = (skip, take) =>
                            if skip = 0 and take = null then
                                ...
                            else
                                if skip = 0 then
                                    let
                                    b = ""
                                    in
                                    [
                                        Text = Text.Format("LIMIT #{0}", { take }),
                                        Location = "AfterQuerySpecification"
                                    ]
                                else
                                    let
                                    b = ""
                                    in
                                        [
 
                                            Text = Text.Format("LIMIT #{0} OFFSET #{1}", { take, skip }),
                                            Location = "AfterQuerySpecification"
                                        ]
];

// A function that allows you to modify column metadata returned by the SQLColumns function.
// Fixing Unicode issue by mapping the Exasol VARCHAR and CHAR Datatypes to SQL_WVARCHAR and SQL_WCHAR
Odbc.DataSource.Options.SQLColumns =
    (catalogName, schemaName, tableName, columnName, source) =>
        let
            OdbcSqlType.VARCHAR = 12,
            OdbcSqlType.CHAR = 1,
            OdbcSqlType.SQL_WVARCHAR = -9,
            OdbcSqlType.SQL_WCHAR = -8,
            OdbcSqlType.DECIMAL = 3,
            OdbcSqlType.BIGINT = -5,
            FixDataType =
                (dataType) =>
                    if dataType = OdbcSqlType.VARCHAR then
                        OdbcSqlType.SQL_WVARCHAR
                    else if dataType = OdbcSqlType.CHAR then
                        OdbcSqlType.SQL_WVARCHAR
                    else
                        dataType,
            FixDataTypeName =
                (dataTypeName) =>
                    if dataTypeName = "VARCHAR" then
                        "SQL_WVARCHAR"
                    else if dataTypeName = "CHAR" then
                        "SQL_WVARCHAR"
                    else if dataTypeName = "HASHTYPE" then
                        "SQL_WVARCHAR"
                    else
                        dataTypeName,
            Transform1 =
                Table.TransformColumns(
                    source,
                    {
                        {
                            "DATA_TYPE",
                            FixDataType
                        },
                        {
                            "TYPE_NAME",
                            FixDataTypeName
                        }
                    }
                ),
            Transform2 =
                Table.FromRecords(
                    Table.TransformRows(
                        Transform1,
                        (r) =>
                            Record.TransformFields(
                                r,
                                {
                                    {
                                        "DATA_TYPE",
                                        each
                                            if
                                                (
                                                    r[DATA_TYPE]
                                                    = OdbcSqlType.DECIMAL
                                                    and r[DECIMAL_DIGITS]
                                                    = 0
                                                )
                                            then
                                                OdbcSqlType.BIGINT
                                            else
                                                _
                                    },
                                    {
                                        "TYPE_NAME",
                                        each
                                            if
                                                (
                                                    r[TYPE_NAME]
                                                    = "DECIMAL"
                                                    and r[DECIMAL_DIGITS]
                                                    = 0
                                                )
                                            then
                                                "BIGINT"
                                            else
                                                _
                                    }
                                }
                            )
                    )
                ),
            Transform3 =
                Value.ReplaceType(
                    Transform2,
                    Value.Type(source)
                )
        in
            Transform3;

// A table, or function that returns a table, that overrides the type information returned by SQLGetTypeInfo.
// ...
// When the value is set to a function, your function will receive the result of the original call to SQLGetTypeInfo, allowing you to modify the table.
Odbc.DataSource.Options.SQLGetTypeInfo =
    (types as table) as table =>
        let
            newTypes =
                #table(
                    {
                        "TYPE_NAME",
                        "DATA_TYPE",
                        "COLUMN_SIZE",
                        "LITERAL_PREFIX",
                        "LITERAL_SUFFIX",
                        "CREATE_PARAMS",
                        "NULLABLE",
                        "CASE_SENSITIVE",
                        "SEARCHABLE",
                        "UNSIGNED_ATTRIBUTE",
                        "FIXED_PREC_SCALE",
                        "AUTO_UNIQUE_VALUE",
                        "LOCAL_TYPE_NAME",
                        "MINIMUM_SCALE",
                        "MAXIMUM_SCALE",
                        "SQL_DATA_TYPE",
                        "SQL_DATETIME_SUB",
                        "NUM_PREC_RADIX",
                        "INTERVAL_PRECISION"
                    },
                    // we add a new entry for each type we want to add, the following entries are needed so that Power BI is able to handle Unicode characters
                    {
                        {
                            "SQL_WCHAR",
                            -8,
                            2000,
                            "'",
                            "'",
                            "max length",
                            1,
                            1,
                            3,
                            null,
                            0,
                            null,
                            "SQL_WCHAR",
                            null,
                            null,
                            -8,
                            null,
                            null,
                            null
                        },
                        {
                            "SQL_WVARCHAR",
                            -9,
                            2000000,
                            "'",
                            "'",
                            "max length",
                            1,
                            1,
                            3,
                            null,
                            0,
                            null,
                            "SQL_WVARCHAR",
                            null,
                            null,
                            -9,
                            null,
                            null,
                            null
                        }
                    }
                ),
            append =
                Table.Combine(
                    {
                        types,
                        newTypes
                    }
                )
        in
            append;

// A record providing various overrides of driver capabilities, and a way to specify capabilities that aren't expressed through ODBC 3.8.
Odbc.Datasource.Options.SqlCapabilities = [
    Sql92Conformance = 8/* SQL_SC_SQL92_FULL */ ,
    //GroupByCapabilities = 2 /*SQL_GB_GROUP_BY_CONTAINS_SELECT = 0x0002*/,
    FractionalSecondsScale = 3,
    SupportsNumericLiterals = true,
    SupportsStringLiterals = true,
    SupportsOdbcDateLiterals = true,
    SupportsOdbcTimestampLiterals = true
];

// A record that allows you to override values returned by calls to SQLGetFunctions.
// A common use of this field is to disable the use of parameter binding, or to specify that generated queries should use CAST rather than CONVERT.
Odbc.Datasource.Options.SQLGetFunctions = [
    SQL_API_SQLBINDPARAMETER = false
];

// A record that allows you to override values returned by calls to SQLGetInfo.
Odbc.Datasource.Options.SQLGetInfo = [
    SQL_SQL92_PREDICATES = 0x00001F07,
    SQL_AGGREGATE_FUNCTIONS = 0x7F,
    SQL_SQL92_RELATIONAL_JOIN_OPERATORS = 0x0000037F,
    SQL_CONVERT_FUNCTIONS = 0x00000002,
    //  Tell Power BI that Exasol only knows Casts so no CONVERT functions are generated
    SQL_CONVERT_VARCHAR = 0x0082F1FF,
    // Tell Power BI that Exasol also is able to convert SQL_WVARCHAR, additional fix for Unicode characters (Exasol ODBC returns 0x0002F1FF)
    SQL_CONVERT_WVARCHAR = 0x0082F1FF
//,   // Tell Power BI that Exasol also is able to convert SQL_WVARCHAR, additional fix for Unicode characters (Exasol ODBC returns 0x0002F1FF)
];