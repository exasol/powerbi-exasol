using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using Xunit;

namespace UIAutomationTests
{
    //for these tests you need to have a working DSN set up under ODBC data sources, the name is configurable for the tests in exa
    [Collection("VisualStudioUIAutomationTestCollection")]
    public class TestsDSN
    {
        UIAutomationTestFixture testFixture;

        string dsnName = Utilities.GetConfigurationValue("dsn-name");

        public TestsDSN(UIAutomationTestFixture tf)
        {
            testFixture = tf;
        }
        [Fact]
        public void TestDsn1()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/DSN/DSN1.query.pq");
            string changedDSNStr = MQueryExpression.Replace("{DSN}", dsnName);
            var (error, grid) = testFixture.Test(changedDSNStr);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
        }
        [Fact]
        public void TestDsn2()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/DSN/DSN2.query.pq");

            string changedDSNStr = MQueryExpression.Replace("{DSN}", dsnName);
            var (error, grid) = testFixture.Test(changedDSNStr);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
        }
        [Fact]
        public void TestDsn3()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/DSN/DSN3.query.pq");

            string changedDSNStr = MQueryExpression.Replace("{DSN}", dsnName);
            var (error, grid) = testFixture.Test(changedDSNStr);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
        }
        [Fact]
        public void TestDsn4()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/DSN/DSN4.query.pq");

            string changedDSNStr = MQueryExpression.Replace("{DSN}", dsnName);
            var (error, grid) = testFixture.Test(changedDSNStr);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
        }
        [Fact]
        public void TestDsn5()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/DSN/DSN5.query.pq");

            string changedDSNStr = MQueryExpression.Replace("{DSN}", dsnName);
            var (error, grid) = testFixture.Test(changedDSNStr);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
        }
        [Fact]
        public void TestDsn6()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/DSN/DSN6.query.pq");

            string changedDSNStr = MQueryExpression.Replace("{DSN}", dsnName);
            var (error, grid) = testFixture.Test(changedDSNStr);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
        }
    }
}
