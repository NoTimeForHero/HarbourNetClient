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
        public ResponseType Type { get; set; }
        public object Data { get; set; }

        public enum ResponseType
        {
            Success = 1,
            Exception = 2
        }

        public static DataResponse Error(string key, System.Exception ex)
            => new DataResponse { Key = key, Type = ResponseType.Exception, Data = ex };
        public static DataResponse Complete(string key, Http data)
            => new DataResponse { Key = key, Type = ResponseType.Success, Data = data };

        public class Http
        {
            public bool Success { get; set; }
            public int LoadingTimeMs { get; set; }
            public int StatusCode { get; set; }
            public string Response { get; set; }
            public Dictionary<string, string> Headers { get; set; }
        }
    }
}
