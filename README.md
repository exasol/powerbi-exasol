# Power BI - Exasol Connector
The Exasol Microsoft Power BI Connector enables you to connect from Power BI Desktop to Exasol in *Direct Query* mode (classical import mode is supported as well).

**The Exasol Microsoft Power BI Connector is a Certified Custom Connector now and is also shipped with Power BI desktop. The powerbi-exasol repository will contain the latest release which might contain modifications not yet included in the stable version.**

## Prerequisites

* Install the [Exasol ODBC driver (EXASOL_ODBC_*.msi)](https://www.exasol.com/portal/display/DOWNLOAD/6.0) (if you are not sure if you shall install the 32 Bit or 64 Bit version install both versions)
* Install the current version of Power BI desktop

## Use the Custom Connector from this Repository instead of the official shipped connector in Power BI Desktop

:exclamation:  The current version of the Exasol connector in this repository contains some major fixes for unicode.
If you face issues with únicode characters, you can install the newest connector as described below:

If you want to use the most current connector provided in this repository to be able to use the newest connector available, before the
next official release of Power BI, please us the following instructions:

* Download [Exasol.mez](https://github.com/EXASOL/powerbi-exasol/blob/master/Exasol/bin/Release/Exasol.mez) 
* Create A directory like  [Documents]\Power BI Desktop\Custom Connectors
* Copy Exasol.mez into the [Documents]\Power BI Desktop\Custom Connectors directory
* Open Power BI Desktop and  lower the security level for extensions in Power BI Desktop to enable loading unsigned/uncertified connectors.
* Go to File | Options and settings | Options
* Go the Security tab
* Under Data Extensions, select Allow any extension to load without warning or validation
* Restart Power BI Desktop
* Now Power BI uses the Custom Connector for Exasol instead of the official included connector

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

The Exasol connector was tested successfully with the On-premises data gateway version 14.16.6808.1 (September 2018) and also supports Direct Query.

1. Install and configure the On-premises data gateway (https://powerbi.microsoft.com/en-us/gateway/ )

2. Copy the [exasol.mez](https://github.com/EXASOL/powerbi-exasol/blob/master/Exasol/bin/Release/Exasol.mez) file to e.g. C:\Users\PBIEgwService\Documents\Power BI Desktop\Custom Connectors

3. The Exasol connector will now be listed in the Connectors section of the On-premises data gateway GUI

![alt text](https://github.com/EXASOL/powerbi-exasol/blob/master/screenshots/OnPremisesDataGatewayListExasolConnector.PNG )

4. Go now to powerbi.com to create a new Exasol connection for this Gateway:

Allow custom connectors in your gateway
![alt text](https://github.com/EXASOL/powerbi-exasol/blob/master/screenshots/GatewayAllowCustomDataConnectors.PNG )

Create the Exasol Connection (Type Yes for Encryption)
![alt text](https://github.com/EXASOL/powerbi-exasol/blob/master/screenshots/ExasolOnPremiseGatewayConnection.PNG )

5. Now you are ready to go to publish your workbooks to powerbi.com from from Power BI Desktop. When connecting to Exasol from Power BI desktop use the exact same settings (Connection-String / Encrpytion Setting / User Credentials). When the workbook is published the connection of the gateway is then associated with this workbook.

![alt text](https://github.com/EXASOL/powerbi-exasol/blob/master/screenshots/ExasolOnPremisePublishedWorkbookDirectQuery.PNG )


