using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSWorkerService.Classes.JSONSchemas
{
    class HTTPSendJob
    {
        public string GUID { get; set; }
        public string ResponseBody { get; set; }
        public string StatusCode { get; set; }

        public HTTPSendJob()
        {
        }

        // Overloaded Constructor
        public HTTPSendJob(string guid)
        {
            this.GUID = guid;
        }

    }
}
