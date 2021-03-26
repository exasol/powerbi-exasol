using System;
using System.IO;
using Xunit;

namespace UIAutomationTests
{
    //https://xunit.net/docs/running-tests-in-parallel
    //We don't want to run them in parallel (since we're doing automation UI testing) so we add the tests to the same test collection
    [Collection("VisualStudioUIAutomationTestCollection")]
    public class TestsUsernamePassword
    {
        TestFixture testFixture;
        public TestsUsernamePassword(TestFixture tf)
        {
            testFixture = tf;
        }
        //metadata test - exasol odbc.datasource metadata overview
        //should show all custom populated schemas within EXA_DB
        [Fact]
        public void OdbcDatasourceOverview()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/ExasolODBCDatasourceOverview.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);


            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            Assert.True(grid.RowCount > 1, $@"actual rowCount is {grid.RowCount}");
            var firstRow = grid.Rows[0];
            var kindCell = firstRow.Cells[3];
            Assert.True(kindCell.Value == "Schema");
        }
        //metadata test - adventure works (populated schema)
        [Fact]
        public void OdbcDatasourcePopulatedSchemaAdventureWorksRows()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/ExasolAW.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            
            Assert.True(String.IsNullOrWhiteSpace(error),$@"Errormessage: {error}");
            Assert.True(grid.RowCount > 1, $@"actual rowCount is {grid.RowCount}");
            //TODO: add test to check if they're all tables or views
        }
        //metadata test - test (empty schema)
        [Fact]
        public void  OdbcDatasourceEmptySchemaRows()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/Exasol.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            Assert.True(grid.RowCount == 1,$@"actual rowCount is {grid.RowCount}");
        }
        [Fact]
        public void OdbcDatasourceAWTableMD()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/ExasolAW.DimAccountTableMD.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            Assert.True(grid.RowCount > 1, $@"there should be some rows describing the metadata in a list/record in 'grid form'");
            int? nameIndex = Utilities.FindColumnNameIndex(grid, "Name");
            int? valueIndex = Utilities.FindColumnNameIndex(grid, "Value");

            Assert.True(nameIndex.HasValue);
            Assert.True(valueIndex.HasValue);

            int? datarowIndex = Utilities.FindRow(grid, nameIndex.Value, "Kind");
            Assert.True(datarowIndex.HasValue);
            var kindValue = grid.Rows[datarowIndex.Value].Cells[valueIndex.Value].Value;
            Assert.True(kindValue == "Table","Kind should be Table");

        }

        [Fact]
        public void OdbcDatasourceAWViewMD()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/ExasolAW.vDMPrepViewMD.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            Assert.True(grid.RowCount > 1, $@"there should be some rows describing the metadata in a list/record in 'grid form'");
            int? nameIndex = Utilities.FindColumnNameIndex(grid, "Name");
            int? valueIndex = Utilities.FindColumnNameIndex(grid, "Value");

            Assert.True(nameIndex.HasValue);
            Assert.True(valueIndex.HasValue);

            int? datarowIndex = Utilities.FindRow(grid, nameIndex.Value, "Kind");
            Assert.True(datarowIndex.HasValue);
            var kindValue = grid.Rows[datarowIndex.Value].Cells[valueIndex.Value].Value;
            Assert.True(kindValue == "View","Kind should be View");
        }
        [Fact]
        public void OdbcDatasourceAWTable()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/ExasolAW.DimAccountTable.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            Assert.True(grid.RowCount > 1, $@"actual rowCount is {grid.RowCount}");
            //add some asserts on the total number of columns
            Assert.True(grid.ColumnCount > 1);
            //add some more asserts?
        }

        [Fact]
        public void OdbcDatasourceAWView()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/ExasolAW.vDMPrepView.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            Assert.True(grid.RowCount > 1, $@"actual rowCount is {grid.RowCount}");
            //add some asserts on the total number of columns
            Assert.True(grid.ColumnCount > 1);
            //add some more asserts?
        }

        [Fact]
        public void OdbcDatasourceDatatypeConversion()
        {
            string MQueryExpression = Utilities.Queries.OdbcDatasourceGetTableSchema("MORETESTS", "DATATYPES");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            Assert.True(grid.RowCount > 1, $@"actual rowCount is {grid.RowCount}");

            //Ideally we'd split this up into several Fact tests or use a Theory 
            //but we'd have to requery all the time so it would just take way longer.
            //In the end it should be suffciëntly clear still where it failed.

            CheckColumnTypeInformation(grid, "varchar", "Text.Type", "text", "SQL_WVARCHAR"); //regression test
            CheckColumnTypeInformation(grid, "longvarchar", "Text.Type", "text", "SQL_WVARCHAR"); //regression test
            CheckColumnTypeInformation(grid, "geometry", "Binary.Type", "binary", "GEOMETRY"); //!!! discuss this case
            CheckColumnTypeInformation(grid, "boolean", "Logical.Type", "logical", "BOOLEAN");
            CheckColumnTypeInformation(grid, "char", "Text.Type", "text", "SQL_WVARCHAR"); //regression test
            CheckColumnTypeInformation(grid, "date", "Date.Type", "date", "DATE");
            CheckColumnTypeInformation(grid, "decimal", "Decimal.Type", "number", "DECIMAL");//this is a regression test (decimal to BIGINT with precision 0)
            CheckColumnTypeInformation(grid, "decimalwith0precision", "Int64.Type", "number", "BIGINT");//this is a regression test (decimal to BIGINT with precision 0) -> add another column for this
            CheckColumnTypeInformation(grid, "doubleprecision", "Double.Type", "number", "DOUBLE PRECISION");
            CheckColumnTypeInformation(grid, "float", "Double.Type", "number", "DOUBLE PRECISION");
            CheckColumnTypeInformation(grid, "integer", "Int64.Type", "number", "BIGINT");
            CheckColumnTypeInformation(grid, "tinyint", "Int64.Type", "number", "BIGINT");
            CheckColumnTypeInformation(grid, "smallint", "Int64.Type", "number", "BIGINT");
            CheckColumnTypeInformation(grid, "bigint", "Int64.Type", "number", "BIGINT");
            CheckColumnTypeInformation(grid, "intervaldaytosecond", "Binary.Type", "binary", "INTERVAL DAY TO SECOND");
            CheckColumnTypeInformation(grid, "intervalyeartomonth", "Binary.Type", "binary", "INTERVAL YEAR TO MONTH");
            CheckColumnTypeInformation(grid, "timestamp", "DateTime.Type", "datetime", "TIMESTAMP");
            CheckColumnTypeInformation(grid, "timestampwithlocaltimezone", "Binary.Type", "binary", "TIMESTAMP WITH LOCAL TIME ZONE");
            CheckColumnTypeInformation(grid, "hashtype", "Text.Type", "text", "SQL_WVARCHAR"); //regression test

        }
        [Fact]
        public void OdbcQueryDatatypeConversion()
        {
            string MQueryExpression = Utilities.Queries.OdbcQueryGetTableSchema("MORETESTS", "DATATYPES");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            Assert.True(grid.RowCount > 1, $@"actual rowCount is {grid.RowCount}");


            CheckColumnTypeInformation(grid, "varchar", "Text.Type", "text", "VARCHAR"); //TBD
            CheckColumnTypeInformation(grid, "longvarchar", "Text.Type", "text", "VARCHAR"); //TBD
            CheckColumnTypeInformation(grid, "geometry", "Text.Type", "text", "GEOMETRY"); //!!! discuss this case, deviates from Odbc.Datasource by default
            CheckColumnTypeInformation(grid, "boolean", "Logical.Type", "logical", "BOOLEAN");
            CheckColumnTypeInformation(grid, "char", "Text.Type", "text", "CHAR"); //!!! TBD
            CheckColumnTypeInformation(grid, "date", "Date.Type", "date", "DATE");
            CheckColumnTypeInformation(grid, "decimal", "Decimal.Type", "number", "DECIMAL");//this is a regression test (decimal to BIGINT with precision 0)
            //CheckColumnTypeInformation(grid, "decimalwith0precision", "Int64.Type", "number", "BIGINT");//this is a regression test (decimal to BIGINT with precision 0) -> discuss this case for odbc.query
            CheckColumnTypeInformation(grid, "doubleprecision", "Double.Type", "number", "DOUBLE");
            CheckColumnTypeInformation(grid, "float", "Double.Type", "number", "DOUBLE");
            CheckColumnTypeInformation(grid, "integer", "Decimal.Type", "number", "DECIMAL");
            CheckColumnTypeInformation(grid, "tinyint", "Decimal.Type", "number", "DECIMAL");
            CheckColumnTypeInformation(grid, "smallint", "Decimal.Type", "number", "DECIMAL");
            CheckColumnTypeInformation(grid, "bigint", "Decimal.Type", "number", "DECIMAL");
            CheckColumnTypeInformation(grid, "intervaldaytosecond", "Text.Type", "text", "INTERVAL DAY TO SECOND");
            CheckColumnTypeInformation(grid, "intervalyeartomonth", "Text.Type", "text", "INTERVAL YEAR TO MONTH");
            CheckColumnTypeInformation(grid, "timestamp", "DateTime.Type", "datetime", "TIMESTAMP");
            CheckColumnTypeInformation(grid, "timestampwithlocaltimezone", "DateTime.Type", "datetime", "TIMESTAMP"); //!!!discuss this case, deviates by default
            CheckColumnTypeInformation(grid, "hashtype", "Text.Type", "text", "HASHTYPE"); //regression test

        }

        private void CheckColumnTypeInformation(FlaUI.Core.AutomationElements.Grid grid, string columnName, string columnType, string columnKind, string columnNativeTypeName)
        {

            int? columnNameIndex = Utilities.FindColumnNameIndex(grid, "Name");
            Assert.True(columnNameIndex.HasValue);

            int? columnRowIndex = Utilities.FindRow(grid, columnNameIndex.Value, columnName);
            Assert.True(columnRowIndex.HasValue, $@"column {columnName} not found");

            AssertColumnValue(grid, columnRowIndex.Value,columnName, "TypeName", columnType);
            AssertColumnValue(grid, columnRowIndex.Value,columnName, "Kind", columnKind);
            AssertColumnValue(grid, columnRowIndex.Value,columnName, "NativeTypeName", columnNativeTypeName);
        }

        private void AssertColumnValue(FlaUI.Core.AutomationElements.Grid grid, int rowIndex,string columnName, string columnPropertyName, string expectedValue)
        {
            int? columnPropertyIndex = Utilities.FindColumnNameIndex(grid, columnPropertyName);

            Assert.True(columnPropertyIndex.HasValue, $@"property info {columnPropertyName} not found");

            Assert.True(grid.Rows[rowIndex].Cells[columnPropertyIndex.Value].Value == expectedValue,
                $@"column {columnName}: {columnPropertyName} is {grid.Rows[rowIndex].Cells[columnPropertyIndex.Value].Value}, expected {expectedValue}");
        }

        [Fact]
        //text conversion tests for datasource and query
        private void OdbcDatasourceGetText()
        {
            string MQueryExpression = Utilities.Queries.OdbcDatasourceGetTable("MORETESTS", "TEXTCONVERSION");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            Assert.True(grid.RowCount > 1, $@"actual rowCount is {grid.RowCount}");

            int? rowNameIndex = Utilities.FindColumnNameIndex(grid, "rowname");
            int? varcharIndex = Utilities.FindColumnNameIndex(grid, "varchar");
            int? longvarcharIndex = Utilities.FindColumnNameIndex(grid, "longvarchar");
            int? charIndex = Utilities.FindColumnNameIndex(grid, "char");

            int? veroRowIndex = Utilities.FindRow(grid, rowNameIndex.Value, "vero");
            int? umlautsRowIndex = Utilities.FindRow(grid, rowNameIndex.Value, "umlauts");
            int? eightballRowIndex = Utilities.FindRow(grid, rowNameIndex.Value, "8balls");


            Assert.True(grid.Rows[veroRowIndex.Value].Cells[varcharIndex.Value].Value == "Véroniquë ç'est unne fémme uniquë");
            Assert.True(grid.Rows[veroRowIndex.Value].Cells[longvarcharIndex.Value].Value == "Véroniquë ç'est unne fémme uniquë");
            Assert.Contains("Véroniquë ç'est unne fémme uniquë", grid.Rows[veroRowIndex.Value].Cells[charIndex.Value].Value); //

            Assert.True(grid.Rows[eightballRowIndex.Value].Cells[varcharIndex.Value].Value == "❽❽❽❽❽");
            Assert.True(grid.Rows[eightballRowIndex.Value].Cells[longvarcharIndex.Value].Value == "❽❽❽❽❽");
            Assert.Contains("❽❽❽❽❽", grid.Rows[eightballRowIndex.Value].Cells[charIndex.Value].Value);

            Assert.True(grid.Rows[umlautsRowIndex.Value].Cells[varcharIndex.Value].Value == "ÖÜÄ");
            Assert.True(grid.Rows[umlautsRowIndex.Value].Cells[longvarcharIndex.Value].Value == "ÖÜÄ");
            Assert.Contains("ÖÜÄ", grid.Rows[umlautsRowIndex.Value].Cells[charIndex.Value].Value);
        }
        [Fact]
        private void OdbcQueryGetText()
        {
            string MQueryExpression = Utilities.Queries.OdbcQueryGetTable("MORETESTS", "TEXTCONVERSION");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            Assert.True(grid.RowCount > 1, $@"actual rowCount is {grid.RowCount}");

            int? rowNameIndex = Utilities.FindColumnNameIndex(grid, "rowname");
            int? varcharIndex = Utilities.FindColumnNameIndex(grid, "varchar");
            int? longvarcharIndex = Utilities.FindColumnNameIndex(grid, "longvarchar");
            int? charIndex = Utilities.FindColumnNameIndex(grid, "char");

            int? veroRowIndex = Utilities.FindRow(grid, rowNameIndex.Value, "vero");
            int? umlautsRowIndex = Utilities.FindRow(grid, rowNameIndex.Value, "umlauts");
            int? eightballRowIndex = Utilities.FindRow(grid, rowNameIndex.Value, "8balls");

            Assert.True(grid.Rows[veroRowIndex.Value].Cells[varcharIndex.Value].Value == "Véroniquë ç'est unne fémme uniquë");
            Assert.True(grid.Rows[veroRowIndex.Value].Cells[longvarcharIndex.Value].Value == "Véroniquë ç'est unne fémme uniquë");
            Assert.Contains("Véroniquë ç'est unne fémme uniquë", grid.Rows[veroRowIndex.Value].Cells[charIndex.Value].Value); //

            Assert.True(grid.Rows[eightballRowIndex.Value].Cells[varcharIndex.Value].Value == "❽❽❽❽❽");
            Assert.True(grid.Rows[eightballRowIndex.Value].Cells[longvarcharIndex.Value].Value == "❽❽❽❽❽");
            Assert.Contains("❽❽❽❽❽", grid.Rows[eightballRowIndex.Value].Cells[charIndex.Value].Value);

            Assert.True(grid.Rows[umlautsRowIndex.Value].Cells[varcharIndex.Value].Value == "ÖÜÄ");
            Assert.True(grid.Rows[umlautsRowIndex.Value].Cells[longvarcharIndex.Value].Value == "ÖÜÄ");
            Assert.Contains("ÖÜÄ", grid.Rows[umlautsRowIndex.Value].Cells[charIndex.Value].Value );


        }

        [Fact]
        public void OdbcQueryLimit5()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/CustomQuery.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            Assert.True(grid.RowCount == 5 + 1, $@"actual rowCount is {grid.RowCount}");
            Assert.True(grid.ColumnCount > 1);
        }
        [Fact]
        public void OdbcQueryViewLimit5()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/CustomQueryView.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            Assert.True(grid.RowCount == 5 + 1, $@"actual rowCount is {grid.RowCount}");
            Assert.True(grid.ColumnCount > 1);
        }
        [Fact]
        public void OdbcDatasourceViewSchema()
        {
            string MQueryExpression = Utilities.Queries.OdbcDatasourceGetTableSchema("ADVENTUREWORKSDW2014", "vDMPrep");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");

        }
        [Fact]
        public void OdbcQueryViewSchema()
        {
            string MQueryExpression = Utilities.Queries.OdbcQueryGetTableSchema("ADVENTUREWORKSDW2014", "vDMPrep");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");

        }

        //test for the test connection to make sure it keeps working with 2 parameters for the 'test query' documented in the pq file.
        [Fact]
        public void ExasolTestQuery()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/ExasolTestQuery.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");

        }
        //odbc parameters
        [Fact]
        public void ExasolOdbcParams()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/ExasolOdbcParams.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");

        }
        [Fact]
        public void ExasolOdbcParamsParentheses()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/ExasolOdbcParamsParentheses.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");

        }

        [Fact]
        public void ExasolOdbcParamsQuery()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/ExasolOdbcParamsQuery.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");

        }
        [Fact]
        public void ExasolOdbcParamsOptionsNull()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/ExasolOdbcParamsOptionsNull.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");

        }
        [Fact]
        public void ExasolOdbcParamsOdbcParamsNull()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/ExasolOdbcParamsOdbcParamsNull.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");

        }
    }
}
