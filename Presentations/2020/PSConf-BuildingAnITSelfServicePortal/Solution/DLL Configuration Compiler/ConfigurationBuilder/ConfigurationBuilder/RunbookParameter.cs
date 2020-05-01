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
        public int ID { get; set; }
        public string Name { get; set; }
        public int HTMLIndexValue { get; set; }
        public string ParameterType { get; set; }

        public static List<RunbookParameter> AddRange(Hashtable[] hashtables)
        {

            List<RunbookParameter> parameters = new List<RunbookParameter>();

            int i = 0;

            foreach (Hashtable hashtable in hashtables)
            {

                var parameter = new RunbookParameter()
                {
                    ID = i++,
                    Name = (string)hashtable["Name"],
                    HTMLIndexValue = (int)hashtable["HTMLIDValue"],
                    ParameterType = (string)hashtable["Type"]
                };

                parameters.Add(parameter);

            }

            return parameters;
        }

    }
}
