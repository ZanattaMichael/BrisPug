using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Net.Http;
using System.Text;
using AutomationTask.Classes;
using System.Configuration;

namespace AutomationTask
{
    public static class TestConfiguration
    {
        [FunctionName("TestConfiguration")]
        public static async Task<bool> Invoke([ActivityTrigger] HTTPReponseBody reponseBody, ILogger log)
        {
            
            HttpResponseMessage result;

            log.LogInformation($"TestConfiguration Triggered:");

            var url = Environment.GetEnvironmentVariable("TestConfiguration");

            // Seralize the Response
            string json = reponseBody.ConvertToJson();

            // Call the PowerShell Function and Wait for a Response
            using (var client = new HttpClient())
            {
                StringContent stringContent = new StringContent(json, Encoding.UTF8, "application/json");
                stringContent.Headers.Add("Ocp-Apim-Subscription-Key", Environment.GetEnvironmentVariable("PSHelperSubscriptionKey"));
                result = await client.PostAsync(url, stringContent);
                log.LogDebug($"[TestConfiguration] Response Status Code:", result.StatusCode);
            }

            // Return the result
            return result.IsSuccessStatusCode
                ? true
                : false;

        }
    }
}
