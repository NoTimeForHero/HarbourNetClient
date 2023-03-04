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

namespace NetClient
{
    public partial class FormDebug : WatchableForm
    {
        public FormDebug()
        {
            InitializeComponent();
            textBox1.Text = "";
        }

        public override void Log(string message)
        {
            textBox1.Text += message + "\r\n";
        }
    }
}
