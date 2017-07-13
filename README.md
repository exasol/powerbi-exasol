# powerbi-exasol

The EXASOL Power BI Connector (Beta) is based on the new [DataConnectors framework from Microsoft](https://github.com/Microsoft/DataConnectors) and enables 
you to connect from Power BI Desktop to EXASOL in *Direct Query* mode (classical import mode is supported as well).

###### Please note that this is an open source project which is *not officially supported* by EXASOL. We will try to help you as much as possible, but can't guarantee anything since this is not an official EXASOL product.

## Prerequisites

* Install the [EXASOL ODBC driver (EXASOL_ODBC_*.msi)](https://www.exasol.com/portal/display/DOWNLOAD/6.0) (if you are not sure if you shall install the 32 Bit or 64 Bit version install both versions)
* Install the current version of Power BI desktop (the connector was testes with version Version: 2.48.4792.481 64-bit (July, 2017)) 

## Installation


1. Create a [My Documents]\Microsoft Power BI Desktop\Custom Connectors directory
2. Copy the EXASOL extension file  [exasol.mez](https://github.com/EXASOL/powerbi-exasol/blob/master/Exasol/bin/Release/Exasol.mez)  into this directory
3. Enable the **Custom data connectors preview feature** in Power BI Desktop (under File | Options and settings | Custom data connectors)
4. Restart Power BI Desktop
5. Exasol Connection is available in Get Data -> Databases -> Exasol
