﻿using System;
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

        public static int DebugCounter = 0;

        public async Task<Response> SendRequest(DataRequest input, byte[] requestBody)
        {
            var query = input.Query;
            logger.Info($"HTTP Request: {query.Method} {query.Url}");

            var request = new HttpRequestMessage(new HttpMethod(query.Method), query.Url);
            string contentType = "text/plain";


            if (query.Headers != null)
            {
                logger.Debug("Headers: ");
                foreach (var pair in query.Headers)
                {
                    logger.Debug($"{pair.Key}: {pair.Value}");
                    if (pair.Key.ToLower() == "content-type")
                    {
                        contentType = pair.Value.Split(';')[0];
                    }
                    else
                    {
                        // Protection from headers like "Content-Type":
                        //  https://stackoverflow.com/questions/10679214/how-do-you-set-the-content-type-header-for-an-httpclient-request
                        request.Headers.TryAddWithoutValidation(pair.Key, pair.Value);
                    }
                }
            }

            if (requestBody != null && requestBody.Length > 0)
            {
                if (query.RequestBodyBinary) throw new NotImplementedException("Binary body is not supported yet!");
                else
                {
                    var content = requestBody.ToString(options.Parsed.Encoding);
                    request.Content = new StringContent(content, Encoding.UTF8, contentType);
                }
            }

            var watcher = Stopwatch.StartNew();
            var response = await client.SendAsync(request);
            var responseHeaders = response.Headers
                .ToDictionary(x => x.Key, x => string.Join(";", x.Value));
            var body = await response.Content.ReadAsByteArrayAsync();
            watcher.Stop();

            if (query.ResponseBodyBinary) throw new NotImplementedException("Binary body is not supported yet!");
            else
            {
                // TODO: Find correct server response encoding
                body = Encoding.Convert(Encoding.UTF8, options.Parsed.Encoding, body);
            }

            var elapsed = (int)watcher.Elapsed.TotalMilliseconds;
            logger.Info($"Response {(int)response.StatusCode} {response.StatusCode} in {elapsed} ms with {body.Length} bytes length!");

            var isSuccess = (int)response.StatusCode >= 200 && (int)response.StatusCode <= 299;

            var details = new Dictionary<string, object>
            {
                {"Success", isSuccess},
                {"Headers", responseHeaders},
                {"LoadingTimeMs", elapsed},
                {"StatusCode",  (int)response.StatusCode}
            };

            return new Response { Details = details, Body = body };
        }

        public class Response
        {
            public Dictionary<string, object> Details { get; set; }
            public byte[] Body { get; set; }
        }
    }
}
