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
        public async void TestAW()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/ExasolAW.query.pq");

            var resultGrid = await testFixture.RunTest(MQueryExpression);
            Assert.True(resultGrid.RowCount > 1, $@"actual rowCount is {resultGrid.RowCount}");
        }
        [Fact]
        public async void  Test1()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/Exasol.query.pq");

            var resultGrid = await testFixture.RunTest(MQueryExpression);
            Assert.True(resultGrid.RowCount == 1,$@"actual rowCount is {resultGrid.RowCount}");
        }
        [Fact]
        public async void TestAW2()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/ExasolAW.query.pq");

            var resultGrid = await testFixture.RunTest(MQueryExpression);
            Assert.True(resultGrid.RowCount > 1,$@"actual rowCount is {resultGrid.RowCount}");
        }

    }
}