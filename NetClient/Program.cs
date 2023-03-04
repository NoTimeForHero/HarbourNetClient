using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Windows.Forms;
using CommandLine;
using CommandLine.Text;

namespace NetClient
{
    internal static class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            try
            {
                if (args.Length == 0) args = new[] { "--hwnd=0", "--ttl=60" };
                // MessageBox.Show(string.Join(", ", args));
                Run(args);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString(), "Fatal Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        static void Run(string[] args)
        {
            var parsed = Parser.Default.ParseArguments<ProgramArgs>(args);
            var errors = parsed.GetHumanReadableErrors().ToList();
            if (errors.Count > 0)
            {
                var message = "Invalid command line arguments:\n" + string.Join("\n", errors);
                MessageBox.Show(message, "Invalid CLI args!", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            var options = parsed.Value;
            var form = new FormDebug();
            form.Shown += (o, ev) =>
            {
                form.Log("My handle: " + form.Handle);
                form.Log("Parent handler: " + options.HostHWND);
                var payload = form.Handle.ToString();
                var message = MessageBus.Serialize(MessageBus.Types.Initialize, payload);
                Win32.SendDataToWindow(new IntPtr(options.HostHWND), message);
                // Win32.SendDataToWindow(form.Handle, File.ReadAllBytes("message.txt"));
            };
            form.OnCopyDataMessage += (raw) =>
            {
                // File.WriteAllBytes("message.txt", raw);
                var message = MessageBus.Deserialize(raw);
                if (message == null) return;
                MessageBox.Show(form, $"Message: {message.Type}\n{message.Payload}");
            };
            Application.Run(form);
        }
    }
}
