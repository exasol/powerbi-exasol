// This file contains your Data Connector logic
section Exasol;

[DataSource.Kind="Exasol", Publish="Exasol.Publish"]
shared Exasol.Database = Value.ReplaceType(ExasolImpl, ExasolType);

ExasolType = type function (
    server as (type text meta [
        Documentation.FieldCaption = "Connection String",
        Documentation.FieldDescription = "Exasol Connection String, e.g. 192.168.80.11..15:8563",
        Documentation.SampleValues = {"192.168.80.11..15:8563"}
    ])) 
    as table meta [
        Documentation.Name = "Exasol",
        Documentation.LongDescription = "Exasol"
    ];

ExasolImpl = (server as text ) as table =>
    let
        ConnectionString =
        [
            DRIVER = "EXASolution Driver",
            EXAHOST = server
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
            HierarchicalNavigation = true,
            SqlCapabilities = [
                Sql92Conformance = 8 /* SQL_SC_SQL92_FULL */,
                //GroupByCapabilities = 2 /*SQL_GB_GROUP_BY_CONTAINS_SELECT = 0x0002*/,
                FractionalSecondsScale = 3,
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
                SQL_SQL92_PREDICATES = 0x0000FFFF,
                SQL_AGGREGATE_FUNCTIONS = 0xFF,
                SQL_SQL92_RELATIONAL_JOIN_OPERATORS = 0x000003FF
            ]
        ]),
        Database = OdbcDataSource{[Name = "EXA_DB"]}[Data]
    in
        Database;

// Data Source Kind description
Exasol = [
    Description = "Exasol",
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
