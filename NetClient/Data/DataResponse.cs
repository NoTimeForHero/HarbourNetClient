using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NetClient.Data
{
    internal class DataResponse
    {
        public string Key { get; set; }
        public string Type { get; set; }
        public object Data { get; set; }

        public class AllowedTypes
        {
            public const string Error = "Error";
            public const string Success = "Success";
        }
    }
}
