using System;
using System.IO;
using Xunit;

namespace UIAutomationTests
{
    //https://xunit.net/docs/running-tests-in-parallel
    //We don't want to run them in parallel (since we're doing automation UI testing) so we add the tests to the same test collection
    [Collection("VisualStudioUIAutomationTestCollection")]
    public class TestsAuthenticationUsernamePassword
    {
        UIAutomationTestFixture testFixture;

        public TestsAuthenticationUsernamePassword(UIAutomationTestFixture tf)
        {
            testFixture = tf;
        }

        //2 tests here will be sufficient for now since we just want to see if we can authenticate and fetch data with odbc.datasource and odbc.query
        [Fact]
        public void TestOdbcQueryAuthenticationUsernamePassword()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/CustomQuery.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            Assert.True(grid.RowCount == 5 + 1, $@"actual rowCount is {grid.RowCount}");
        }
        [Fact]
        public void TestOdbcDatasourceAuthenticationUsernamePassword()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/ExasolAW.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);


            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            Assert.True(grid.RowCount > 1, $@"actual rowCount is {grid.RowCount}");
        }
    }

}
