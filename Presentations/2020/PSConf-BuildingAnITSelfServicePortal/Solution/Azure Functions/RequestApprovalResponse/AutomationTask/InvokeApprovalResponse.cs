using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace AutomationTask
{
    public static class InvokeApprovalResponse
    {
        [FunctionName("InvokeApprovalResponse")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post")] HttpRequest req,
            [OrchestrationClient]DurableOrchestrationClient client,
            ILogger log)
        {
            
            log.LogInformation("C# HTTP trigger function processed a request.");

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);

            string instanceId = data?.instanceId;
            string approvalStatus = data?.selectedOption;

            if (instanceId != null && approvalStatus != null) {
                await client.RaiseEventAsync(instanceId, approvalStatus, true);
                return new OkResult();
            } else
            {
                return new BadRequestResult();
            }

        }
    }
}
