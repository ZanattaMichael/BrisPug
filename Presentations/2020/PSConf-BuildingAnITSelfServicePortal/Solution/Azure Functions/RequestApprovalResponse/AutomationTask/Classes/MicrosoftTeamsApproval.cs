using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Text;
using System.Linq;
using System.Configuration;

namespace AutomationTask.Classes
{
    public class MicrosoftTeamsApproval
    {
        public string InstanceID { get; set; }
        public string Message { get; set; }
        public string URLResponse = Environment.GetEnvironmentVariable("MicrosoftTeamsCallbackURL");
        public string[] Owners { get; set; }
        public string Owner { get; set; }

        public MicrosoftTeamsApproval()
        {
        }

        public MicrosoftTeamsApproval(string instanceId,
                                      HTTPReponseBody reponseBody)

        {

            var requestedItem = reponseBody.GetRequestItem();

            this.InstanceID = instanceId;
            this.Message = $"IT Automated Approval Request: {reponseBody.Identity} has requested access to: {requestedItem}.";
            this.Owners = this.GetOwners(reponseBody);
        }

        internal string[] GetOwners(HTTPReponseBody reponseBody)
        {
            return HTMLConfiguration._htmlObject.SingleOrDefault(
                h => h.httpContent.Type == reponseBody.Type).httpContent.Owners;
        }

        public string ConvertToJson(string owner)
        {
            this.Owner = owner;
            return JsonConvert.SerializeObject(this);
        }

    }
}
