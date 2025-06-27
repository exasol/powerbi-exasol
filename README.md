# Power BI - Exasol Connector
The Exasol Microsoft Power BI Connector enables you to connect from Power BI Desktop to Exasol in *Direct Query* mode (classical import mode is supported as well).

**The Exasol Microsoft Power BI Connector is a Certified Custom Connector now and is also shipped with Power BI desktop and the on premise data gateway. The powerbi-exasol repository will contain the latest release which might contain modifications not yet included in the stable version.**

## Prerequisites

* Install the latest [Exasol ODBC driver (EXASOL_ODBC_*.msi)](https://downloads.exasol.com/clients-and-drivers/odbc/) (if you aren't sure on whether you need the 32 Bit or 64 Bit version install both versions)
* Install the [Visual C++ Redistributable](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170)
* Install the current version of Power BI desktop

## Official Updates

:exclamation: A new version of the Exasol connector is scheduled for release during the week of November 9th 2024. 
The new connector will also begin to appear in Power BI Dataflows starting the week of October 28th 2024.
The main new feature is native query support. For a brief overview see the [custom queries ](#custom-queries) section.


## Usage

1. Choose  Get Data -> Database -> Exasol

![alt text](https://github.com/EXASOL/powerbi-exasol/blob/master/screenshots/Get_Data_Exasol.PNG )

2. Enter the Exasol connection string and choose Direct Query

![alt text](https://github.com/EXASOL/powerbi-exasol/blob/master/screenshots/Exasol_Connection_String.PNG )

3. Enter credentials

![alt text](https://github.com/EXASOL/powerbi-exasol/blob/master/screenshots/Enter_Credentials.PNG )

4. Select tables

![alt text](https://github.com/EXASOL/powerbi-exasol/blob/master/screenshots/Navigator.PNG )

5. Review relational model, it's recommended to have foreign keys set in the database so Power BI can autodetect the relations

![alt text](https://github.com/EXASOL/powerbi-exasol/blob/master/screenshots/PowerBI_RelationalModel.PNG )

6. Build fast dashboards on billions of rows in Exasol

![alt text](https://github.com/EXASOL/powerbi-exasol/blob/master/screenshots/Example_Dashboard_Billion_Rows.PNG )

## Using DSNs, enabling ODBC logging and Kerberos authentication

Please see the [user guide](doc/user_guide/user_guide.md)

## Custom queries

Custom queries using `Value.NativeQuery` are supported starting from connector version 1.1.0.

An example (using the Advanced Editor):
```mashup
let
    Source = Exasol.Database("<hostname,ip address or dsn>", "Yes"),
    CustomQuery = Value.NativeQuery( Source, "SELECT * FROM SCHEMANAME.TABLENAME")
in
    CustomQuery
```

General advice: Microsoft doesn’t recommend using SQL queries as the source of tables with Value.NativeQuery/[EnableFolding=true]. Turning these queries into views and referencing the views in your semantic model is probably the better move if possible.

## How To use the Exasol Power BI Connector with the On-premises data gateway

The Exasol connector was tested successfully with the On-premises data gateway version 3000.8.452 (August 2019) and also supports Direct Query. 

:exclamation: As the Exasol Connector is now shipped with the On-premises data gateway it is not necessary to install the Exasol.mez from this repository in the Custom Connectors folder of the Gateway. Actually the data gateway only works with the shipped connector from Microsoft. If you upgrade from older version versions of the On-Premises data gateway please delete the Exasol.mez from the custom connectors folder and restart the gateway service.

Also make sure you install the latest Exasol ODBC driver and Visual C++ Redistributable on the machine/VM where you install the data gateway, just as you would when you intend to use the connector for Power BI Desktop, for more information see section [Prerequisites](#prerequisites).

## Articles on Power BI + Exasol

[Working with Exasol geospatial data in Power BI](https://exasol.my.site.com/s/article/Working-with-Exasol-geospatial-data-in-Power-BI?language=en_US)

## FAQ / Frequent issues

### "OLE DB or ODBC error: [Expression.Error] We couldn’t fold the expression to the data source. Please try a simpler expression"

Please see: https://blog.crossjoin.co.uk/2022/05/08/understanding-the-we-couldnt-fold-the-expression-to-the-data-source-error-in-power-bi/

### Issues with TIMESTAMP WITH LOCAL TIME ZONE data type

This is PowerBI specific:
Types PowerBI can't make sense of or map implicitly get ‘delivered’ as ‘Type.Binary’ in PowerBI.

The easiest workaround in this case would be to create a view in the Exasol DB itself that contains all the columns you need and to convert this problematic ‘TIMESTAMP WITH LOCAL TIME ZONE' column to a calculated ‘TIMESTAMP' column that’s also part of the view. 

A 'TIMESTAMP’ column gets correctly read out by PowerBI.

The SQL command to create this view and do the conversion would look like this:
```sql
CREATE VIEW YOURSCHEMA.WORKAROUNDVIEW as select … , CONVERT( TIMESTAMP , TSLTZ) AS DTCONVERTED from YOURSCHEMA.YOURTABLE;
```
Where TSLTZ is the original ‘TIMESTAMP WITH LOCAL TIME ZONE' column and DTCONVERTED is the calculated & converted 'TIMESTAMP' column .

You can then query this view in PowerBI without any further conversion steps needed for the new timestamp column.

### "OLE DB or ODBC error: [Expression.Error] Local evaluation of Table.Join or Table.NestedJoin with key equality comparers is not supported"

Usually this issue is caused by a faulty DAX expression or an unexpected value being returned by a DAX expression. 

An example:

This issue can, for example, occur when using RLS in PowerBI. If the DAX expression for a certain role does not return a list of valid values, but instead returns a value like 'false' it might break the visuals and underlying query when filtering.

## Additional information

* [Changelog](doc/changes/changelog.md)
* [Developer guide](doc/developer_guide/developer_guide.md)
