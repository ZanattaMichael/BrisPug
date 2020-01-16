using System;
using System.Collections.Generic;
using System.Management.Automation;
using System.Collections.ObjectModel;
using OnPremConnector.Classes.SQL;
using Newtonsoft.Json;

namespace OnPremConnector.Classes.PowerShell
{
    class PowerShellHandler
    {

        public Collection<PSObject> PSOutput;

        public void execute(string scriptBlock, List<PowerShellParameter> powerShellParameters = null)
        {

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

    public class PowerShellParameter {

        public string ParameterName { get; set; }
        public string ParameterValue { get; set; }

    }


}
