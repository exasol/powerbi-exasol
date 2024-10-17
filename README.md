# Power BI - Exasol Connector
The Exasol Microsoft Power BI Connector enables you to connect from Power BI Desktop to Exasol in *Direct Query* mode (classical import mode is supported as well).

**The Exasol Microsoft Power BI Connector is a Certified Custom Connector now and is also shipped with Power BI desktop and the on premise data gateway. The powerbi-exasol repository will contain the latest release which might contain modifications not yet included in the stable version.**

## Prerequisites

* Install the latest [Exasol ODBC driver (EXASOL_ODBC_*.msi)](https://downloads.exasol.com/clients-and-drivers/odbc/) (if you aren't sure on whether you need the 32 Bit or 64 Bit version install both versions)
* Install the [Visual C++ Redistributable](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170)
* Install the current version of Power BI desktop

## Official Updates

:exclamation: A new version of the Exasol connector is scheduled for a release during the week of November 9th 2024. 
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

## Using DSNs and Kerberos authentication

Please see the [user guide](doc/user_guide/user_guide.md)

## Custom queries

Custom queries using `Value.NativeQuery` are supported starting from connector version 1.1.0.

An example (using the Advanced Editor):
```
let
    Source = Exasol.Database("<hostname,ip address or dsn>", "Yes"),
    CustomQuery = Value.NativeQuery( Source, "SELECT * FROM SCHEMANAME.TABLENAME")
in
    CustomQuery
```

## How To use the Exasol Power BI Connector with the On-premises data gateway

The Exasol connector was tested successfully with the On-premises data gateway version 3000.8.452 (August 2019) and also supports Direct Query. 

:exclamation: As the Exasol Connector is now shipped with the On-premises data gateway it is not necessary to install the Exasol.mez from this repository in the Custom Connectors folder of the Gateway. Actually the data gateway only works with the shipped connector from Microsoft. If you upgrade from older version versions of the On-Premises data gateway please delete the Exasol.mez from the custom connectors folder and restart the gateway service.

Also make sure you install the latest Exasol ODBC driver and Visual C++ Redistributable on the machine/VM where you install the data gateway, just as you would when you intend to use the connector for Power BI Desktop, for more information see section [Prerequisites](#prerequisites).


## Additional information

* [Changelog](doc/changes/changelog.md)

