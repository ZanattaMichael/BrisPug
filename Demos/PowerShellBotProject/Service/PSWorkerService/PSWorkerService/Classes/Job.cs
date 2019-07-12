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

        public GetJobs()  {


            //
            // Request some Jobs from the API
            httpRequestJobs = RESTHandler.requestNewJobs();

            // Iterate Through Each of the Jobs and Execute the PowerShell Async
            foreach (HTTPRequestJobDetail job in httpRequestJobs.jobs) {
                
                // DeEncode the Base64 InputCliXML
                string decoded = Classes.Supporting.ConvertFromBase64.Invoke(job.CLIXML);

            
            }


        }


        public ExecuteJob(string scriptBlock, List<PowerShellParameter> powerShellParameters = null) {

            using (System.Management.Automation.PowerShell PowerShellInstance = System.Management.Automation.PowerShell.Create())
            {

                // Parameter String Array
                List<string> ParamArray = new List<string>();

                // Build the Parameters
                if (powerShellParameters != null)
                {
                    foreach (PowerShellParameter parameter in powerShellParameters)
                    {
                        ParamArray.Add($"-{parameter.ParameterName} {parameter.ParameterValue}");
                    }
                }

                // Join the Array
                string param = string.Join(" ",ParamArray.ToArray());

                // Build the Wrapper
                string wrapper = $"Function Invoke-Wrapper{{{scriptBlock}}}; Invoke-Wrapper {param} | Out-String | ConvertTo-Json -Compress -Depth 1 ";
                                
                // Add the Script to the Instance
                PowerShellInstance.AddScript(wrapper);

                // Invoke the Execution
                this.PSOutput = PowerShellInstance.Invoke();

            }


        }



    }
}
