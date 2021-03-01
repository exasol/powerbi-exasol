// This file contains the Exasol Connector logic
[
    Version = "1.0.6"
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
    (server as text, encrypted as text, optional query as text ) => //as table =>
    let 
        currentCredentials = Extension.CurrentCredential(),
        authenticationKind = currentCredentials[AuthenticationKind],

        OpenIDKey = if (currentCredentials[Password] <> null) then currentCredentials[Password] else "",

    //null guard (so older reports created with a previous version won't get reference errors
    _queryStr = if (query <> null) then query else "",
            bQuery = if Text.Length(_queryStr) > 0 then
            true else false,
    OdbcConnectionString = [
    DRIVER = "EXASolution Driver",
    EXAHOST = server,
    ENCRYPTION = _encrypt
//,LOGMODE = "DEFAULT"
//,EXALOGFILE = "C:\tmp\odbclogfilepowerbi.txt"
],

    bOpenId = if authenticationKind = "Key" then true else false,
    OdbcOptions = GetOptions(bOpenId,bQuery,OpenIDKey),

            _encrypt =
                if encrypted = "Yes" then
                    "Y"
                else
                    "N",
            
            //https://docs.microsoft.com/en-us/powerquery-m/odbc-datasource
            OdbcDataSource =
            
                Odbc.DataSource(
                    OdbcConnectionString,
                    OdbcOptions)
                ,
            Database = 
            OdbcDataSource{[Name = "EXA_DB"]}[Data],
     
            OdbcQueryResult = if OdbcOptions <> null then Odbc.Query( OdbcConnectionString, _queryStr,OdbcOptions ) else
             Odbc.Query( OdbcConnectionString, _queryStr ),
            //since mashup has 'lazy evaluation' we should be able to simplify it to this
            result = 
             if bQuery = false then
             Database
             else
             OdbcQueryResult

            in
            result;

GetOptions = ( openId as logical, query as logical, openIDKey as text) =>
let
    
    OpenIdConnectionStringRecord = [
    AUTHMETHOD = "refreshtoken",
    EXAPWD = openIDKey
    ],
    DatasourceUsernamePassword = [
    
    AstVisitor = Odbc.DataSource.Options.AstVisitor,
    SQLColumns = Odbc.DataSource.Options.SQLColumns,
    SQLGetTypeInfo = Odbc.DataSource.Options.SQLGetTypeInfo,
    HierarchicalNavigation = true,
    HideNativeQuery = false,
    ClientConnectionPooling = true,
    SqlCapabilities = Odbc.Datasource.Options.SqlCapabilities,
    SQLGetFunctions = Odbc.Datasource.Options.SQLGetFunctions,
    SQLGetInfo = Odbc.Datasource.Options.SQLGetInfo
],
    DatasourceOpenId = [
    CredentialConnectionString = OpenIdConnectionStringRecord,
    AstVisitor = Odbc.DataSource.Options.AstVisitor,
    SQLColumns = Odbc.DataSource.Options.SQLColumns,
    SQLGetTypeInfo = Odbc.DataSource.Options.SQLGetTypeInfo,
    HierarchicalNavigation = true,
    HideNativeQuery = false,
    ClientConnectionPooling = true,
    SqlCapabilities = Odbc.Datasource.Options.SqlCapabilities,
    SQLGetFunctions = Odbc.Datasource.Options.SQLGetFunctions,
    SQLGetInfo = Odbc.Datasource.Options.SQLGetInfo
],

    QueryOpenId = [
    CredentialConnectionString = OpenIdConnectionStringRecord
],
QueryUsernamePassword = null,

options = 
    if query = false and openId = false then
    DatasourceUsernamePassword
    else if query = false and openId = true then
    DatasourceOpenId
    else if query = true and openId = false then
    QueryUsernamePassword
    else if query = true and openId = true then
    QueryOpenId
    else
    ... //not implemented error
in
options
;

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
        UsernamePassword = [],
        Key = [KeyLabel= "Personal access token", Label= "OpenID"]

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



//TRACING
//START OF PJTRACE
    Diagnostics.ValueToText = (value) =>
        let
            _canBeIdentifier = (x) =>
                                            let
                                                keywords = {"and", "as", "each", "else", "error", "false", "if", "in", "is", "let", "meta", "not", "otherwise", "or", "section", "shared", "then", "true", "try", "type" },
                                                charAlpha = (c as number) => (c>= 65 and c <= 90) or (c>= 97 and c <= 122) or c=95,
                                                charDigit = (c as number) => c>= 48 and c <= 57
                                            in
                                                try
                                                    charAlpha(Character.ToNumber(Text.At(x,0))) 
                                                    and
                                                        List.MatchesAll(
                                                            Text.ToList(x),
                                                            (c)=> let num = Character.ToNumber(c) in charAlpha(num) or charDigit(num)
                                                        )
                                                    and not 
                                                        List.MatchesAny( keywords, (li)=> li=x )
                                                otherwise 
                                                    false,
    
            Serialize.Binary =      (x) => "#binary(" & Serialize(Binary.ToList(x)) & ") ",

            Serialize.Date =        (x) => "#date(" & 
                                           Text.From(Date.Year(x))  & ", " & 
                                           Text.From(Date.Month(x)) & ", " & 
                                           Text.From(Date.Day(x))   & ") ",

            Serialize.Datetime =    (x) => "#datetime(" &
                                           Text.From(Date.Year(DateTime.Date(x)))    & ", " &
                                           Text.From(Date.Month(DateTime.Date(x)))   & ", " &
                                           Text.From(Date.Day(DateTime.Date(x)))     & ", " &
                                           Text.From(Time.Hour(DateTime.Time(x)))    & ", " &
                                           Text.From(Time.Minute(DateTime.Time(x)))  & ", " &
                                           Text.From(Time.Second(DateTime.Time(x)))  & ") ",

            Serialize.Datetimezone =(x) => let 
                                              dtz = DateTimeZone.ToRecord(x) 
                                           in
                                              "#datetimezone(" & 
                                              Text.From(dtz[Year])        & ", " &
                                              Text.From(dtz[Month])       & ", " &
                                              Text.From(dtz[Day])         & ", " &
                                              Text.From(dtz[Hour])        & ", " &
                                              Text.From(dtz[Minute])      & ", " &
                                              Text.From(dtz[Second])      & ", " &
                                              Text.From(dtz[ZoneHours])   & ", " &
                                              Text.From(dtz[ZoneMinutes]) & ") ",

            Serialize.Duration =    (x) => let
                                              dur = Duration.ToRecord(x)
                                           in
                                              "#duration(" &
                                              Text.From(dur[Days])    & ", " &
                                              Text.From(dur[Hours])   & ", " &
                                              Text.From(dur[Minutes]) & ", " &
                                              Text.From(dur[Seconds]) & ") ",

            Serialize.Function =    (x) => _serialize_function_param_type(
                                              Type.FunctionParameters(Value.Type(x)),
                                              Type.FunctionRequiredParameters(Value.Type(x)) ) &
                                           " as " &
                                           _serialize_function_return_type(Value.Type(x)) &
                                           " => (...) ",

            Serialize.List =        (x) => "{" & 
                                           List.Accumulate(x, "", (seed,item) => if seed="" then Serialize(item) else seed & ", " & Serialize(item)) &
                                           "} ",

            Serialize.Logical =     (x) => Text.From(x),

            Serialize.Null =        (x) => "null",

            Serialize.Number =      (x) => 
                                        let Text.From = (i as number) as text => 
                                            if Number.IsNaN(i) then "#nan" else
                                            if i=Number.PositiveInfinity then "#infinity" else
                                            if i=Number.NegativeInfinity then "-#infinity" else
                                            Text.From(i)
                                        in
                                            Text.From(x),

            Serialize.Record =      (x) => "[ " &
                                           List.Accumulate(
                                                Record.FieldNames(x), 
                                                "", 
                                                (seed,item) => 
                                                    (if seed="" then Serialize.Identifier(item) else seed & ", " & Serialize.Identifier(item)) & " = " & Serialize(Record.Field(x, item))
                                           ) &
                                           " ] ",

            Serialize.Table =       (x) => "#table( type " &
                                            _serialize_table_type(Value.Type(x)) &
                                            ", " &
                                            Serialize(Table.ToRows(x)) &
                                            ") ",
                                    
            Serialize.Text =        (x) => """" & 
                                           _serialize_text_content(x) & 
                                           """",

            _serialize_text_content =  (x) => let 
                                                escapeText = (n as number) as text => "#(#)(" & Text.PadStart(Number.ToText(n, "X", "en-US"), 4, "0") & ")"
                                            in
                                            List.Accumulate(
                                               List.Transform(
                                                   Text.ToList(x),
                                                   (c) => let n=Character.ToNumber(c) in 
                                                            if n = 9   then "#(#)(tab)" else
                                                            if n = 10  then "#(#)(lf)"  else
                                                            if n = 13  then "#(#)(cr)"  else
                                                            if n = 34  then """"""      else
                                                            if n = 35  then "#(#)(#)"   else
                                                            if n < 32  then escapeText(n) else 
                                                            if n < 127 then Character.FromNumber(n) else 
                                                            escapeText(n) 
                                                ),
                                                "",
                                                (s,i)=>s&i
                                            ),
        
            Serialize.Identifier =   (x) => 
                                            if _canBeIdentifier(x) then 
                                                x 
                                            else 
                                                "#""" &
                                                _serialize_text_content(x) &
                                                """",

            Serialize.Time =        (x) => "#time(" &
                                           Text.From(Time.Hour(x))   & ", " & 
                                           Text.From(Time.Minute(x)) & ", " & 
                                           Text.From(Time.Second(x)) & ") ",
                                
            Serialize.Type =        (x) => "type " & _serialize_typename(x),
                                    
                             
            _serialize_typename =    (x, optional funtype as logical) =>                        /* Optional parameter: Is this being used as part of a function signature? */
                                        let
                                            isFunctionType = (x as type) => try if Type.FunctionReturn(x) is type then true else false otherwise false,
                                            isTableType = (x as type) =>  try if Type.TableSchema(x) is table then true else false otherwise false,
                                            isRecordType = (x as type) => try if Type.ClosedRecord(x) is type then true else false otherwise false,
                                            isListType = (x as type) => try if Type.ListItem(x) is type then true else false otherwise false
                                        in
                                
                                            if funtype=null and isTableType(x) then _serialize_table_type(x) else
                                            if funtype=null and isListType(x) then "{ " & @_serialize_typename( Type.ListItem(x) ) & " }" else
                                            if funtype=null and isFunctionType(x) then "function " & _serialize_function_type(x) else
                                            if funtype=null and isRecordType(x) then _serialize_record_type(x) else
                                    
                                            if x = type any then "any" else
                                            let base = Type.NonNullable(x) in
                                              (if Type.IsNullable(x) then "nullable " else "") &       
                                              (if base = type anynonnull then "anynonnull" else                
                                              if base = type binary then "binary" else                
                                              if base = type date   then "date"   else
                                              if base = type datetime then "datetime" else
                                              if base = type datetimezone then "datetimezone" else
                                              if base = type duration then "duration" else
                                              if base = type logical then "logical" else
                                              if base = type none then "none" else
                                              if base = type null then "null" else
                                              if base = type number then "number" else
                                              if base = type text then "text" else 
                                              if base = type time then "time" else 
                                              if base = type type then "type" else 
                                      
                                              /* Abstract types: */
                                              if base = type function then "function" else
                                              if base = type table then "table" else
                                              if base = type record then "record" else
                                              if base = type list then "list" else
                                      
                                              "any /*Actually unknown type*/"),

            _serialize_table_type =     (x) => 
                                               let 
                                                 schema = Type.TableSchema(x)
                                               in
                                                 "table " &
                                                 (if Table.IsEmpty(schema) then "" else 
                                                     "[" & List.Accumulate(
                                                        List.Transform(
                                                            Table.ToRecords(Table.Sort(schema,"Position")),
                                                            each Serialize.Identifier(_[Name]) & " = " & _[Kind]),
                                                        "",
                                                        (seed,item) => (if seed="" then item else seed & ", " & item )
                                                    ) & "] " ),

            _serialize_record_type =    (x) => 
                                                let flds = Type.RecordFields(x)
                                                in
                                                    if Record.FieldCount(flds)=0 then "record" else
                                                        "[" & List.Accumulate(
                                                            Record.FieldNames(flds),
                                                            "",
                                                            (seed,item) => 
                                                                seed &
                                                                (if seed<>"" then ", " else "") &
                                                                (Serialize.Identifier(item) & "=" & _serialize_typename(Record.Field(flds,item)[Type]) )
                                                        ) & 
                                                        (if Type.IsOpenRecord(x) then ",..." else "") &
                                                        "]",

            _serialize_function_type =  (x) => _serialize_function_param_type(
                                                  Type.FunctionParameters(x),
                                                  Type.FunctionRequiredParameters(x) ) &
                                                " as " &
                                                _serialize_function_return_type(x),
    
            _serialize_function_param_type = (t,n) => 
                                    let
                                        funsig = Table.ToRecords(
                                            Table.TransformColumns(
                                                Table.AddIndexColumn( Record.ToTable( t ), "isOptional", 1 ),
                                                { "isOptional", (x)=> x>n } ) )
                                    in
                                        "(" & 
                                        List.Accumulate(
                                            funsig,
                                            "",
                                            (seed,item)=>
                                                (if seed="" then "" else seed & ", ") &
                                                (if item[isOptional] then "optional " else "") &
                                                Serialize.Identifier(item[Name]) & " as " & _serialize_typename(item[Value], true) )
                                         & ")",

            _serialize_function_return_type = (x) => _serialize_typename(Type.FunctionReturn(x), true), 

            Serialize = (x) as text => 
                               if x is binary       then try Serialize.Binary(x) otherwise "null /*serialize failed*/"        else 
                               if x is date         then try Serialize.Date(x) otherwise "null /*serialize failed*/"          else 
                               if x is datetime     then try Serialize.Datetime(x) otherwise "null /*serialize failed*/"      else 
                               if x is datetimezone then try Serialize.Datetimezone(x) otherwise "null /*serialize failed*/"  else 
                               if x is duration     then try Serialize.Duration(x) otherwise "null /*serialize failed*/"      else 
                               if x is function     then try Serialize.Function(x) otherwise "null /*serialize failed*/"      else 
                               if x is list         then try Serialize.List(x) otherwise "null /*serialize failed*/"          else 
                               if x is logical      then try Serialize.Logical(x) otherwise "null /*serialize failed*/"       else
                               if x is null         then try Serialize.Null(x) otherwise "null /*serialize failed*/"          else
                               if x is number       then try Serialize.Number(x) otherwise "null /*serialize failed*/"        else
                               if x is record       then try Serialize.Record(x) otherwise "null /*serialize failed*/"        else 
                               if x is table        then try Serialize.Table(x) otherwise "null /*serialize failed*/"         else 
                               if x is text         then try Serialize.Text(x) otherwise "null /*serialize failed*/"          else 
                               if x is time         then try Serialize.Time(x) otherwise "null /*serialize failed*/"          else 
                               if x is type         then try Serialize.Type(x) otherwise "null /*serialize failed*/"          else 
                               "[#_unable_to_serialize_#]"                     
        in
            try Serialize(value) otherwise "<serialization failed>";
PJTrace = (info as text,value) => {
let 

//valueText = Text.From(value),
valueText = Diagnostics.ValueToText(value),
traceText = "TRACE: " & info & " : " & valueText,
trace = Diagnostics.Trace(
TraceLevel.Information,traceText,valueText
)
in trace
};
//END OF PJTRACE