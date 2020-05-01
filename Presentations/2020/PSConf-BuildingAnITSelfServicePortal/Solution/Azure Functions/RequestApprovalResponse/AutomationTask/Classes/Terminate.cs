using Microsoft.Azure.WebJobs;
using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.Extensions.Logging;

namespace AutomationTask.Classes
{
    static class Terminate
    {

        public static void StopFunction(string message, 
                                        ILogger log, 
                                        Exception exception = null)
        {
            
            if (exception != null)
            {
                log.LogError(exception, message);
            } else {
                log.LogError(message);
            }
        }
    }
}
