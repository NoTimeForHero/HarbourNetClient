using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using NLog;
using NLog.Targets;

namespace NetClient
{
    public partial class FormDebug : WatchableForm
    {
        private MemoryTarget target;

        public FormDebug()
        {
            InitializeComponent();
            textLogs.Text = "";

            target = LogManager.Configuration.AllTargets.OfType<MemoryTarget>().FirstOrDefault();
            timerRefreshLogs_Tick(null, null);
        }

        private void timerRefreshLogs_Tick(object sender, EventArgs e)
        {
            if (target == null) return;
            textLogs.Text = string.Join(Environment.NewLine, target.Logs);
        }
    }
}
