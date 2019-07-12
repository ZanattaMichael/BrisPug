using PSWorkerService.Classes.API;
using PSWorkerService.Classes.JSONSchemas;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSWorkerService.Classes.Supporting {

    class ConvertFromBase64
    {

        public static string Invoke(string s) {

           return System.Text.Encoding.UTF8.GetString(System.Convert.FromBase64String(s));

        }

    }


}