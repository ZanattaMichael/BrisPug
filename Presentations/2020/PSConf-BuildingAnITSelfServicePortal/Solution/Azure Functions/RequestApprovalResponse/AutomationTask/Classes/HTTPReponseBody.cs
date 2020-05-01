using System;
using System.Collections.Generic;
using System.Text;
using Newtonsoft.Json;
using System.Linq;
using Microsoft.Extensions.Logging;

namespace AutomationTask.Classes
{
    public class HTTPReponseBody
    {
        public string Identity { get; set; }
        public string Type { get; set; }
        public string HTMLNameSelected { get; set; }
        public List<HTTPResponseBodyParameter> HTTPResponseBodyParameters { get; set; }

        public HTTPReponseBody()
        {
        }

        public string GetRequestItem() {

            // Logger
            ILogger log;
            string value = null;

            // Perform a Lookup within the Configuration for:
            // 1: The correct _htmlObject (Matching TYPE, since type should be unique
            // 2: the corret parametername that matches HTMLNameSelected.

            try
            {
                var parameterName = HTMLConfiguration._htmlObject.SingleOrDefault(t => t.httpContent.Type == Type).
                AzureAutomationRunbook.Parameters.SingleOrDefault(p => p.HTMLName == HTMLNameSelected).Name;

                value = HTTPResponseBodyParameters.SingleOrDefault(p => p.Name == parameterName).Value;
            }
            catch (ArgumentNullException e)
            {
                throw new Exception("GetRequestItem() - Response was null. Not found.",e);
            } catch (InvalidOperationException e)
            {
                throw new Exception("GetRequestItem() - More then one item found.", e);
            }

            return value;
        }
        public string ConvertToJson()
        {
            return JsonConvert.SerializeObject(this);
        }
    }

    public class HTTPResponseBodyParameter
    {
        public string Name { get; set; }
        public string Value { get; set; }

        public HTTPResponseBodyParameter() { }
    }
}
