using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Windows.Forms;
using CommandLine;
using CommandLine.Text;
using NetClient.Services;
using Newtonsoft.Json;
using NLog;
using Unity;

namespace NetClient
{
    internal static class Program
    {
        private static readonly ILogger logger = LogManager.GetCurrentClassLogger();

        [STAThread]
        static void Main(string[] args)
        {
            try
            {
                logger.Info("Application started");
                logger.Info("CLI args: " + (args.Length > 0 ? string.Join(", ", args) : "[Empty]"));

                if (args.Length == 0)
                {
                    args = new[] { "--hwnd=0", "--ttl=60" };
                    logger.Info("Overriding args with debug values: " + string.Join(", ", args));
                }

                Run(args);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString(), "Fatal Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                logger.Fatal(ex);
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
                logger.Fatal(message);
                return;
            }

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            var container = new UnityContainer();
            container.RegisterType<WatchableForm, FormDebug>();
            container.RegisterSingleton<MainService>();
            container.RegisterSingleton<HttpService>();
            container.RegisterInstance(parsed.Value);
            container.Resolve<MainService>().Run();
        }
    }
}
