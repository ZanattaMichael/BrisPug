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
    public static class InvokeApprovalRequest
    {
        [FunctionName("InvokeApprovalRequest")]
        public static async void Invoke([ActivityTrigger] MicrosoftTeamsApproval teamsApprovalCard, ILogger log)
        {
            
            log.LogInformation($"InvokeApprovalRequest Triggered:");

            var url = Environment.GetEnvironmentVariable("MicrosoftTeamsLogicApp");

            foreach (String owner in teamsApprovalCard.Owners)
            {
                // Generate a response URL

                var json = teamsApprovalCard.ConvertToJson(owner);

                using (var client = new HttpClient())
                {
                    StringContent stringContent = new StringContent(json, Encoding.UTF8, "application/json");
                    stringContent.Headers.Add("Ocp-Apim-Subscription-Key", Environment.GetEnvironmentVariable("LogicAppSubscriptionKey"));
                    await client.PostAsync(url, stringContent);
                }
            }
        }
    }
}
