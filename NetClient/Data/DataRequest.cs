using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace NetClient.Data
{
    internal class DataRequest
    {
        [JsonProperty(Required = Required.Always)]
        public string Key { get; set; }

        [JsonProperty(Required = Required.Always)]
        public Request Query { get; set; }

        public class Request
        {
            [JsonProperty(Required = Required.Always)]
            public string Url { get; set; }

            [JsonProperty(Required = Required.Always)]
            public string Method  { get; set; }

            [JsonProperty(Required = Required.Default)]
            public Dictionary<string, string> Headers { get; set; }

            [JsonProperty(Required = Required.Default)]
            public string Body { get; set; }
        }
    }
}
