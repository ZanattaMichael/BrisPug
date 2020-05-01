using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConfigurationBuilder
{
    public class HTTPContent
    {
        public string Title { get; set; }
        public string Type { get; set; }
        public string Description { get; set; }
        public string ResponseURL { get; set; }
        public string[] Owners { get; set; }
        public List<HTMLConfig> HTMLConfigs { get; set; }

        public HTTPContent()
        {

        }

        public HTTPContent(Hashtable hashtable)
        {
            this.Title = (string)hashtable["Title"];
            this.Type = (string)hashtable["Type"];
            this.Description = (string)hashtable["Description"];
            this.ResponseURL = (string)hashtable["ResponseURL"];
            this.Owners = ((IEnumerable)hashtable["Owners"]).Cast<object>()
                                                            .Select(x => x.ToString())
                                                            .ToArray();

            this.HTMLConfigs = HTMLConfig.AddRange((hashtable["HTMLConfig"]).ToHashtableList());

        }
    }
}
