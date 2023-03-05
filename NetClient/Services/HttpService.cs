using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using NetClient.Data;
using Newtonsoft.Json;
using NLog;

namespace NetClient.Services
{
    internal class HttpService
    {
        protected readonly ILogger logger = LogManager.GetCurrentClassLogger();
        protected readonly HttpClient client;
        protected readonly ProgramArgs options;

        public HttpService(ProgramArgs options)
        {
            client = new HttpClient();
            this.options = options;
        }

        public async Task<DataResponse.Http> SendRequest(DataRequest input)
        {
            var query = input.Query;
            logger.Info($"HTTP Request: {query.Method} {query.Url}");

            var request = new HttpRequestMessage(new HttpMethod(query.Method), query.Url);


            if (query.Body != null) request.Content = new StringContent(query.Body);
            if (query.Headers != null)
            {
                logger.Debug("Headers: ");
                foreach (var pair in query.Headers)
                {
                    logger.Debug($"{pair.Key}: {pair.Value}");
                    // Protection from headers like "Content-Type":
                    //  https://stackoverflow.com/questions/10679214/how-do-you-set-the-content-type-header-for-an-httpclient-request
                    request.Headers.TryAddWithoutValidation(pair.Key, pair.Value);
                }
            }

            var watcher = Stopwatch.StartNew();
            var response = await client.SendAsync(request);
            var responseHeaders = response.Headers
                .ToDictionary(x => x.Key, x => string.Join(";", x.Value));
            var body = await response.Content.ReadAsStringAsync();
            watcher.Stop();


            var elapsed = (int)watcher.Elapsed.TotalMilliseconds;
            logger.Info($"Response {(int)response.StatusCode} {response.StatusCode} in {elapsed} ms with {body.Length} bytes length!");

            var result = new DataResponse.Http
            {
                Success = (int)response.StatusCode >= 200 && (int)response.StatusCode <= 299,
                Headers = responseHeaders,
                LoadingTimeMs = elapsed,
                StatusCode = (int)response.StatusCode,
                Response = body
            };
            return result;
        }
    }
}
