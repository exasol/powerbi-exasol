using System;
using System.IO;
using Xunit;

namespace UIAutomationTests
{
    //https://xunit.net/docs/running-tests-in-parallel
    public class UnitTests : IClassFixture<TestFixture>
    {
        TestFixture testFixture;
        public UnitTests(TestFixture tf)
        {
            testFixture = tf;
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

    }
}
