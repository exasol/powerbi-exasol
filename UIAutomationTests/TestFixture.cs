using FlaUI.Core;
using FlaUI.Core.AutomationElements;
using FlaUI.Core.Conditions;
using FlaUI.Core.Input;
using FlaUI.Core.WindowsAPI;
using FlaUI.UIA3;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace UIAutomationTests
{
    public class TestFixture : IDisposable
    {

        string vsExecutablePath = $@"C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe";
        string slnPath = $@"C:\repos\powerbi-exasol\Exasol\Exasol.mproj";

        string queryPqPath = $@"C:\repos\powerbi-exasol\Exasol\Exasol.query.pq";
        string originalQueryPqStr;

        string username = "sys";
        string password = "exasol";

        Application app;
        UIA3Automation automation;

        ConditionFactory cf;

        AutomationElement mainWindow;

        AutomationElement debugTargetButtonAE;
        Button debugTargetButton;
        AutomationElement MQueryOutput;
        AutomationElement[] tabItemAEs;

        //https://stackoverflow.com/questions/12976319/xunit-net-global-setup-teardown
        //Do "global" initialization here; Only called once.
        public TestFixture()
        {
            PrepVisualStudio();
            SetupConditionFactory();
            AcquireDebugTargetButton();
            PressDebugTargetButton();
            WaitUntilBuildTasksAreDone();
            AcquireMQueryWindowAndAcquireTabsWhenFullyLoaded();
            //the errors tab will pop up and ask for credentials
            //entering the credentials seems to be more reliable than loading them (credential loading seems buggy!)
            EnterCredentials();
            MakeBackup();
        }

        private void SetupConditionFactory()
        {
            cf = new ConditionFactory(new UIA3PropertyLibrary());
        }

        private void EnterCredentials()
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
            debugTargetButtonAE = mainWindow.FindFirst(FlaUI.Core.Definitions.TreeScope.Descendants, cf.ByName("Debug Target"));
            debugTargetButton = debugTargetButtonAE.AsButton();
        }

        private void MakeBackup()
        {
            originalQueryPqStr = File.ReadAllText(queryPqPath);
            File.WriteAllText($@"c:\temp\pq.backup", originalQueryPqStr);
        }

        public Grid RunTest(string MQueryExpression)
        {
            File.WriteAllText(queryPqPath, MQueryExpression);
            return RunTest();
        }

        private Grid RunTest()
        {
            PressDebugTargetButton();
            WaitUntilBuildTasksAreDone();
            AcquireMQueryWindowAndAcquireTabsWhenFullyLoaded();
            return GetResultGrid();
        }

        private Grid GetResultGrid()
        {
            var resultTab = tabItemAEs[0];
            var outputDataGridAE = WaitUntilFirstFound(resultTab, FlaUI.Core.Definitions.TreeScope.Descendants, (cf.ByControlType(FlaUI.Core.Definitions.ControlType.DataGrid)));
            var outputDataGrid = outputDataGridAE.AsGrid();
            return outputDataGrid;
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

