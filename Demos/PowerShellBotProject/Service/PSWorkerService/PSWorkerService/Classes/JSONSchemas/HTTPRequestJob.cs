using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSWorkerService.Classes.JSONSchemas
{
    class HTTPRequestJob
    {

        public <List<HTTPRequestJobDetails>> jobs { get; set; }
        public string error { get; set; }
    }

    class HTTPRequestJobDetails {

        public string GUID { get; set; }
        public string CLIXML { get; set; } 

    }

}
