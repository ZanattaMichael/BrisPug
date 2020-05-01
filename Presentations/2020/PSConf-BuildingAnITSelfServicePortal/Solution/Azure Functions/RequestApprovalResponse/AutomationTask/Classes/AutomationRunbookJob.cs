using System;
using System.Collections.Generic;
using System.Text;

namespace AutomationTask.Classes
{
    public class AutomationRunbookJob
    {

        public string Name { get; set; }
        public IDictionary<string, string> Parameters { get; set;}

        public string RunOn { get; set; }
        public string ResourceGroupName { get; set; }
        public string AutomationAccountName { get; set; }

        public AutomationRunbookJob() { }
    }
}
