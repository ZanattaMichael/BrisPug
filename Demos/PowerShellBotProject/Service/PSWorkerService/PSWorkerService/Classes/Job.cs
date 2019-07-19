using PSWorkerService.Classes.API;
using PSWorkerService.Classes.JSONSchemas;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Management.Automation;
using System.Collections.ObjectModel;
using Newtonsoft.Json;


namespace PSWorkerService.Classes
{
    class Job
    {

        public HTTPRequestJob httpRequestJobs { get; set; }

        // Default Construcutor
        public Job()
        {

        }

        public static void Process()  {

            // Create a Job
            Job j = new Job();

            //
            // Request some Jobs from the API
            j.httpRequestJobs = RESTHandler.requestNewJobs();

            // Iterate Through Each of the Jobs and Execute the PowerShell Async
            foreach (HTTPRequestJobDetail job in j.httpRequestJobs.jobs) {

                // Create a Response Object
                HTTPSendJob httpSendJob = new HTTPSendJob(job.GUID);

                // Execute the Job
                try
                {                
                    // Decode the Base64 InputCliXML
                    string decoded = Supporting.ConvertFromBase64.Invoke(job.CLIXML);
                    // Execute the PowerShell Job
                    httpSendJob.ResponseBody = j.ExecuteJob(decoded);
                    httpSendJob.StatusCode = "Completed";
                   
                } catch
                {
                    // Capture an Error
                    httpSendJob.StatusCode = "Error";

                } finally
                {
                    RESTHandler.sendResponseJob(httpSendJob);
                }

            }   

        }


        private string ExecuteJob(string scriptBlock) {

            using (System.Management.Automation.PowerShell PowerShellInstance = System.Management.Automation.PowerShell.Create())
            {

                // Parameter String Array
                List<string> ParamArray = new List<string>();

                // Join the Array
                string param = string.Join(" ",ParamArray.ToArray());

                // Build the Wrapper
                string wrapper = $"Function Invoke-Wrapper{{{scriptBlock}}}; Invoke-Wrapper | ConvertTo-Json -Compress -Depth 1 ";
                                
                // Add the Script to the Instance
                PowerShellInstance.AddScript(wrapper);

                // Invoke the Execution
                var result = PowerShellInstance.Invoke();

                // Seralize the Output
                return Supporting.ConvertFromBase64.Invoke(result.ToString());

            }

        }



    }
}
