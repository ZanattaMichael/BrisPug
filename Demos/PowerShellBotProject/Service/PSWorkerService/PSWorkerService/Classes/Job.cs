using PSWorkerService.Classes.API;
using PSWorkerService.Classes.JSONSchemas;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSWorkerService.Classes
{
    class Job
    {

        public List<HTTPRequestJob> httpRequestJobs { get; set; }

        // Default Construcutor
        public Job()
        {

            //
            // Requests some Jobs

            httpRequestJobs = RESTHandler.requestNewJobs();

            // Iterate Through Each of the Jobs and Exectre the PowerShell Async



        }


    }
}
