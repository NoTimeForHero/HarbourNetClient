using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using CommandLine;
using NetClient.Forms;
using NetClient.Services;
using NLog;
using Unity;

namespace NetClient
{
    internal class Entrypoint
    {
        private static readonly ILogger logger = LogManager.GetCurrentClassLogger();

        public static void Run(string[] args)
        {
            logger.Info("Application started");
            logger.Info("CLI args: " + (args.Length > 0 ? string.Join(", ", args) : "[Empty]"));

            if (args.Length == 0)
            {
                args = new[] { "--hwnd=0", "--ttl=30", "--debug" };
                logger.Info("Overriding args with debug values: " + string.Join(", ", args));
            }

            try
            {
                InternalRun(args);
            }
            catch (Exception ex)
            {
                logger.Fatal(ex);
                throw;
            }
        }

        static void InternalRun(string[] args)
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
            parsed.Value.Parsed.Encoding = Encoding.GetEncoding(parsed.Value.Encoding ?? "windows-1251");

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            var container = new UnityContainer();

            if (parsed.Value.Debug) container.RegisterType<WatchableForm, FormDebug>();
            else container.RegisterType<WatchableForm, FormHidden>();

            container.RegisterSingleton<MainService>();
            container.RegisterSingleton<HttpService>();
            container.RegisterInstance(parsed.Value);
            container.Resolve<MainService>().Run();
        }

    }
}
