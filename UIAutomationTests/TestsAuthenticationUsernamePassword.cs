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
