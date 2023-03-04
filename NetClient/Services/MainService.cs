using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using NLog;

namespace NetClient.Services
{
    internal class MainService
    {
        protected ILogger logger = LogManager.GetCurrentClassLogger();
        protected WatchableForm form;

        public MainService(WatchableForm form, ProgramArgs options)
        {
            this.form = form;
            form.Shown += (o, ev) =>
            {
                logger.Info("Current handle: " + form.Handle);
                logger.Info("Parent handle: " + options.HostHWND);

                var payload = form.Handle.ToString();
                var message = MessageBus.Serialize(MessageBus.Types.Initialize, payload);
                Win32.SendDataToWindow(new IntPtr(options.HostHWND), message);
                // Win32.SendDataToWindow(form.Handle, File.ReadAllBytes("message.txt"));
            };
            form.OnCopyDataMessage += (raw) =>
            {
                logger.Debug($"[SendMessage] Recieved message {raw.Length} bytes!");
                // File.WriteAllBytes("message.txt", raw);
                var message = MessageBus.Deserialize(raw);
                if (message == null) return;

                logger.Info($"Recieved message: {message.Type}");
                //MessageBox.Show(form, $"Message: {message.Type}\n{message.Payload}");
            };
        }

        public void Run()
        {
            Application.Run(form);
        }

    }
}
