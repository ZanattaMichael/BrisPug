using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Security.Claims;
using System.Threading.Tasks;
using AutomationTask.Classes;
using ConfigurationBuilder;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace AutomationTask
{
    public static class InvokeRequest
    {

        [FunctionName("InvokeRequest")]
        public static async Task<bool> RunOrchestrator(
            [OrchestrationTrigger] DurableOrchestrationContext context,
            ILogger log)
        {

            log.LogInformation("InvokeRequest Durable Function Started:");

            // Refer to: https://docs.microsoft.com/en-us/azure/azure-functions/durable/durable-functions-bindings
            HTTPReponseBody reponseBody;
            MicrosoftTeamsApproval teamsApprovalCard;
            string json;

            try
            {
                json = context.GetInput<String>();
                reponseBody = JsonConvert.DeserializeObject<HTTPReponseBody>(json);
                teamsApprovalCard = new MicrosoftTeamsApproval(context.InstanceId, reponseBody);
            }
            catch (Exception e)
            {
                Terminate.StopFunction("An Error Occured Attempting to Deserialize the Object", log, e);
                return false;
            }

            // Validate the Response to the Configuration
            bool result = await context.CallActivityAsync<bool>("TestConfiguration", reponseBody);

            if (!result)
                Terminate.StopFunction("Validation Failed", log);

            //
            // Send the Request to Microsoft Teams for Approval

            // Set a Custom Status of "Requesting Approval"
            context.SetCustomStatus("RequestingApproval");
            var approvalRequestResult = await context.CallActivityAsync<MicrosoftTeamsApproval>("InvokeApprovalRequest", teamsApprovalCard);

            //
            // Wait for the Response. In this case we are waiting for an event to be raised.
            var ApprovalEvent = context.WaitForExternalEvent("Approve");
            var DenyEvent = context.WaitForExternalEvent("Deny");
            var response = await Task.WhenAny(ApprovalEvent, DenyEvent);

            //
            // Action the Result. We are going to trigger an Azure Automation Runbook

            context.SetCustomStatus("InvokingRunbook");

            if (response == DenyEvent)
            {
                context.SetCustomStatus("RequestDenied");
                return false;
            }

            //
            // Get the Configuration

            HTMLObject config;
            List<HTMLObject> configs = HTMLConfiguration._htmlObject;
            // Use Linq to Join the Type to the Type within the Configuration
            try
            {
                config = configs.SingleOrDefault(c => c.httpContent.Type == reponseBody.Type);
            }
            catch (InvalidOperationException i)
            {
                Terminate.StopFunction(
                    "Could not match JSON response to Configuration. Zero or Multiple Items were returned. " +
                    "Please check that the configuration typename is unique for each configuration.", log, i);
                return false;
            }
            catch (Exception e)
            {
                Terminate.StopFunction("Could not match JSON response to Configuration. Source or Predicate is null.", log, e);
                return false;
            }

            //
            // Build the Runbook Job
            AutomationRunbookJob automationRunbook = new AutomationRunbookJob
            {
                AutomationAccountName = Environment.GetEnvironmentVariable("AutomationAccountName"),
                ResourceGroupName = Environment.GetEnvironmentVariable("ResourceGroupName"),
                RunOn = Environment.GetEnvironmentVariable("HybridRunbookWorkerGroup"),
                Name = config.AzureAutomationRunbook.Name,
                Parameters = new Dictionary<string, string>()
            };

            reponseBody.HTTPResponseBodyParameters.ForEach(c => automationRunbook.Parameters.Add(c.Name, c.Value));

            //
            // Call the Runbook
            RetryOptions retry = new RetryOptions(new TimeSpan(0, 5, 0), 3);

            await context.CallActivityWithRetryAsync("StartRunbook", retry, automationRunbook);

            // Completed
            return true;

        }

        [FunctionName("InvokeRequest_HttpStart")]
        public static async Task<HttpResponseMessage> HttpStart(
            [HttpTrigger(AuthorizationLevel.Function, "post")]HttpRequestMessage req,
            [OrchestrationClient]DurableOrchestrationClient starter,
            ILogger log)
        {
            
            log.LogInformation("InvokeRequest_HttpStart Function Triggered:");

            // Authentication Validation;
            ClaimsPrincipal principal;

            if ((principal = await Security.ValidateTokenAsync(req.Headers.Authorization)) == null)
            {
                return new HttpResponseMessage(System.Net.HttpStatusCode.Unauthorized);
            }

            string json = req.Content.ReadAsStringAsync().Result;

            // Empty Request
            if (string.IsNullOrEmpty(json))
            {
                log.LogError("Request Body is Empty");
                return new HttpResponseMessage(System.Net.HttpStatusCode.BadRequest);
            }

            log.LogInformation($"JSON Body: {json}");
            // Append the Claims Principal to the JSON Request
            dynamic data = JsonConvert.DeserializeObject(json);

            data.Identity = principal.Identity.Name;
            json = JsonConvert.SerializeObject(data);

            //
            // Trigger the Automation Workflow
            log.LogInformation("InvokeRequest_HttpStart Start New Async: InvokeRequest", json);
            string instanceId = await starter.StartNewAsync("InvokeRequest", json);

            log.LogInformation($"Started orchestration with ID = '{instanceId}'.");

            //return starter.CreateCheckStatusResponse(req, instanceId);

            // Dont return the instance ID back to the caller
            return new HttpResponseMessage(System.Net.HttpStatusCode.OK);
            //return starter.CreateCheckStatusResponse(req, instanceId);
        }
    }
}