using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConfigurationBuilder
{
    public class HTMLConfig
    {
        public int Id { get; set; }
        public string TagIdPrefix { get; set; }
        public string ElementType { get; set; }
        public string[] Values { get; set; }
        public string HTMLName { get; set; }

        public HTMLConfig()
        {

        }

        public static List<HTMLConfig> AddRange(Hashtable[] hashtables)
        {
            List<HTMLConfig> configs = new List<HTMLConfig>();
            int i = 0;

            foreach (Hashtable hashtable in hashtables)
            {
                configs.Add(
                        new HTMLConfig()
                        {
                            Id = i++,
                            HTMLName = (string)hashtable["HTMLName"],
                            TagIdPrefix = $"{(string)hashtable["TagType"]}_{i}",
                            ElementType = (string)hashtable["ElementType"],
                            Values = ((IEnumerable)hashtable["Values"]).Cast<object>()
                                                                      .Select(x => x.ToString())
                                                                      .ToArray()
                        }
                    );
            }

            return configs;
        }
    }
}
