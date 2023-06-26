using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using CommandLine;
using CommandLine.Text;
using NetClient.Forms;
using NetClient.Services;
using Newtonsoft.Json;
using NLog;
using Unity;

namespace NetClient
{
    internal static class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            try
            {
                Entrypoint.Run(args);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString(), "Fatal Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }
}
