using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Timers;
using System.Windows.Forms;
using NLog;
using Timer = System.Timers.Timer;

namespace NetClient.Services
{
    internal class KeepAliveService
    {
        protected readonly ILogger logger = LogManager.GetCurrentClassLogger();
        protected readonly Timer timer;

        public KeepAliveService(ProgramArgs options)
        {
            timer = new Timer
            {
                Interval = options.TTL * 1000,
                Enabled = true,
            };
            timer.Elapsed += Timer_Elapsed;
            timer.Start();
            logger.Info($"Initialized a keep-alive timer in {options.TTL} seconds!");
        }

        public void Reset()
        {
            logger.Debug("Reset timer");
            timer.Stop();
            timer.Start();
        }

        private void Timer_Elapsed(object sender, ElapsedEventArgs e)
        {
            logger.Warn("Timer elapsed! Application will be terminated!");
            Application.Exit();
        }
    }
}
