using System.Collections;
using System.Collections.Generic;

namespace ConfigurationBuilder
{
    public class RestBody
    {
        public string Type { get; set; }
        public int SelectedIndexValue { get; set; }
        public List<RestBodyParameter> RestBodyParameters { get; set; }

        RestBody()
        {
        }

        public RestBody(Hashtable hashTable)
        {
            this.Type = (string)hashTable["Type"];
            this.SelectedIndexValue = (int)hashTable["SelectedIndexValue"];
            this.RestBodyParameters = RestBodyParameter.AddRange((hashTable["RestBodyParameters"]).ToHashtableList());
        }

    }
}