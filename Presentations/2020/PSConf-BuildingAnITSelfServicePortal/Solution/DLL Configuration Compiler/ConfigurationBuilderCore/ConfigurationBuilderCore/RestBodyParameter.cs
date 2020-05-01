using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConfigurationBuilder
{
    public class RestBodyParameter
    {
        public string PropertyName { get; set; }
        public int HTMLID { get; set; }

        public RestBodyParameter()
        {

        }

        public static List<RestBodyParameter> AddRange(Hashtable[] hashtables)
        {
            List<RestBodyParameter> properties = new List<RestBodyParameter>();

            foreach (Hashtable hashtable in hashtables)
            {
                properties.Add(
                        new RestBodyParameter()
                        {
                            HTMLID = (int)hashtable["HtmlID"],
                            PropertyName = (string)hashtable["PropertyName"]
                        }
                    );
            }

            return properties;
        }

    }
}
