using System.Collections;
using System.Collections.Generic;

namespace ConfigurationBuilder
{
    public class RestBody
    {
        public string Type { get; set; }
        public string HTMLNameSelected { get; set; }

        public RestBody()
        {
        }

        public RestBody(Hashtable hashTable)
        {
            this.Type = (string)hashTable["Type"];
            this.HTMLNameSelected = (string)hashTable["HTMLNameSelected"];
        }

    }
}