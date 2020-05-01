using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Collections;

namespace ConfigurationBuilder
{
    public class RunbookParameter
    {
        public string Name { get; set; }
        public string HTMLName { get; set; }

        public RunbookParameter()
        {

        }

        public static List<RunbookParameter> AddRange (Hashtable[] hashtables)
        {

            List<RunbookParameter> parameters = new List<RunbookParameter>();

            foreach (Hashtable hashtable in hashtables) {

                var parameter = new RunbookParameter()
                {
                    Name = (string)hashtable["Name"],
                    HTMLName = (string)hashtable["HTMLName"]
                };

                parameters.Add(parameter);

            }

            return parameters;
        }

    }
}
