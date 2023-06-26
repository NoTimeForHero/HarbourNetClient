using System;
using System.Collections.Generic;
using System.Diagnostics;
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
        protected readonly KeepAliveService keepAlive;
        protected readonly MessageBus bus;
        protected readonly ProgramArgs options;
        protected readonly WatchableForm form;
        protected readonly HttpService http;

        public MainService(IUnityContainer container)
        {
            form = container.Resolve<WatchableForm>();
            options = container.Resolve<ProgramArgs>();
            http = container.Resolve<HttpService>();
            bus = container.Resolve<MessageBus>();
            keepAlive = container.Resolve<KeepAliveService>();
            form.Shown += OnInit;
            form.OnCopyDataMessage += (arg) => Task.Factory.StartNew(() => OnMessage(arg));
        }

        protected void OnInit(object o, EventArgs ev)
        {
            logger.Info("Current handle: " + form.Handle);
            logger.Info("Parent handle: " + options.HostHWND);

            var payload = form.Handle.ToString();
            var message = bus.Serialize(MessageBus.Types.Initialize, payload);
            Win32.SendDataToWindow(new IntPtr(options.HostHWND), message);
            if (options.Debug && Debugger.IsAttached && File.Exists("message.bin")) Win32.SendDataToWindow(form.Handle, File.ReadAllBytes("message.txt"));
        }

        protected async Task OnMessage(byte[] raw)
        {
            try
            {
                if (options.Debug && !Debugger.IsAttached) File.WriteAllBytes("message.bin", raw);
                if (options.Debug) logger.Debug($"[SendMessage] Recieved message {raw.Length} bytes!");
                var message = bus.Deserialize(raw);
                if (message == null) return;
                if (options.Debug) logger.Info($"Recieved message: {message.Type}");
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
            // Reset timer on any recognized packet
            keepAlive.Reset();

            switch (message.Type)
            {
                case MessageBus.Types.Request:
                    var request = JsonConvert.DeserializeObject<DataRequest>(message.Payload);
                    if (request == null) throw new NullReferenceException("Message deserialization failed!");
                    var key = request.Key;
                    logger.Info("Get new request with key: " + key);
                    byte[] binaryData = null;
                    DataResponse response;
                    try
                    {
                        var res = await http.SendRequest(request, message.Binary);
                        binaryData = res.Body;
                        response = new DataResponse { Key = key, Type = DataResponse.AllowedTypes.Success, Data = res.Details };
                    }
                    catch (Exception ex)
                    {
                        logger.Info("Request failed: " + ex.GetType().FullName + ": " + ex.Message);
                        logger.Debug(ex);
                        response = new DataResponse { Key = key, Type = DataResponse.AllowedTypes.Error, Data = ex };
                    }
                    var payload = bus.Serialize(MessageBus.Types.Response, JsonConvert.SerializeObject(response), binaryData);
                    Win32.SendDataToWindow(new IntPtr(options.HostHWND), payload);
                    break;
                case MessageBus.Types.KeepAlive:
                    if (options.Debug) logger.Trace("Keep Alive Packet!");
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
