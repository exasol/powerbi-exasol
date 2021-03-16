using FlaUI.Core.AutomationElements;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace UIAutomationTests
{
    class Utilities
    {
        public static int? FindColumnNameIndex(Grid grid, string columnName)
        {
            for (int i =0; i < grid.Header.Columns.Length;i++)
            {
                if (grid.Header.Columns[i].Text == columnName)
                    return i;
            }
            return null;
        }
        public static int? FindRow(Grid grid,int columnIndex, string rowValue)
        {
            for (int i = 0; i < grid.Rows.Length; i++)
            {
                if (grid.Rows[i].Cells[columnIndex].Value == rowValue)
                    return i;
            }
            return null;
        }

        public class Queries
        {
            public static string GetCellTypeQuery(string schema,string tablename,string columnname,string row)
            {
                string MQueryExpression = File.ReadAllText("GetCellType.query.pq");

                string SchemaNameStr = "{schemaname}";
                string TableNameStr = "{tablename}";
                string ColumnNameStr = "{columnname}";
                string RowStr = "{row}";

                   string filledInPq =  MQueryExpression
                    .Replace(SchemaNameStr, schema)
                    .Replace(TableNameStr, tablename)
                    .Replace(ColumnNameStr, columnname)
                    .Replace(RowStr, row);

                return filledInPq;
            }
            public static string GetCellTypesQuery(string schema, string tablename)
            {
                string MQueryExpression = File.ReadAllText("GetCellTypes.query.pq");

                string SchemaNameStr = "{schemaname}";
                string TableNameStr = "{tablename}";

                string filledInPq = MQueryExpression
                 .Replace(SchemaNameStr, schema)
                 .Replace(TableNameStr, tablename);

                return filledInPq;
            }
            public static string OdbcDatasourceGetTableSchema(string schema, string tablename)
            {
                string MQueryExpression = File.ReadAllText("QueryPqFiles/OdbcDatasourceGetTableSchema.query.pq");

                string SchemaNameStr = "{schemaname}";
                string TableNameStr = "{tablename}";

                string filledInPq = MQueryExpression
                 .Replace(SchemaNameStr, schema)
                 .Replace(TableNameStr, tablename);
                return filledInPq;
            }
            public static string OdbcQueryGetTableSchema(string schema, string tablename)
            {
                string MQueryExpression = File.ReadAllText("QueryPqFiles/OdbcQueryGetTableSchema.query.pq");

                string SchemaNameStr = "{schemaname}";
                string TableNameStr = "{tablename}";

                string filledInPq = MQueryExpression
                 .Replace(SchemaNameStr, schema)
                 .Replace(TableNameStr, tablename);
                return filledInPq;
            }

            public static string OdbcDatasourceGetTable(string schema, string tablename)
            {
                string MQueryExpression = File.ReadAllText("QueryPqFiles/OdbcDatasourceGetTable.query.pq");

                string SchemaNameStr = "{schemaname}";
                string TableNameStr = "{tablename}";

                string filledInPq = MQueryExpression
                 .Replace(SchemaNameStr, schema)
                 .Replace(TableNameStr, tablename);
                return filledInPq;
            }
            public static string OdbcQueryGetTable(string schema, string tablename)
            {
                string MQueryExpression = File.ReadAllText("QueryPqFiles/OdbcQueryGetTable.query.pq");

                string SchemaNameStr = "{schemaname}";
                string TableNameStr = "{tablename}";

                string filledInPq = MQueryExpression
                 .Replace(SchemaNameStr, schema)
                 .Replace(TableNameStr, tablename);
                return filledInPq;
            }

        }

    }
}
