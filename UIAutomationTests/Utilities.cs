using FlaUI.Core.AutomationElements;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;

namespace UIAutomationTests
{
    class Utilities
    {
        public static int? FindColumnNameIndex(Grid grid, string columnName)
        {
            for (int i = 0; i < grid.Header.Columns.Length; i++)
            {
                if (grid.Header.Columns[i].Text == columnName)
                    return i;
            }
            return null;
        }
        public static int? FindRow(Grid grid, int columnIndex, string rowValue)
        {
            for (int i = 0; i < grid.Rows.Length; i++)
            {
                if (grid.Rows[i].Cells[columnIndex].Value == rowValue)
                    return i;
            }
            return null;
        }
        static Utilities()
        {
            config = new ConfigurationBuilder().AddJsonFile("config.json").Build();
        }
        private static IConfigurationRoot config;
        public static string GetConfigurationValue(string configurationKey)
        {
            return config[configurationKey];
        }
        public class ComposeMashupFiles
        {
            static readonly string mashupBlockRegexStr;
            static readonly string mashupFunctionOutputRegexStr;
            static ComposeMashupFiles()
            {
                mashupBlockRegexStr = File.ReadAllText("etc/mashupBlockRegex.txt");
                mashupFunctionOutputRegexStr = File.ReadAllText("etc/mashupFunctionOutputRegex.txt");
            }
            public static string GetMashupCodeBlock(string blockIdentifier, string sourceStr)
            {
                string mashupSpecificBlockRegexStr = mashupBlockRegexStr.Replace("blockIdentifier", blockIdentifier);
 
                
                Regex mashupBlockRegex = new Regex(mashupSpecificBlockRegexStr);
                var match = mashupBlockRegex.Match(sourceStr);
                if (match.Success)
                {
                    return match.Value;
                }
                else
                {
                    throw new Exception($"Identifier {blockIdentifier} not found");
                }
            }
            public enum SpoofCredentials
            {
                UsernamePassword,
                Key,
                Windows,

            }
            public static string SpoofCurrentCredentialsRecord(string functionStr, SpoofCredentials credentialsRecordType)
            {
                if (credentialsRecordType == SpoofCredentials.Windows)
                {
                    return functionStr.Replace("Extension.CurrentCredential()", "[AuthenticationKind = \"Windows\",Password=\"\"]");
                }
                else
                {
                    throw new NotImplementedException();
                }
            }
            public static string ReplaceMashupFunctionOutput(string functionStr, string newOutputVariableStr)
            {
 
                Regex mashupBlockRegex = new Regex(mashupFunctionOutputRegexStr);

                var matches = mashupBlockRegex.Matches(functionStr);
                if (!(matches.Count == 1)) { 
   
                    throw new Exception($"No in statement found or regex match ambiguity (multiple found)");
                }

                var newFunctionStr = mashupBlockRegex.Replace(functionStr,"in " + newOutputVariableStr);
                return newFunctionStr;
            }
            public static string LetStatement = "let ";
            public static string CommaAndNewLine = "," + Environment.NewLine;
        }
        public class Queries
        {
            public static string GetCellTypeQuery(string schema, string tablename, string columnname, string row)
            {
                string MQueryExpression = File.ReadAllText("GetCellType.query.pq");

                string SchemaNameStr = "{schemaname}";
                string TableNameStr = "{tablename}";
                string ColumnNameStr = "{columnname}";
                string RowStr = "{row}";

                string filledInPq = MQueryExpression
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
