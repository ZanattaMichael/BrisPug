using PSWorkerService.Classes.API;
using PSWorkerService.Classes.JSONSchemas;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PSWorkerService.Classes.Supporting
{

    class ConvertToBase64
    {

        public static string Invoke(string s)
        {

            return System.Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(s));

        }

    }


}