//Use this file to write queries to test your data connector
//local exasol VM TEST SCHEMA
let
    Server = "192.168.56.101:8563",
    queryResult = Exasol.Database(Server,"Yes", "select * from [ADVENTUREWORKSDW2014].[DimProduct] LIMIT 5 ;")//,
    //myDb = Source,
    //mySchema =  Source{[Name = "ADVENTUREWORKSDW2014",Kind="Schema"]}[Data]
in
    queryResult

//


//  let
//      Server = "192.168.56.101:8563",
//      ConnectionString = [
//     DRIVER = "EXASolution Driver",
//     EXAHOST = Server,
//     ENCRYPTION = "Y"//_encrypt
// //,LOGMODE = "DEFAULT"
// //,EXALOGFILE = "C:\tmp\odbclogfilepowerbi.txt"
// ],
//      res = Odbc.Query(ConnectionString,"select * from [ADVENTUREWORKSDW2014].[DimProduct] LIMIT 5 ;")
//      //myDb = Source,
// 
//      //mySchema =  Source{[Name = "ADVENTUREWORKSDW2014",Kind="Schema"]}[Data]
//  in
//      res
// 
//"Native queries aren't supported by this value"
// let
//      Server = "192.168.56.101:8563",
//      Source = Exasol.Database(Server,"Yes"),
//     Test = Value.NativeQuery(
//             Source, 
//             "SELECT * FROM DimDate 
//             WHERE EnglishMonthName=@MonthName 
//             AND
//             EnglishDayNameOfWeek=@DayName", 
//             [MonthName="March", DayName="Tuesday"])
// in
//     Test


// //leave this for now
// let
//      //Server = "192.168.56.101:8563",
//      ConnectionString = "DSN=exa_test;DRIVER={EXASolution Driver};EXAHOST=192.168.56.101:8563;EXASCHEMA=TEST",
//     Test = Odbc.Query(
//             ConnectionString,
//             "SELECT * FROM DimDate 
//             WHERE EnglishMonthName=@MonthName 
//             AND
//             EnglishDayNameOfWeek=@DayName")
// in
//     Test


//DSN=exa_test;UID=sys;PWD=exasol;EXASCHEMA=MY_SCHEMA
//			DRIVER={EXASolution Driver};EXAHOST=192.168.6.11..14:8563;UID=sys;PWD=exasol
//
//

// let
//      Server = "192.168.56.101:8563",
//      Source = Exasol.Database(Server,"Yes"),
//     Test = Value.NativeQuery(
//             Source, 
//             "SELECT * FROM DimDate 
//             WHERE EnglishMonthName=@MonthName 
//             AND
//             EnglishDayNameOfWeek=@DayName", 
//             [MonthName="March", DayName="Tuesday"])
// in
//     Test

// 
// let
//      Server = "192.168.56.101:8563",
//      Source = Exasol.Database(Server,"Yes"),
//     Test = Value.NativeQuery(
//             Source, 
//             "SELECT * FROM DimDate 
//             WHERE EnglishMonthName=@MonthName 
//             AND
//             EnglishDayNameOfWeek=@DayName", 
//             [MonthName="March", DayName="Tuesday"])
// in
//     Test