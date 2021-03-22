using FlaUI.Core;
using FlaUI.Core.AutomationElements;
using FlaUI.Core.Conditions;
using FlaUI.Core.Input;
using FlaUI.Core.WindowsAPI;
using FlaUI.UIA3;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace UIAutomationTests
{
    public class TestFixture : IDisposable
    {


        string vsExecutablePath;
        string slnPath;

        string queryPqPath;
        string originalQueryPqStr;

        string server;
        string username;
        string password;

        string tokenFilePath;
        string generateTokenPath;

        Application app;
        UIA3Automation automation;

        ConditionFactory cf;

        AutomationElement mainWindow;

        AutomationElement debugTargetButtonAE;
        Button debugTargetButton;
        AutomationElement MQueryOutput;
        AutomationElement[] tabItemAEs;

        private void Config()
        {
            var config = new ConfigurationBuilder()
            .AddJsonFile("config.json")
            .Build();

            server = config["server"];
            username = config["username"];
            password = config["password"];

            vsExecutablePath = config["vsExecutablePath"];
            slnPath = config["slnPath"];
            queryPqPath = config["queryPqPath"];

            tokenFilePath = config["tokenFilePath"];
            generateTokenPath = config["generateTokenPath"];
        }
        //https://stackoverflow.com/questions/12976319/xunit-net-global-setup-teardown
        //Do "global" initialization here; Only called once.
        public TestFixture()
        {
            Config();
            MakeBackup();
            PrepVisualStudio();
            SetPqFileBeforeCredentials();
            SetupConditionFactory();
            AcquireDebugTargetButton();
            PressDebugTargetButton();
            WaitUntilBuildTasksAreDone();
            AcquireMQueryWindowAndAcquireTabsWhenFullyLoaded();

            
        }
        public enum AuthenticationMethod
        {
            UsernamePassword,
            KeyOIDCToken
        }
        bool bAuthenticated = false;

        //the errors tab will pop up and ask for credentials
        //entering the credentials seems to be more reliable than loading them (credential loading seems buggy!)
        public void Authenticate(AuthenticationMethod authenticationMethod)
        {
            if (!bAuthenticated)
            {

                switch (authenticationMethod)
                {
                    case AuthenticationMethod.UsernamePassword:
                        EnterCredentialsUsernameAndPassword();
                        break;
                    case AuthenticationMethod.KeyOIDCToken:
                        EnterCredentialsKeyOIDCToken();
                        break;

                }
                bAuthenticated = true;
            }

        }
        private void SetPqFileBeforeCredentials()
        {
            string MQueryExpression = File.ReadAllText("QueryPqFiles/Exasol.query.pq");
            FormatAndSetPqFile(MQueryExpression);
        }

        private void SetupConditionFactory()
        {
            cf = new ConditionFactory(new UIA3PropertyLibrary());
        }

        private void EnterCredentialsUsernameAndPassword()
        {
            var errorsTabAE = tabItemAEs[2];
            errorsTabAE.AsTabItem().Select();

            var comboBoxes = WaitUntilMultipleFound(errorsTabAE, FlaUI.Core.Definitions.TreeScope.Descendants, cf.ByControlType(FlaUI.Core.Definitions.ControlType.ComboBox));
            var cbCredentialType = comboBoxes[1].AsComboBox();
            cbCredentialType.Select(0);

            var textBoxes = WaitUntilAtLeastNFound( errorsTabAE,FlaUI.Core.Definitions.TreeScope.Descendants, cf.ByControlType(FlaUI.Core.Definitions.ControlType.Edit), 2);
            textBoxes[0].AsTextBox().Text = username;
            textBoxes[1].AsTextBox().Text = password;

            var buttons = errorsTabAE.FindAll(FlaUI.Core.Definitions.TreeScope.Descendants, cf.ByControlType(FlaUI.Core.Definitions.ControlType.Button));
            buttons[0].AsButton().Invoke();

        }

        private void EnterCredentialsKeyOIDCToken()
        {
            var token = FetchToken();
            var errorsTabAE = tabItemAEs[2];
            errorsTabAE.AsTabItem().Select();

            var comboBoxes = WaitUntilMultipleFound(errorsTabAE, FlaUI.Core.Definitions.TreeScope.Descendants, cf.ByControlType(FlaUI.Core.Definitions.ControlType.ComboBox));
            var cbCredentialType = comboBoxes[1].AsComboBox();
            cbCredentialType.Select(1);

            var textBoxes = WaitUntilAtLeastNFound(errorsTabAE, FlaUI.Core.Definitions.TreeScope.Descendants, cf.ByControlType(FlaUI.Core.Definitions.ControlType.Edit), 1);
            textBoxes[0].AsTextBox().Text = token;

            var buttons = errorsTabAE.FindAll(FlaUI.Core.Definitions.TreeScope.Descendants, cf.ByControlType(FlaUI.Core.Definitions.ControlType.Button));
            buttons[0].AsButton().Invoke();
        }

        private string FetchToken()
        {
            return GenerateToken();
        }

        private string GenerateToken()
        {
            string token;
            string generateTokenPath = "C:\\auth\\tokens.py";
            string cmd = generateTokenPath;
            string arguments = "";
            ProcessStartInfo start = new ProcessStartInfo();
            start.FileName = "python";
            start.Arguments = cmd;//, arguments);
            start.UseShellExecute = false;
            start.RedirectStandardOutput = true;
            using (Process process = Process.Start(start))
            {
                using (StreamReader reader = process.StandardOutput)
                {
                    string result = reader.ReadToEnd();
                    token = result;
                }
            }
            return token;
        }

        private void PrepVisualStudio()
        {
            app = FlaUI.Core.Application.Launch(vsExecutablePath, slnPath);

            automation = new UIA3Automation();
            automation.ConnectionTimeout = new TimeSpan(0, 1, 0);
            automation.TransactionTimeout = new TimeSpan(0, 1, 0);

            mainWindow = WaitUntillSlnIsLoaded(app, automation);
        }

        private void AcquireMQueryWindowAndAcquireTabsWhenFullyLoaded()
        {
            MQueryOutput = WaitUntilFirstFound(mainWindow, FlaUI.Core.Definitions.TreeScope.Descendants, cf.ByName("M Query Output"));
            //acquire tabs
            tabItemAEs = WaitUntilAtLeastNFound(MQueryOutput, FlaUI.Core.Definitions.TreeScope.Descendants, cf.ByControlType(FlaUI.Core.Definitions.ControlType.TabItem), 4);
        }

        private void PressDebugTargetButton()
        {
            debugTargetButton.Invoke();
        }

        private void WaitUntilBuildTasksAreDone()
        {
            int delayMSeconds = 200;
            AcquireDebugTargetButton();
            while (debugTargetButton.IsEnabled == false)
            {
                Task.Delay(delayMSeconds).Wait();
                AcquireDebugTargetButton();
            }
        }

        private void AcquireDebugTargetButton()
        {
            debugTargetButtonAE =WaitUntilFirstFound(mainWindow, FlaUI.Core.Definitions.TreeScope.Descendants, cf.ByName("Debug Target"));
            debugTargetButton = debugTargetButtonAE.AsButton();
        }

        private void MakeBackup()
        {
            originalQueryPqStr = File.ReadAllText(queryPqPath);
            File.WriteAllText($@"c:\temp\pq.backup", originalQueryPqStr);
        }

        public (string Error, Grid Grid) Test(string MQueryExpression)
        {
            FormatAndSetPqFile(MQueryExpression);
            RunTest();
            return GetResults();
        }

        private void FormatAndSetPqFile(string MQueryExpression)
        {
            String plusServerStr = MQueryExpression.Replace("{server}", server);
            File.WriteAllText(queryPqPath, plusServerStr);
        }

        private (string Error,Grid Grid) GetResults()
        {
            var error = GetErrorReport();
            var grid = GetResultGrid();
            var t = (error,grid);
            return t;
        }

        private string GetErrorReport()
        {
            SelectErrorsTab();
            return  GrabErrorText();

        }

        private string GrabErrorText()
        {
            var errorsTab = tabItemAEs[2];
            var errorReportText = WaitUntilFirstFound(errorsTab, FlaUI.Core.Definitions.TreeScope.Descendants, (cf.ByAutomationId("ErrorReport")));
            var errorReportTextLabel = errorReportText.AsLabel();
            return errorReportTextLabel.Text;
        }

        private void RunTest()
        {
            PressDebugTargetButton();
            WaitUntilBuildTasksAreDone();
            AcquireMQueryWindowAndAcquireTabsWhenFullyLoaded();
        }

        private Grid GetResultGrid()
        {
            SelectOutputTab();      
            return GrabGrid();
        }

        private Grid GrabGrid()
        {
            var outputTab = tabItemAEs[0];
            var outputDataGridAE = WaitUntilFirstFound(outputTab, FlaUI.Core.Definitions.TreeScope.Descendants, (cf.ByControlType(FlaUI.Core.Definitions.ControlType.DataGrid)));
            var outputDataGrid = outputDataGridAE.AsGrid();
            return outputDataGrid;
        }

        private void SelectOutputTab()
        {
            var outputTab = tabItemAEs[0];
            outputTab.AsTabItem().Select();
        }
        private void SelectErrorsTab()
        {
            var errorsTab = tabItemAEs[2];
            errorsTab.AsTabItem().Select();
        }
        public void Dispose()
        {
            // Do "global" teardown here; Only called once.
            automation.Dispose();
            app.Close();
            RestoreQueryPq();
        }
        //put original query pq file back
        private void RestoreQueryPq()
        {         
            File.WriteAllText(queryPqPath, originalQueryPqStr);
        }

        private static Window WaitUntillSlnIsLoaded(FlaUI.Core.Application app, UIA3Automation automation)
        {
            int delayMSeconds = 500;
            var cf = new ConditionFactory(new UIA3PropertyLibrary());
            AutomationElement debugTargetButton = null;
            Window mainWindow = null;

            while (debugTargetButton is null)
            {
                mainWindow = app.GetMainWindow(automation);

                debugTargetButton = mainWindow.FindFirst(FlaUI.Core.Definitions.TreeScope.Descendants, cf.ByName("Debug Target"));

                if (!(debugTargetButton is null))
                {
                    break;
                }

                Task.Delay(delayMSeconds).Wait();
            }
            return mainWindow;

        }

        private static AutomationElement WaitUntilFirstFound(AutomationElement parent, FlaUI.Core.Definitions.TreeScope treeScope, ConditionBase condition)
        {
            int delayMSeconds = 200;
            AutomationElement futureHandle = null;

            while (futureHandle is null)
            {

                futureHandle = parent.FindFirst(treeScope, condition);

                if (!(futureHandle is null))
                {
                    break;
                }
                Task.Delay(delayMSeconds).Wait();
            }
            return futureHandle;

        }
        private static AutomationElement[] WaitUntilMultipleFound(AutomationElement parent, FlaUI.Core.Definitions.TreeScope treeScope, ConditionBase condition)
        {
            int delayMSeconds = 200;
            AutomationElement[] elements = { };

            while (elements.Length == 0)
            {

                elements = parent.FindAll(treeScope, condition);

                if (elements.Length > 0)
                {
                    break;
                }
                Task.Delay(delayMSeconds).Wait();
            }
            return elements;
        }
        private static AutomationElement[] WaitUntilAtLeastNFound(AutomationElement parent, FlaUI.Core.Definitions.TreeScope treeScope, ConditionBase condition,int nr)
        {
            int delayMSeconds = 200;
            AutomationElement[] elements = { };

            while (elements.Length < nr)
            {
                elements = parent.FindAll(treeScope, condition);

                if (elements.Length >= nr)
                {
                    break;
                }
                Task.Delay(delayMSeconds).Wait();
            }
            return elements;
        }

    }
}

