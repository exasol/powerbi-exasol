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
    public class TestFixture
    {

        string vsExecutablePath = $@"C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\IDE\devenv.exe";
        string slnPath = $@"C:\repos\powerbi-exasol\Exasol\Exasol.mproj";

        string queryPqPath = $@"C:\repos\powerbi-exasol\Exasol\Exasol.query.pq";
        string originalQueryPqStr;

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

            AcquireMQueryWindowAndAcquireTabsWhenFullyLoaded();

            //entering the credentials seems to be more reliable
            EnterCredentials();

            SaveAndBackupOriginalQueryString();
        }

        private void SetupConditionFactory()
        {
            cf = new ConditionFactory(new UIA3PropertyLibrary());
        }

        private void EnterCredentials()
        {
            //the errors tab will pop up and ask for credentials
            var errorsTabAE = tabItemAEs[2];
            errorsTabAE.AsTabItem().Select();

            var comboBoxes = WaitUntilMultipleFoundAsync(errorsTabAE, FlaUI.Core.Definitions.TreeScope.Descendants, cf.ByControlType(FlaUI.Core.Definitions.ControlType.ComboBox)).Result;
            //comboBoxes = errorsTabAE.FindAll(FlaUI.Core.Definitions.TreeScope.Descendants, cf.ByControlType(FlaUI.Core.Definitions.ControlType.ComboBox));
            var cbCredentialType = comboBoxes[1].AsComboBox();
            cbCredentialType.Select(0);

            var textBoxes = errorsTabAE.FindAll(FlaUI.Core.Definitions.TreeScope.Descendants, cf.ByControlType(FlaUI.Core.Definitions.ControlType.Edit));
            textBoxes[0].AsTextBox().Text = "sys";
            textBoxes[1].AsTextBox().Text = "exasol";

            var buttons = errorsTabAE.FindAll(FlaUI.Core.Definitions.TreeScope.Descendants, cf.ByControlType(FlaUI.Core.Definitions.ControlType.Button));
            buttons[0].AsButton().Invoke();

        }

        private void PrepVisualStudio()
        {
            app = FlaUI.Core.Application.Launch(vsExecutablePath, slnPath);

            automation = new UIA3Automation();
            automation.ConnectionTimeout = new TimeSpan(0, 1, 0);
            automation.TransactionTimeout = new TimeSpan(0, 1, 0);

            //https://markheath.net/post/async-antipatterns
            mainWindow = WaitUntillSlnIsLoadedAsync(app, automation).Result;

        }

        private void AcquireMQueryWindowAndAcquireTabsWhenFullyLoaded()
        {
            MQueryOutput = WaitUntilFindFirstFoundAsync(mainWindow, FlaUI.Core.Definitions.TreeScope.Descendants, cf.ByName("M Query Output")).Result;

            //acquire tabs
            tabItemAEs = WaitUntilMultipleFoundAsync(MQueryOutput, FlaUI.Core.Definitions.TreeScope.Descendants, cf.ByControlType(FlaUI.Core.Definitions.ControlType.TabItem)).Result;
        }

        private void PressDebugTargetButton()
        {
            debugTargetButton.Invoke();
        }

        private void AcquireDebugTargetButton()
        {
            debugTargetButtonAE = mainWindow.FindFirst(FlaUI.Core.Definitions.TreeScope.Descendants, cf.ByName("Debug Target"));
            debugTargetButton = debugTargetButtonAE.AsButton();
        }

        private void SaveAndBackupOriginalQueryString()
        {
            //store original query pq text
            originalQueryPqStr = File.ReadAllText(queryPqPath);
            //make a backup
            File.WriteAllText($@"c:\temp\pq.backup", originalQueryPqStr);
        }

        //
        public async Task<Grid> RunTest(string MQueryExpression)
        {
            File.WriteAllText(queryPqPath, MQueryExpression);
            return await RunTest(cf, debugTargetButton, tabItemAEs);
        }

        private static async Task<Grid> RunTest(ConditionFactory cf, Button btn, AutomationElement[] tabItemAEs)
        {
            //Run again
            btn.Invoke();

            //Read results

            Console.WriteLine("Writing from output grid :");
            var outputDataGridAE = await WaitUntilFindFirstFoundAsync(tabItemAEs[0], FlaUI.Core.Definitions.TreeScope.Descendants, (cf.ByControlType(FlaUI.Core.Definitions.ControlType.DataGrid)));

            var outputDataGrid = outputDataGridAE.AsGrid();

            return outputDataGrid;
        }


        public void Dispose()
        {
            // Do "global" teardown here; Only called once.
            automation.Dispose();
            app.Close();
            //put original query pq file back
            File.WriteAllText(queryPqPath, originalQueryPqStr);
        }

        private static async Task<Window> WaitUntillSlnIsLoadedAsync(FlaUI.Core.Application app, UIA3Automation automation)
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

                await Task.Delay(delayMSeconds);
            }
            return mainWindow;

        }

        private static async Task<AutomationElement> WaitUntilFindFirstFoundAsync(AutomationElement parent, FlaUI.Core.Definitions.TreeScope treeScope, ConditionBase condition)
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
                await Task.Delay(delayMSeconds);
            }
            return futureHandle;

        }
        private static async Task<AutomationElement[]> WaitUntilMultipleFoundAsync(AutomationElement parent, FlaUI.Core.Definitions.TreeScope treeScope, ConditionBase condition)
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
                await Task.Delay(delayMSeconds);
            }
            return elements;

        }

    }
}

