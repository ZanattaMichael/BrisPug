using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Azure.Management.Automation;
using Microsoft.Azure.Management.Automation.Models;
using System.Net.Http;
using System.Text;
using AutomationTask.Classes;
using System.Configuration;

namespace AutomationTask
{
    public static class StartRunbook
    {
        [FunctionName("StartRunbook")]
        public static async Task TaskAsync([ActivityTrigger] AutomationRunbookJob Params, ILogger log)
        {

            string url = Environment.GetEnvironmentVariable("StartRunbook");
            var json = JsonConvert.SerializeObject(Params);

            using (var client = new HttpClient())
            {

                
                StringContent stringContent = new StringContent(json, Encoding.UTF8, "application/json");
                stringContent.Headers.Add("Ocp-Apim-Subscription-Key", Environment.GetEnvironmentVariable("PSHelperSubscriptionKey"));
                var response = await client.PostAsync(url, stringContent);
            }

            

           // log.LogInformation($"Runbook Started: Job Id: {job.Job.Id}");

        }
    }
}
