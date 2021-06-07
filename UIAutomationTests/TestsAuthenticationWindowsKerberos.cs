using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using Xunit;

namespace UIAutomationTests
{
    [Collection("VisualStudioUIAutomationTestCollection")]
    public class TestsAuthenticationWindowsKerberos
    {
        UIAutomationTestFixture testFixture;
        public TestsAuthenticationWindowsKerberos(UIAutomationTestFixture tf)
        {
            testFixture = tf;
        }
        //This is a unit test where we'll check if the OdbcConnection record that gets passed on to the Odbc Query or Datasource function is correct.
        [Fact]
        public void TestWindowsKerberosAuthenticationConnectionStringRecord()
        {
            var (sbPqFileStr, dnsRecord) = CreateKerberosConnectionStringPqTestFile();

            var (error, grid) = testFixture.Test(sbPqFileStr, UIAutomationTestFixture.AuthenticationMethod.None);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");

            string connectionStrKerberosServicenameField = "KERBEROSSERVICENAME";
            //assert there's a row with a Kerberos service record field
            int? kerberosServiceNameRecordRow = Utilities.FindRow(grid, 0, connectionStrKerberosServicenameField);
            Assert.True(kerberosServiceNameRecordRow.HasValue, "KERBEROSSERVICENAME is missing from the Connection String Record.");
            Assert.True(grid.Rows[kerberosServiceNameRecordRow.Value].Cells[1].Value == "exasol/" + dnsRecord);
        }
        //another test with different authentication mode spoof here to make sure KERBEROSSERVICENAME is not included in the Connection String Record 
        [Fact]
        public void TestWindowsKerberosAuthenticationConnectionStringRecordWithKeyCredentialsSpoof()
        {
            var (sbPqFileStr, dnsRecord) = CreateKerberosConnectionStringPqTestFile(Utilities.ComposeMashupFiles.SpoofCredentials.Key);

            var (error, grid) = testFixture.Test(sbPqFileStr, UIAutomationTestFixture.AuthenticationMethod.None);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");

            string connectionStrKerberosServicenameField = "KERBEROSSERVICENAME";

            int? kerberosServiceNameRecordRow = Utilities.FindRow(grid, 0, connectionStrKerberosServicenameField);
            Assert.True(!kerberosServiceNameRecordRow.HasValue, "KERBEROSSERVICENAME shouldn't be a part of this record.");
        }

        private (string, string) CreateKerberosConnectionStringPqTestFile(Utilities.ComposeMashupFiles.SpoofCredentials spoofCredentials = Utilities.ComposeMashupFiles.SpoofCredentials.Windows)
        {
            int pqFileNumberOfCharacters = 20000;
            StringBuilder queryPqFileSB = new StringBuilder(pqFileNumberOfCharacters);

            var pqFilePath = Utilities.GetConfigurationValue("pqPath");
            var pqFileContentsStr = File.ReadAllText(pqFilePath);

            queryPqFileSB.Append(Utilities.ComposeMashupFiles.LetStatement);
            queryPqFileSB.Append(Utilities.ComposeMashupFiles.GetMashupCodeBlock("CreateOdbcConnectionStringRecord", pqFileContentsStr));
            queryPqFileSB.Append(Utilities.ComposeMashupFiles.CommaAndNewLine);
            queryPqFileSB.Append(Utilities.ComposeMashupFiles.GetMashupCodeBlock("AppendOdbcConnectionStringForKerberosAuthentication", pqFileContentsStr));
            queryPqFileSB.Append(Utilities.ComposeMashupFiles.CommaAndNewLine);

            var mainFunction = Utilities.ComposeMashupFiles.GetMashupCodeBlock("ExasolImpl", pqFileContentsStr);
            //we spoof the current credentials record
            mainFunction = Utilities.ComposeMashupFiles.SpoofCurrentCredentialsRecord(mainFunction, spoofCredentials);
            //we change the returned object to the connection string object we usually pass along to the datasource or query function to see how it looks
            mainFunction = Utilities.ComposeMashupFiles.ReplaceMashupFunctionOutput(mainFunction, "appendedOdbcConnectionString");
            queryPqFileSB.Append(mainFunction);
            queryPqFileSB.Append(Utilities.ComposeMashupFiles.CommaAndNewLine);
            string dnsRecord = "exasoldb.example.com";
            //the function needs to get called
            queryPqFileSB.Append($@"result = ExasolImpl(""{dnsRecord}"", ""Yes"")
            in result");

            return (queryPqFileSB.ToString(), dnsRecord);
        }
    }
}
