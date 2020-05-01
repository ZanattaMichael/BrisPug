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
        public string TagValue { get; set; }
        public string[] Values { get; set; }

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
                            TagIdPrefix = $"{(string)hashtable["TagType"]}_{i}",
                            TagValue = (string)hashtable["TagType"],
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
