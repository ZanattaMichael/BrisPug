using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSWorkerService.Classes.JSONSchemas
{
    class HTTPRequestJob
    {
        public string GUID { get; set; }
        public string CLIXML { get; set; }
        public string error { get; set; }
    }
}
