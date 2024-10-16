// This file contains the Exasol Connector logic
[
    Version = "1.1.0"
]
section Exasol;

// EnableTraceOutput = false;
// // for Development and Troubleshooting
// // Load common library functions
// // 
// // Defines a function capable of loading functions from other files
// Extension.LoadFunction =
//     (name as text) =>
//         let
//             binary = Extension.Contents(name),
//             asText = Text.FromBinary(binary)
//         in
//             Expression.Evaluate(asText, #shared);
// // Diagnostics module contains multiple functions. We can take the ones we need.
// Diagnostics = Extension.LoadFunction("Diagnostics.pqm");
// Diagnostics.LogValue =
//     if (EnableTraceOutput) then
//         Diagnostics[LogValue]
//     else
//         (prefix, value) => value;
[
    DataSource.Kind = "Exasol",
    Publish = "Exasol.Publish"
]
shared Exasol.Database =
    Value.ReplaceType(
        ExasolImpl,
        ExasolType
    );

//handling the UI part of the connector requires using (custom) types and metadata, see the links below for more information:
//https://docs.microsoft.com/en-us/powerquery-m/m-spec-types
//https://bengribaudo.com/blog/2021/03/17/5523/power-query-m-primer-part20-metadata
//https://docs.microsoft.com/en-us/power-query/handlingdocumentation
//the implementation part itself is documented in the data connectors odbc sample (sqlODBC:
//but for some reason no-one includes their UI definition.
//recOptions = type [ Name = text, Age = number ]
//UI ( https://docs.microsoft.com/en-us/power-query/handlingdocumentation )
ExasolType =
    type function (server as
        (
            type text
            meta
            [
                Documentation.FieldCaption = "Connection String",
                Documentation.FieldDescription = "Exasol Connection String, e.g. 192.168.80.11..15:8563 or a DSN: DSN=exa-one",
                Documentation.SampleValues = {
                    "192.168.80.11..15:8563",
                    "DSN=exa-one"
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
        )) as table
    meta
    [
        Documentation.Name = "Exasol",
        Documentation.LongDescription = "Exasol",
        Documentation.Icon = Extension.Contents("Exasol32.png")
    ];

ExasolImpl =
    (server as text, encrypted as text) =>
        let
            // These fields come from the options record, so they might be null.
            currentCredentials = Extension.CurrentCredential(),
            authenticationKind = currentCredentials[AuthenticationKind],
            //null guard (so older reports created with a previous version won't get reference errors

            bWindowsKerberos =
                if authenticationKind = "Windows" then
                    true
                else
                    false,
            odbcConnectionString =
                CreateOdbcConnectionStringRecord(
                    server,
                    encrypted
                ),
            appendedOdbcConnectionString =
                AppendOdbcConnectionStringForKerberosAuthentication(
                    odbcConnectionString,
                    bWindowsKerberos,
                    server
                ),
            odbcOptions = GetOptions(),
            _encrypt =
                if encrypted = "Yes" then
                    "Y"
                else
                    "N",
            //https://docs.microsoft.com/en-us/powerquery-m/odbc-datasource
            odbcDataSource =
                Odbc.DataSource(
                    appendedOdbcConnectionString,
                    odbcOptions
                ),
            database = odbcDataSource{[Name = "EXA_DB"]}[Data],

            //mashup has 'lazy evaluation'so we can simplify logic/move the if to the later steps since if we don't use something it won't get evaluated.
            result = database
        in
            result;

CreateOdbcConnectionStringRecord =
    (server as text, encrypt as text) as record =>
        let
            splitServerList = Text.Split(server, "="),
            dsnNamePart = splitServerList{1},
            dsnName =
                Text.Remove(
                    dsnNamePart,
                    {
                        "'",
                        """"
                    }
                ),
            odbcConnectionString =
                if
                    Text.Contains(
                        server,
                        "DSN=",
                        Comparer.OrdinalIgnoreCase
                    )
                then
                    [
                        DSN = dsnName
                    ]
                else
                    [
                        DRIVER = "EXASolution Driver",
                        EXAHOST = server,
                        ENCRYPTION = encrypt
                    //,LOGMODE = "DEFAULT"
                    //,EXALOGFILE = "C:\tmp\odbclogfilepowerbi.txt"
                    ]
        in
            odbcConnectionString;

AppendOdbcConnectionStringForKerberosAuthentication =
    (OdbcConnectionString as record, bKerberos as logical, server as text) as record =>
        let
            odbcKerberosRecord = [
                KERBEROSSERVICENAME = "exasol/" & server
            ],
            toBeCombinedRecordsList = {
                OdbcConnectionString,
                odbcKerberosRecord
            },
            bDsn =
                if
                    Text.Contains(
                        server,
                        "DSN=",
                        Comparer.OrdinalIgnoreCase
                    )
                then
                    true
                else
                    false,
            combinedRecord =
                if bKerberos and bDsn = false then
                    Record.Combine(toBeCombinedRecordsList)
                else
                    OdbcConnectionString
        in
            combinedRecord;

GetOptions =
    () =>
        let
            DatasourceUsernamePassword = [
                SQLColumns = Odbc.DataSource.Options.SQLColumns,
                SQLGetTypeInfo = Odbc.DataSource.Options.SQLGetTypeInfo,
                //HierarchicalNavigation : Turning this off will make datasource navigation work in a different way and would thus break all the existing reports
                HierarchicalNavigation = true,
                HideNativeQuery = false,
                ClientConnectionPooling = true,
                SqlCapabilities = Odbc.Datasource.Options.SqlCapabilities,
                SQLGetFunctions = Odbc.Datasource.Options.SQLGetFunctions,
                SQLGetInfo = Odbc.Datasource.Options.SQLGetInfo
            ],
            options =  DatasourceUsernamePassword
        in
            options;

// Data Source Kind description
Exasol = [
    Description = "Exasol",
    //Test connection needed for gateway support: https://docs.microsoft.com/en-us/power-query/handlinggatewaysupport
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
        UsernamePassword = [],
        Windows = [
            Label = "Windows / Kerberos"
        ],
        Implicit = []
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

// General information on all the Odbc Datasource options:
// https://docs.microsoft.com/en-us/power-query/odbc

// A function that allows you to modify column metadata returned by the SQLColumns function.
// Fixing Unicode issue by mapping the Exasol VARCHAR and CHAR Datatypes to SQL_WVARCHAR and SQL_WCHAR
Odbc.DataSource.Options.SQLColumns =
    (catalogName, schemaName, tableName, columnName, source) =>
        let
            //DECLARE type values
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
            //the new types get added to the exising ones and the merged table gets returned
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
    Sql92Translation = "PassThrough",
    //GroupByCapabilities = 2 /*SQL_GB_GROUP_BY_CONTAINS_SELECT = 0x0002*/,
    FractionalSecondsScale = 3,
    SupportsNumericLiterals = true,
    SupportsStringLiterals = true,
    SupportsOdbcDateLiterals = true,
    SupportsOdbcTimestampLiterals = true,
    LimitClauseKind = LimitClauseKind.Limit
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