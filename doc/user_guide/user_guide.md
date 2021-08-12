# Exasol Power BI Connector 1.0.6 Release - User Guide

## New features

- DSN (Data Source Name) Support

- Limited Kerberos support

## Installing the connector:

This new version of the connector comes bundled with the September 2021 release of Power BI Desktop scheduled the week of 9/13.

## DSN (Data Source Name) Support

Next to connection strings the new version of the connector now also supports Data Source Names (DSNs). 

This way you can also use preconfigured data sources.

There are many applications of this feature ( e.g: logging, debugging, advanced authentication scenarios. )

### Creating a datasource

You can create and edit datasources in the 'ODBC Data sources' app available on Windows

![](./img/2021-07-16-13-58-16-image.png)

Let's look at a simple example:

Let's create a simple data source

![](./img/2021-07-16-14-03-38-image.png)

Let's call it "exa-test" and use the simplest connection string we can

![](./img/2021-07-16-14-06-10-image.png)

(You have an option to test the connection here to make sure it works. You might need to provide credentials but you can remove these after the test if you wish.) 

### Using the data source name in the connector

Write DSN=<your-data-source-name> as the connection string and press OK.

![](./img/2021-07-16-14-16-08-image.png)

Depending on whether you've provided credentials or not in your connection string you then pick one of the available authentication options and you should be succesfully connected.

#### Use case: ODBC Driver Logs

You can easily enable and disable ODBC driver logging using the data source options:

Navigate to the 'ODBC data sources' application.

Select your data source, click the "advanced" tab.

![](./img/2021-07-16-15-55-16-image.png)

You can easily turn logging on and off as well as select a desired log mode using the "Log file and "Log mode" fields.

Another option to do this is to manually add the relevant connection string keys to the connection string or to add them to Additional Connection string parameters under 'Advanced'.

In this case that would be: `LOGMODE=DEBUGCOMM;EXALOGFILE=C:\tmp\pbiblog.txt`;



#### Use case: Advanced Kerberos scenarios

In case the default built in Kerberos option isn't enough you can use a DSN and append KERBEROSHOSTNAME and KERBEROSSERVICENAME connection string keys and values to the connectionstring.

#### More information

There is also more documentation on exasol ODBC datasources configuration available here: [ODBC Driver for Windows | Exasol Documentation](https://docs.exasol.com/connect_exasol/drivers/odbc/odbc_windows.htm)

For an overview of the other available connection string keys, see this article:

[Using the ODBC Driver | Exasol Documentation](https://docs.exasol.com/connect_exasol/drivers/odbc/using_odbc.htm)

# Limited Kerberos support

We also support an 'easy' kerberos authentication mode where the `KERBEROSSERVICENAME` will be `exasol/<dnsrecord>` if you choose the kerberos authentication option.

If you need more control over this you can set the right values in the data source connection string instead (see data sources section above) and then opt for kerberos (if you use a DSN this will add no additional authentication connection string keys) or 'implicit' authentication.
