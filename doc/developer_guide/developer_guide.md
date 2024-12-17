# Developer guide

## SDKs

### PowerQuery SDK for Visual Studio 2019

DEPRECATED ( https://github.com/microsoft/DataConnectors)

Please use PowerQuery SDK for Visual Studio Code instead

### PowerQuery SDK for Visual Studio Code

Install extension via VS code 

Repo of SDK + issues section: 
https://github.com/microsoft/vscode-powerquery-sdk 

### Develop a connector using the PowerQuery SDK for Visual Studio Code

https://learn.microsoft.com/en-us/power-query/install-sdk

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

## Submission for certification

The Connector Certification portal will be decommissioned by the end of this calendar year (https://connectorcertification.azurewebsites.net/). Effective December 16, 2024, all connector certification submissions should be made via email to dataconnectors@microsoft.com.

## Microsoft Support

### Official Support

https://admin.powerplatform.microsoft.com/support

### PowerQuery SDK board

https://github.com/microsoft/vscode-powerquery-sdk

 


