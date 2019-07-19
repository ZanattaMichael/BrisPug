using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSWorkerService.Classes.JSONSchemas
{
    class HTTPRequestJob
    {

        public List<HTTPRequestJobDetail> jobs { get; set; }
        public string error { get; set; }
    }

    class HTTPRequestJobDetail {

        public string GUID { get; set; }
        public string CLIXML { get; set; } 

    }

}
