using System;
using System.IO;
using Xunit;

namespace UIAutomationTests
{
    //https://xunit.net/docs/running-tests-in-parallel
    //We don't want to run them in parallel (since we're doing automation UI testing) so we add the tests to the same test collection
    [Collection("NotParallel")]
    public class UnitTestsUsernamePassword : IClassFixture<TestFixture>
    {
        TestFixture testFixture;
        public UnitTestsUsernamePassword(TestFixture tf)
        {
            testFixture = tf;
            tf.Authenticate(TestFixture.AuthenticationMethod.UsernamePassword);
        }
        [Fact]
        public void TestAW()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/ExasolAW.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            
            Assert.True(String.IsNullOrWhiteSpace(error),$@"Errormessage: {error}");
            Assert.True(grid.RowCount > 1, $@"actual rowCount is {grid.RowCount}");
        }
        [Fact]
        public void  Test1()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/Exasol.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            Assert.True(grid.RowCount == 1,$@"actual rowCount is {grid.RowCount}");
        }
        [Fact]
        public void TestAW2()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/ExasolAW.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            Assert.True(grid.RowCount > 1,$@"actual rowCount is {grid.RowCount}");
        }
        [Fact]
        public void TestSqlQueryLimit5()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/CustomQuery.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            Assert.True(grid.RowCount == 5 + 1, $@"actual rowCount is {grid.RowCount}");
        }

    }
}
