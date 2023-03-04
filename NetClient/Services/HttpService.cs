using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using NetClient.Data;
using NLog;

namespace NetClient.Services
{
    internal class HttpService
    {
        protected readonly ILogger logger = LogManager.GetCurrentClassLogger();
        protected readonly HttpClient client;

        public HttpService()
        {
            client = new HttpClient();
        }

        public async Task SendRequest(DataRequest input)
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

            var response = await client.SendAsync(request);
            var body = await response.Content.ReadAsByteArrayAsync();
            logger.Info($"Response {response.StatusCode} with {body.Length} bytes length!");
        }
    }
}
