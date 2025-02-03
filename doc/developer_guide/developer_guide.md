# Developer guide

## SDKs

### PowerQuery SDK for Visual Studio 2019

DEPRECATED ( https://github.com/microsoft/DataConnectors)

Please use PowerQuery SDK for Visual Studio Code instead (next section)

### PowerQuery SDK for Visual Studio Code

Install extension via VS code 

Repo of SDK + issues section: 
https://github.com/microsoft/vscode-powerquery-sdk 

### Connector "architecture" and fixes

The current connector overwrites the following ODBC Functions:

#### SQLColumns

- Map VARCHAR, CHAR to WVARCHAR type declared in SQLGetTypeInfo.  
Done as a fix for using slicers/filters with unicode characters.
- Map HASHTYPE to WVARCHAR type declared in SQLGetTypeInfo.  
Done as a fix because hashtype used to beseen as a Byte type instead of a text type. Might be obsolete now.
- Map from DECIMAL to BIGINT in the case of a 0 decimal digits.


#### SQLGetTypeInfo

- Add WCHAR and WVARCHAR types.  
PowerBI asks for these types explicitly when opening a report using the datasource.  
Also used as part of the workaround for slicers using and filtering on unicode characters.
- WVARCHAR type is the only type being mapped to currently.
- WVARCHAR type uses a VARCHAR type alias ("LONG VARCHAR") as its type name and local type name to fix an issue in some reports where it sometimes does a cast when pushing down a query.
#### SQLGetInfo

- Custom rules on casts via bytemasks, disables conversions since not supported in Exasol DB.

#### SqlCapabilities

- Sql92Translation = "PassThrough" : enables NativeQuery

### Develop a connector using the PowerQuery SDK for Visual Studio Code

https://learn.microsoft.com/en-us/power-query/install-sdk

#### "Power Query / M Language" extension

Dependency of PowerQuery SDK for Visual Studio Code
Provides M Language support.

#### Building 

Select Terminal > "Run build task ..." > And then pick one of 2 options
- "Build connector project using MakePQX (newer)
- "MSBuild" (legacy)

A .mez file will be created if all goes well.

#### Testing

TBC

#### Testing changes in PowerBI locally

You can install your newly created .mez file in:

C:\Users\<username>>\Documents\Power BI Desktop\Custom Connectors

You'll also need to enable some settings in PowerBI Desktop locally:
https://learn.microsoft.com/en-us/power-bi/connect-data/desktop-connector-extensibility#custom-connectors

If you go to Get Data > and look for Exasol you'll see 'Exasol (Custom)' if the extension's loaded correctly.


If you wish to run a custom version of the connector on the PowerBI service you'll also need to put the connector in place for the On-Prem Data Gateway.

## Submission for certification / reporting issues with data connector.

"The Connector Certification portal will be decommissioned by the end of this calendar year (https://connectorcertification.azurewebsites.net/). Effective December 16, 2024, all connector certification submissions should be made via email to dataconnectors@microsoft.com."

### PowerQuery SDK board

https://github.com/microsoft/vscode-powerquery-sdk

### Tools 

#### ODBC QueryTool :  
Analyses an active ODBC data source connection  (needs a DSN)
Brought to you by: edohuisman  
Found here: https://sourceforge.net/projects/odbcquerytool/

#### ODBC Test
Microsoft ODBC Test is an ODBC-enabled application that you can use to test ODBC drivers and the ODBC Driver Manager. ODBC Test is included as part of the Microsoft Data Access Components (MDAC) 2.8 Software Development Kit.  
Found here: https://www.microsoft.com/en-us/download/details.aspx?id=21995

### Helpful queries

select * 
from 
EXA_DBA_AUDIT_SQL where trunc(START_TIME) = current_date

you can run FLUSH Statistics; before

### Understanding Mashup language

each keyword :
The each keyword is used to easily create simple functions. “each …” is syntactic sugar for a function signature that takes the _ parameter “(_) => …”
- source Microsoft
 https://henrikmassow.medium.com/the-strange-each-and-in-power-query-f230afc4b341

### On ODBC

#### SQLColumns
The SQLColumns function in ODBC is used to retrieve metadata about columns in a database table. When this function is called, it returns a result set with detailed information about the columns in the specified table.

Columns of SQLColumns Result Set:
| Column Name         | Data Type  | Description |
|---------------------|-----------|-------------|
| TABLE_CAT          | VARCHAR   | The catalog name of the table. Null if the data source does not support catalogs. |
| TABLE_SCHEM        | VARCHAR   | The schema name of the table. Null if the data source does not support schemas. |
| TABLE_NAME         | VARCHAR   | The name of the table containing the column. |
| COLUMN_NAME        | VARCHAR   | The name of the column. |
| DATA_TYPE         | SMALLINT  | The SQL data type of the column (driver-independent SQL data type, e.g., SQL_VARCHAR, SQL_INTEGER). |
| TYPE_NAME         | VARCHAR   | The database-specific data type name (e.g., VARCHAR, INT). |
| COLUMN_SIZE       | INTEGER   | The size of the column (e.g., maximum length for character or binary data, precision for numeric data). |
| BUFFER_LENGTH     | INTEGER   | The recommended buffer size to retrieve the column's data. |
| DECIMAL_DIGITS    | SMALLINT  | The number of digits to the right of the decimal point for numeric data types. Null if not applicable. |
| NUM_PREC_RADIX    | SMALLINT  | The numeric precision radix: 10 for decimal/float types, 2 for binary types, null if not applicable. |
| NULLABLE          | SMALLINT  | Indicates whether the column allows NULL: 0 = No, 1 = Yes, 2 = Unknown. |
| REMARKS          | VARCHAR   | Any descriptive information or comments about the column. |
| COLUMN_DEF        | VARCHAR   | The default value of the column, if any. Null if there is no default value. |
| SQL_DATA_TYPE     | SMALLINT  | The SQL data type as defined in the SQL standard. Often the same as DATA_TYPE. |
| SQL_DATETIME_SUB  | SMALLINT  | For datetime data types, provides subcodes for finer granularity (e.g., SQL_CODE_DATE, SQL_CODE_TIMESTAMP). |
| CHAR_OCTET_LENGTH | INTEGER   | The maximum length in bytes of the column's data. Null for non-character types. |
| ORDINAL_POSITION  | INTEGER   | The 1-based position of the column in the table. |
| IS_NULLABLE       | VARCHAR   | Indicates nullability as a string: 'YES', 'NO', or null (unknown). |

#### SQLGetTypeInfo
The SQLGetTypeInfo function in ODBC retrieves metadata about the data types supported by the data source (database and driver). It returns a result set with detailed information about each supported data type.

Columns of SQLGetTypeInfo Result Set
Below is a table listing the columns returned by the SQLGetTypeInfo result set, along with their descriptions:

| Column Name          | Data Type  | Description |
|----------------------|-----------|-------------|
| TYPE_NAME           | VARCHAR   | The database-specific name of the data type (e.g., VARCHAR, INT, DATE). |
| DATA_TYPE           | SMALLINT  | The driver-independent SQL datatype identifier (e.g., SQL_VARCHAR, SQL_INTEGER). |
| COLUMN_SIZE         | INTEGER   | The maximum size of the data type. For strings, it's the maximum length in characters; for numeric types, it's precision. |
| LITERAL_PREFIX      | VARCHAR   | The prefix for literal values of the data type (e.g., ' for character strings, NULL for none). |
| LITERAL_SUFFIX      | VARCHAR   | The suffix for literal values of the data type (e.g., ' for character strings, NULL for none). |
| CREATE_PARAMS       | VARCHAR   | Parameters required to define the data type in a CREATE TABLE statement (e.g., length, precision, scale). |
| NULLABLE           | SMALLINT  | Indicates whether the data type allows NULL values: 0 = No, 1 = Yes, 2 = Unknown. |
| CASE_SENSITIVE     | SMALLINT  | Indicates whether the data type is case-sensitive: 0 = No, 1 = Yes. |
| SEARCHABLE         | SMALLINT  | Indicates how the data type can be used in a WHERE clause. |
| UNSIGNED_ATTRIBUTE | SMALLINT  | For numeric data types, indicates if the type is unsigned: 0 = No, 1 = Yes, NULL = Not applicable. |
| FIXED_PREC_SCALE   | SMALLINT  | Indicates if the data type has a fixed precision and scale: 0 = No, 1 = Yes. |
| AUTO_UNIQUE_VALUE  | SMALLINT  | Indicates if the data type can be an auto-increment value: 0 = No, 1 = Yes. |
| LOCAL_TYPE_NAME    | VARCHAR   | A localized name for the data type (e.g., user-friendly display name). |
| MINIMUM_SCALE      | SMALLINT  | The minimum scale for numeric types. NULL if not applicable. |
| MAXIMUM_SCALE      | SMALLINT  | The maximum scale for numeric types. NULL if not applicable. |
| SQL_DATA_TYPE      | SMALLINT  | The SQL data type as defined in the SQL standard. Often the same as DATA_TYPE. |
| SQL_DATETIME_SUB   | SMALLINT  | For datetime data types, provides subcodes for finer granularity (e.g., SQL_CODE_DATE, SQL_CODE_TIME). |
| NUM_PREC_RADIX     | INTEGER   | The radix (base) for numeric data types. Typically 10 for decimals or 2 for binary types. |
| INTERVAL_PRECISION | INTEGER   | Precision of interval types (e.g., number of digits for years, months, etc.). NULL if not applicable. |

| SEARCHABLE                        |
|-----------------------------------|
|- 0: Not searchable                |
|- 1: Only with =                   |
|- 2: Searchable except with LIKE   |
|- 3: Fully searchable              |


#### driver-independent SQL datatype identifiers
Here’s a comprehensive list of all driver-independent SQL datatype identifiers defined by ODBC. These identifiers are constants used in ODBC functions (e.g., SQLBindCol, SQLGetTypeInfo) to represent standard data types in a database-independent manner.

##### Numeric Data Types
| Identifier      | Value | Description |
|----------------|-------|-------------|
| SQL_BIT        | -7    | Boolean (0 or 1). |
| SQL_TINYINT    | -6    | 8-bit integer. |
| SQL_SMALLINT   | 5     | 16-bit integer. |
| SQL_INTEGER    | 4     | 32-bit integer. |
| SQL_BIGINT     | -5    | 64-bit integer. |
| SQL_DECIMAL    | 3     | Fixed precision and scale numeric value. |
| SQL_NUMERIC    | 2     | Arbitrary precision numeric value. |
| SQL_REAL       | 7     | Single-precision floating-point value. |
| SQL_FLOAT      | 6     | Approximate numeric value (single or double precision). |
| SQL_DOUBLE     | 8     | Double-precision floating-point value. |

##### Character/String Data Types
| Identifier       | Value | Description |
|-----------------|-------|-------------|
| SQL_CHAR        | 1     | Fixed-length character string. |
| SQL_VARCHAR     | 12    | Variable-length character string. |
| SQL_LONGVARCHAR | -1    | Variable-length character string for large text. |
| SQL_WCHAR       | -8    | Fixed-length wide character (Unicode) string. |
| SQL_WVARCHAR    | -9    | Variable-length wide character (Unicode) string. |
| SQL_WLONGVARCHAR | -10  | Large variable-length wide character (Unicode) string. |

##### Binary Data Types
| Identifier        | Value | Description |
|------------------|-------|-------------|
| SQL_BINARY       | -2    | Fixed-length binary data. |
| SQL_VARBINARY    | -3    | Variable-length binary data. |
| SQL_LONGVARBINARY | -4   | Large variable-length binary data. |

##### Date and Time Data Types
| Identifier     | Value | Description |
|---------------|-------|-------------|
| SQL_DATE      | 9     | Date value (year, month, day). |
| SQL_TIME      | 10    | Time value (hour, minute, second). |
| SQL_TIMESTAMP | 11    | Timestamp value (date and time). |

##### Special Data Types
| Identifier                        | Value | Description |
|------------------------------------|-------|-------------|
| SQL_INTERVAL_YEAR                 | 101   | Interval type for years. |
| SQL_INTERVAL_MONTH                | 102   | Interval type for months. |
| SQL_INTERVAL_DAY                  | 103   | Interval type for days. |
| SQL_INTERVAL_HOUR                 | 104   | Interval type for hours. |
| SQL_INTERVAL_MINUTE               | 105   | Interval type for minutes. |
| SQL_INTERVAL_SECOND               | 106   | Interval type for seconds. |
| SQL_INTERVAL_YEAR_TO_MONTH        | 107   | Combined year-month interval. |
| SQL_INTERVAL_DAY_TO_HOUR          | 108   | Combined day-hour interval. |
| SQL_INTERVAL_DAY_TO_MINUTE        | 109   | Combined day-minute interval. |
| SQL_INTERVAL_DAY_TO_SECOND        | 110   | Combined day-second interval. |
| SQL_INTERVAL_HOUR_TO_MINUTE       | 111   | Combined hour-minute interval. |
| SQL_INTERVAL_HOUR_TO_SECOND       | 112   | Combined hour-second interval. |
| SQL_INTERVAL_MINUTE_TO_SECOND     | 113   | Combined minute-second interval. |
| SQL_GUID                          | -11   | Globally unique identifier (UUID). |


#### Exasol SQLGetTypeInfo results
Results of running SQLGetTypeInfo using the Windows Data Access Components SDK' ODBC test tool.

Get Data All:
| TYPE_NAME                              | DATA_TYPE | COLUMN_SIZE | LITERAL_PREFIX | LITERAL_SUFFIX | CREATE_PARAMS       | NULLABLE | CASE_SENSITIVE | SEARCHABLE | UNSIGNED_ATTRIBUTE | FIXED_PREC_SCALE | AUTO_UNIQUE_VALUE | LOCAL_TYPE_NAME                         | MINIMUM_SCALE | MAXIMUM_SCALE | SQL_DATA_TYPE | SQL_DATETIME_SUB | NUM_PREC_RADIX | INTERVAL_PRECISION |
|----------------------------------------|-----------|-------------|----------------|----------------|----------------------|----------|---------------|------------|-------------------|----------------|-----------------|--------------------------------------|--------------|--------------|--------------|----------------|--------------|-----------------|
| INTERVAL DAY TO SECOND                 | -104      | 16          | '              | '              | <Null>               | 1        | 0             | 3          | 0                 | 0              | <Null>          | INTERVAL DAY TO SECOND               | 0            | 9            | -104         | 10             | 10           | 9               |
| INTERVAL YEAR TO MONTH                 | -103      | 6           | '              | '              | <Null>               | 1        | 0             | 3          | 0                 | 0              | <Null>          | INTERVAL YEAR TO MONTH               | 0            | 9            | -103         | 7              | 10           | 9               |
| BOOLEAN                                | -7        | 1           | <Null>         | <Null>         | <Null>               | 1        | 0             | 3          | 0                 | 0              | <Null>          | BOOLEAN                               | <Null>       | <Null>       | -7           | <Null>         | 10           | <Null>          |
| TINYINT                                | -6        | 3           | <Null>         | <Null>         | <Null>               | 1        | 0             | 3          | 0                 | 1              | 0               | TINYINT                               | <Null>       | <Null>       | 5            | <Null>         | 10           | <Null>          |
| BIGINT                                 | -5        | 36          | <Null>         | <Null>         | <Null>               | 1        | 0             | 3          | 0                 | 1              | 0               | BIGINT                                | <Null>       | <Null>       | 5            | <Null>         | 10           | <Null>          |
| LONG VARCHAR                           | -1        | 2000000     | '              | '              | <Null>               | 1        | 1             | 3          | <Null>            | 0              | <Null>          | LONG VARCHAR                          | <Null>       | <Null>       | -1           | <Null>         | <Null>       | <Null>          |
| CHAR                                   | 1         | 2000        | '              | '              | max length           | 1        | 1             | 3          | <Null>            | 0              | <Null>          | CHAR                                  | <Null>       | <Null>       | 1            | <Null>         | <Null>       | <Null>          |
| HASHTYPE                               | 1         | 2048        | '              | '              | <Null>               | 1        | 0             | 3          | <Null>            | 0              | <Null>          | HASHTYPE                              | <Null>       | <Null>       | 1            | <Null>         | <Null>       | <Null>          |
| DECIMAL                                | 3         | 36          | <Null>         | <Null>         | precision,scale      | 1        | 0             | 3          | 0                 | 1              | 0               | DECIMAL                               | 0            | 36           | 3            | <Null>         | 10           | <Null>          |
| INTEGER                                | 4         | 18          | <Null>         | <Null>         | <Null>               | 1        | 0             | 3          | 0                 | 1              | 0               | INTEGER                               | <Null>       | <Null>       | 4            | <Null>         | 10           | <Null>          |
| SMALLINT                               | 5         | 9           | <Null>         | <Null>         | <Null>               | 1        | 0             | 3          | 0                 | 1              | 0               | SMALLINT                              | <Null>       | <Null>       | 5            | <Null>         | 10           | <Null>          |
| FLOAT                                  | 6         | 64          | <Null>         | <Null>         | <Null>               | 1        | 0             | 3          | 0                 | 0              | 0               | FLOAT                                 | <Null>       | <Null>       | 6            | <Null>         | 2            | <Null>          |
| DOUBLE PRECISION                       | 8         | 64          | <Null>         | <Null>         | <Null>               | 1        | 0             | 3          | 0                 | 0              | 0               | DOUBLE PRECISION                      | <Null>       | <Null>       | 8            | <Null>         | 2            | <Null>          |
| VARCHAR                                | 12        | 2000000     | '              | '              | max length           | 1        | 1             | 3          | <Null>            | 0              | <Null>          | VARCHAR                               | <Null>       | <Null>       | 12           | <Null>         | <Null>       | <Null>          |
| DATE                                   | 91        | 10          | '              | '              | <Null>               | 1        | 0             | 3          | <Null>            | 0              | <Null>          | DATE                                  | <Null>       | <Null>       | 9            | 1              | <Null>       | <Null>          |
| TIMESTAMP                              | 93        | 29          | '              | '              | <Null>               | 1        | 0             | 3          | <Null>            | 0              | <Null>          | TIMESTAMP                             | 0            | 9            | 9            | 3              | <Null>       | <Null>          |
| GEOMETRY                               | 123       | 2000000     | '              | '              | <Null>               | 1        | 0             | 3          | <Null>            | 0              | <Null>          | GEOMETRY                              | <Null>       | <Null>       | 12           | <Null>         | <Null>       | <Null>          |
| TIMESTAMP WITH LOCAL TIME ZONE         | 124       | 29          | '              | '              | <Null>               | 1        | 0             | 3          | <Null>            | 0              | <Null>          | TIMESTAMP WITH LOCAL TIME ZONE        | 0            | 9            | 9            | 3              | <Null>       | <Null>          |

18 rows fetched from 19 columns.

