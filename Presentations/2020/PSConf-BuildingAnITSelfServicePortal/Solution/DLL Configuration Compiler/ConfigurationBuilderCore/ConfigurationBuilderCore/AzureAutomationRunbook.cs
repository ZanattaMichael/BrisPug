using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Collections;

namespace ConfigurationBuilder
{
    public class AzureAutomationRunbook
    {
        public string Name { get; set; }
        public List<RunbookParameter> Parameters { get; set; }

        public AzureAutomationRunbook() {
        }

        public AzureAutomationRunbook(Hashtable hashTable)
        {
            this.Name = (string)hashTable["Name"];
            this.Parameters = RunbookParameter.AddRange((hashTable["Parameters"]).ToHashtableList());
        }
    }
}
