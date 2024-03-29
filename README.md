# Power BI - Exasol Connector
The Exasol Microsoft Power BI Connector enables you to connect from Power BI Desktop to Exasol in *Direct Query* mode (classical import mode is supported as well).

**The Exasol Microsoft Power BI Connector is a Certified Custom Connector now and is also shipped with Power BI desktop and the on premise data gateway. The powerbi-exasol repository will contain the latest release which might contain modifications not yet included in the stable version.**

## Prerequisites

* Install the [Exasol ODBC driver (EXASOL_ODBC_*.msi)](https://www.exasol.com/portal/display/DOWNLOAD/6.0) (if you aren't sure on whether you need the 32 Bit or 64 Bit version install both versions)
* Install the current version of Power BI desktop

## Official Updates

:exclamation: The Power BI Release 2.66.5376.1681 64-bit (February 2019) contains all recent fixes of the EXASOL connector regarding unicode.

:exclamation: A new version of the Exasol connector is scheduled for bundled release with PowerBI. 
This new version of the connector comes bundled with the September 2021 release of Power BI Desktop scheduled the week of 9/13.

For a brief overview of the new features coming in this release, see the [user guide](doc/user_guide/user_guide.md)


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


## How To use the Exasol Power BI Connector with the On-premises data gateway

The Exasol connector was tested successfully with the On-premises data gateway version 3000.8.452 (August 2019) and also supports Direct Query. 

:exclamation: As the Exasol Connector is now shipped with the On-premises data gateway it is not necessary to install the Exasol.mez from this repository in the Custom Connectos folder of the Gateway. Actually the data gateway only works with the shipped connector from Microsoft. If you upgrade from older version versions of the On-Premises data gateway please delete the Exasol.mez from the custom connectors folder and restart the gateway service.



