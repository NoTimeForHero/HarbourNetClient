using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace NetClient
{
    public class WatchableForm : Form
    {
        public virtual void Log(string message) {}

        public event Action<byte[]> OnCopyDataMessage;

        protected override void WndProc(ref Message m)
        {
            if (m.Msg == Win32.WM_COPYDATA)
            {
                // MessageBox.Show("COPYDATA!");
                var cds = (Win32.COPYDATASTRUCT)m.GetLParam(typeof(Win32.COPYDATASTRUCT));
                var data = cds.getData();

                // var message = "DWData: " + cds.dwData + "\n";
                // message += "Length: " + cds.cbData + "\n";
                // message += Encoding.GetEncoding(1251).GetString(data);
                // Task.Factory.StartNew(() =>
                // {
                //     MessageBox.Show(message, "SendMessage", MessageBoxButtons.OK, MessageBoxIcon.Question);
                // });
                // File.WriteAllBytes("message.txt", data);

                OnCopyDataMessage?.Invoke(data);
            }
            base.WndProc(ref m);
        }
    }
}
