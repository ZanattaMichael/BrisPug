using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConfigurationBuilder
{
    public class HTMLObject
    {
        int id { get; set; }
        public AzureAutomationRunbook AzureAutomationRunbook { get; set; }
        public RestBody RestBody { get; set; }
        public HTTPContent httpContent { get; set; }


        public HTMLObject()
        {

        }

        public static HTMLObject Add(
                Hashtable RunbookParameters,
                Hashtable RestBody,
                Hashtable HTTPContent,
                int Index)
        {

            HTMLObject htmlObject = new HTMLObject()
            {
            
                id = Index,
                AzureAutomationRunbook = new AzureAutomationRunbook(RunbookParameters),
                RestBody = new RestBody(RestBody),
                httpContent = new HTTPContent(HTTPContent)
            };
           
            return htmlObject;
        }
    }
}
