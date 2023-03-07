using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NetClient.Forms
{
    internal class FormHidden : WatchableForm
    {
        public FormHidden()
        {
            ShowInTaskbar = false;
            Shown += FormHidden_Shown;
            FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
        }

        private void FormHidden_Shown(object sender, EventArgs e)
        {
            Width = 1;
            Height = 1;
            Left = 12000;
            Top = 12000;
            Visible = false;

        }
    }
}
