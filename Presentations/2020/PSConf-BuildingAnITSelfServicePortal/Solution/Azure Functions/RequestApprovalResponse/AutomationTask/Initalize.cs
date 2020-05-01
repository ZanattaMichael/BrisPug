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
using System.Threading;
using System.Net;
using System.Security.Claims;
using AutomationTask.Classes;

namespace AutomationTask
{
    public static class Initialize
    {
        [FunctionName("Initialize")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", "options", Route = null)] HttpRequestMessage req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            // Authentication boilerplate code start
            ClaimsPrincipal principal;
            if ((principal = await Security.ValidateTokenAsync(req.Headers.Authorization)) == null)
            {
               return new UnauthorizedResult();
            }

            // Return the configuration to the user
            return new OkObjectResult(HTMLConfiguration._htmlObjectSerialized);

        }
    }
}
