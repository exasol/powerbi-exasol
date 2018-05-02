# Powerbi-Exasol Connector
The Exasol Microsoft Power BI Connector enables you to connect from Power BI Desktop to Exasol in *Direct Query* mode (classical import mode is supported as well).

**The Exasol Microsoft Power BI Connector is a Certified Custom Connector now. Therefore, you'll find the stable version in the [Microsoft Custom Connector Gallery](https://github.com/Microsoft/CustomConnectorGallery). The powerbi-exasol repository will contain the latest beta release which might contain modifications not yet included in the stable version.**

For installation you can watch the following How-To on Youtube:

[![Alt text](https://img.youtube.com/vi/izR8RRQ2vSs/0.jpg)](https://www.youtube.com/watch?v=izR8RRQ2vSs)


## Prerequisites

* Install the [Exasol ODBC driver (EXASOL_ODBC_*.msi)](https://www.exasol.com/portal/display/DOWNLOAD/6.0) (if you are not sure if you shall install the 32 Bit or 64 Bit version install both versions)
* Install the current version of Power BI desktop (the connector was tested with version Version: 2.48.4792.481 64-bit (July, 2017)) 

## Installation


1. Create a [My Documents]\Microsoft Power BI Desktop\Custom Connectors directory, e.g. `C:\Users\username\Documents\Microsoft Power BI Desktop\Custom Connectors\`

2. Copy the Exasol extension file  [exasol.mez](https://github.com/EXASOL/powerbi-exasol/blob/master/Exasol/bin/Release/Exasol.mez)  into this directory
3. Enable the **Custom data connectors preview feature** in Power BI Desktop (under File | Options and settings | Options | Preview features | Custom data connectors)
4. Restart Power BI Desktop
5. Exasol Connection is available in Get Data -> Database -> Exasol


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

