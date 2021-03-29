using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using Xunit;
using Xunit.Abstractions;

namespace UIAutomationTests
{
    [Collection("VisualStudioUIAutomationTestCollection")]
    public class TestsLogging
    {
        private int timeToWaitForOdbcDriverToStartLoggingInSeconds = 15;
        UIAutomationTestFixture testFixture;
        ITestOutputHelper output;
        public TestsLogging(UIAutomationTestFixture tf, ITestOutputHelper output)
        {
            testFixture = tf;
            this.output = output;
            //CreateLogFile();
            DeleteLogFile();
        }

        private void DeleteLogFile()
        {
            //the mashup engine locks the file after running with logs enabled
            //it keeps writing to it as well, not sure why ..
            //we pre-emptively kill this process if it's still running before we run each of these tests 
            //since it holds the log file hostage and could also mess with our test results.
            string processName = "Microsoft.Mashup.Container.NetFX45";

            var processes = Process.GetProcessesByName(processName);
            foreach ( var process in processes) {
                process.Kill();
            }
            
            var logFilePath = Utilities.GetConfigurationValue("odbcLogFilePath");
            if (!File.Exists(logFilePath))
                File.Delete(logFilePath);
        }

        private void WaitWhileFileInUse(string logFilePath)
        {
            bool fileLocked = true;
            while (fileLocked == true)
            {
                try
                {
                    using (Stream stream = new FileStream(logFilePath, FileMode.Open))
                    {
                        // File/Stream manipulating code here
                        fileLocked = false;
                    }
                }
                catch
                {
                    //check here why it failed and ask user to retry if the file is in use.
                    //In this case: wait a bit
                    Task.Delay(TimeSpan.FromSeconds(5));
                }
            }
        }
        private void CreateLogFile()
        {
            var logFilePath = Utilities.GetConfigurationValue("odbcLogFilePath");
            if (!File.Exists(logFilePath))
                File.Create(logFilePath);

        }

        private string FillInLogFilePath(string MQueryExpression)
        {
            var logFilePath = Utilities.GetConfigurationValue("odbcLogFilePath");
            var newMQueryExpression = MQueryExpression.Replace("{absoluteLogPath}", logFilePath);
            return newMQueryExpression;
        }
        private void AssertLogActivityAfterTs(DateTime startTestTimeStamp)
        {
            var logFilePath = Utilities.GetConfigurationValue("odbcLogFilePath");
            Task.Delay(TimeSpan.FromSeconds(timeToWaitForOdbcDriverToStartLoggingInSeconds)).Wait();
            //WaitWhileFileInUse(logFilePath);

            var lastWrittenToLogFileDt = File.GetLastWriteTime(logFilePath);
            var testCheckTime = DateTime.Now;
            output.WriteLine("Log file path: " + logFilePath);
            output.WriteLine($@"check at {testCheckTime}, test start time : {startTestTimeStamp.ToLongTimeString()} ,last time modified: {lastWrittenToLogFileDt.ToLongTimeString()}");
            Assert.True(lastWrittenToLogFileDt > startTestTimeStamp, $@"Nothing's been logged, check at {testCheckTime}, test start time : {startTestTimeStamp.ToLongTimeString()} ,last time modified: {lastWrittenToLogFileDt.ToLongTimeString()}");
        }
                
        private void AssertNoLogActivityAfterTs(DateTime startTestTimeStamp)
        {

            var logFilePath = Utilities.GetConfigurationValue("odbcLogFilePath");
            Task.Delay(TimeSpan.FromSeconds(timeToWaitForOdbcDriverToStartLoggingInSeconds)).Wait();
            //WaitWhileFileInUse(logFilePath);

            var lastWrittenToLogFileDt = File.GetLastWriteTime(logFilePath);
            var testCheckTime = DateTime.Now;
            output.WriteLine("Log file path: " + logFilePath);
            output.WriteLine($@"check at {testCheckTime}, test start time : {startTestTimeStamp.ToLongTimeString()} ,last time modified: {lastWrittenToLogFileDt.ToLongTimeString()}");
            Assert.False(lastWrittenToLogFileDt > startTestTimeStamp, "Something's been logged");
        }
        [Fact]
        public void LogPathArgumentFilledIn()
        {
            var startTestTimeStamp = DateTime.Now;

            string MQueryExpression = File.ReadAllText("QueryPqFiles/LogPathArgument.query.pq");
            MQueryExpression = FillInLogFilePath(MQueryExpression);

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            AssertLogActivityAfterTs(startTestTimeStamp);
        }
        [Fact]
        public void LogPathArgumentQuery()
        {
            var startTestTimeStamp = DateTime.Now;

            string MQueryExpression = File.ReadAllText("QueryPqFiles/LogPathArgumentQuery.query.pq");
            MQueryExpression = FillInLogFilePath(MQueryExpression);

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            AssertLogActivityAfterTs(startTestTimeStamp);
        }

        [Fact]
        public void LogPathArgumentEmpty()
        {
            var startTestTimeStamp = DateTime.Now;

            string MQueryExpression = File.ReadAllText("QueryPqFiles/LogPathArgumentEmpty.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            AssertNoLogActivityAfterTs(startTestTimeStamp);
        }
        [Fact]
        public void LogPathArgumentNull()
        {
            var startTestTimeStamp = DateTime.Now;
            string MQueryExpression = File.ReadAllText("QueryPqFiles/LogPathArgumentNull.query.pq");

            var (error, grid) = testFixture.Test(MQueryExpression);

            Assert.True(String.IsNullOrWhiteSpace(error), $@"Errormessage: {error}");
            AssertNoLogActivityAfterTs(startTestTimeStamp);
        }
    }
}
