using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net.Http;
using Newtonsoft.Json;
using PSWorkerService.Classes.JSONSchemas;

namespace PSWorkerService.Classes.API
{
    class RESTHandler
    {

        private static async Task<String> invoke(Uri uri, HttpMethod method, string body = null)
        {

            // Define the Response Body
            string HTTPBody = null;

            // Create the Object
            HttpRequestMessage httpRequestMessage = new HttpRequestMessage(method, uri);

            // Append the Body if not null
            if (body != null)
            {
                httpRequestMessage.Content = new StringContent(body, Encoding.UTF8, "application/json");
            }

            // Craft our Sexy HTTP Request
            using (HttpClient httpClient = new HttpClient())
            {
                try
                {
                    // Send the Request
                    var HTTPResponse = await httpClient.SendAsync(httpRequestMessage);
                    HTTPBody = await HTTPResponse.Content.ReadAsStringAsync();

                } catch (Exception e)
                {
                    //TODO Add Handler to handle response
                }               
            }

            // Return 
            return HTTPBody;
                     
        }

        public static HTTPRequestJob requestNewJobs()
        {
            // Define the Response Body
            HTTPRequestJob httpRequestJobs = null;

            //
            // The URI requires a query string to be appended to it.
 
            // Create a URI
            Uri uri = new Uri($"{Service1.URLRequestJob}?ComputerName={System.Environment.MachineName}");

            // Call the Rest Handler
            string response = RESTHandler.invoke(uri, HttpMethod.Get).Result;

            //
            // Seraialize the Response

            try
            {
                httpRequestJobs = JsonConvert.DeserializeObject<HTTPRequestJob>(response);
            } catch (Exception e)
            {
                //TODO: EVENT HANDLE THIS
                return null;
            }

            // Return to the Parent
            return httpRequestJobs;

        }

        public static Task<String> sendNewJobs()
        {
            //
            // The URI requires a query string to be appended to it.

            // Create a URI
            Uri uri = new Uri($"{Service1.URLRequestJob}?ComputerName={System.Environment.MachineName}");

            // Call the Rest Handler capture the response
            
            


        }


    }
}
