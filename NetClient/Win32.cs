using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

namespace NetClient
{
    public class Win32
    {
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern IntPtr FindWindowEx(IntPtr hwndParent, IntPtr hwndChildAfter, string className, string windowName);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern IntPtr SendMessage(IntPtr hWnd, uint msg, IntPtr wParam, ref COPYDATASTRUCT lParam);

        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        static extern uint RegisterWindowMessage(string lpString);

        public const uint WM_COPYDATA = 74;

        public struct COPYDATASTRUCT
        {
            public IntPtr dwData;
            public int cbData;
            public IntPtr lpData;

            public byte[] getData()
            {
                byte[] data = new byte[cbData];
                Marshal.Copy(lpData, data, 0, cbData);
                return data;
            }
        }

        public static void SendDataToWindow(IntPtr target, byte[] bytes)
        {
            var allocated = Marshal.AllocHGlobal(bytes.Length);
            var cds = new COPYDATASTRUCT
            {
                dwData = new IntPtr(3),
                cbData = bytes.Length,
                lpData = allocated
            };
            Marshal.Copy(bytes, 0, cds.lpData, bytes.Length);
            SendMessage(target, WM_COPYDATA, IntPtr.Zero, ref cds);
            Marshal.FreeHGlobal(allocated);
        }
    }
}
