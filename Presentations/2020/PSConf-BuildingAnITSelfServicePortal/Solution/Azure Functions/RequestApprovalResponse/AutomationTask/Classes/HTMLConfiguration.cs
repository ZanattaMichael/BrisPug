using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using ConfigurationBuilder;
using Newtonsoft.Json;
using Microsoft.IdentityModel.Protocols;

namespace AutomationTask.Classes
{
    public static class HTMLConfiguration
    {
        public static readonly List<HTMLObject> _htmlObject;
        public static readonly string _htmlObjectSerialized;
        static HTMLConfiguration()
        {
            var config = GetConfig().Result;
            // TODO: ISSUES with Deserilization
            _htmlObject = JsonConvert.DeserializeObject<List<HTMLObject>>(config);
            _htmlObjectSerialized = config;
        }

        internal static async Task<string> GetConfig() {
            HttpResponseMessage output;
            string responseBody;

            Uri uri = new Uri($"{Environment.GetEnvironmentVariable("GetConfiguration")}?subscription-key={Environment.GetEnvironmentVariable("PSHelperSubscriptionKey")}");

            using (var client = new HttpClient())
            {
                output = await client.GetAsync(uri, CancellationToken.None);
                output.EnsureSuccessStatusCode();
                responseBody = await output.Content.ReadAsStringAsync();
            }
            return responseBody;
        }
    }
}
