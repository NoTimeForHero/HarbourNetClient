using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using NetClient.Data;
using Newtonsoft.Json;
using NLog;
using Unity;

namespace NetClient.Services
{
    internal class MainService
    {
        protected readonly ILogger logger = LogManager.GetCurrentClassLogger();
        protected readonly ProgramArgs options;
        protected readonly WatchableForm form;
        protected readonly HttpService http;

        public MainService(IUnityContainer container)
        {
            form = container.Resolve<WatchableForm>();
            options = container.Resolve<ProgramArgs>();
            http = container.Resolve<HttpService>();
            form.Shown += OnInit;
            form.OnCopyDataMessage += (arg) => Task.Factory.StartNew(() => OnMessage(arg));
        }

        protected void OnInit(object o, EventArgs ev)
        {
            logger.Info("Current handle: " + form.Handle);
            logger.Info("Parent handle: " + options.HostHWND);

            var payload = form.Handle.ToString();
            var message = MessageBus.Serialize(MessageBus.Types.Initialize, payload);
            Win32.SendDataToWindow(new IntPtr(options.HostHWND), message);
            Win32.SendDataToWindow(form.Handle, File.ReadAllBytes("message.txt"));
        }

        protected async Task OnMessage(byte[] raw)
        {
            try
            {
                logger.Debug($"[SendMessage] Recieved message {raw.Length} bytes!");
                // File.WriteAllBytes("message.txt", raw);
                var message = MessageBus.Deserialize(raw);
                if (message == null) return;
                logger.Info($"Recieved message: {message.Type}");
                await OnRecognizedMessage(message);
            }
            catch (Exception ex)
            {
                logger.Warn("Message processing failed!");
                logger.Warn(ex);
            }
        }

        protected async Task OnRecognizedMessage(MessageBus.Message message)
        {
            switch (message.Type)
            {
                case MessageBus.Types.Request:
                    var request = JsonConvert.DeserializeObject<DataRequest>(message.Payload);
                    if (request == null) throw new NullReferenceException("Message deserialization failed!");
                    var key = request.Key;
                    logger.Info("Get new request with key: " + key);
                    DataResponse response;
                    try
                    {
                        var res = await http.SendRequest(request);
                        response = DataResponse.Complete(key, res);
                    }
                    catch (Exception ex)
                    {
                        response = DataResponse.Error(key, ex);
                    }

                    var payload = MessageBus.Serialize(MessageBus.Types.Response, JsonConvert.SerializeObject(response));
                    Win32.SendDataToWindow(new IntPtr(options.HostHWND), payload);
                    break;
                default:
                    logger.Warn("Invalid message type: " + message.Type);
                    break;
            }
            //MessageBox.Show(form, $"Message: {message.Type}\n{message.Payload}");
        }

        public void Run()
        {
            Application.Run(form);
        }

    }
}
