using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using CommandLine;

namespace NetClient
{
    internal class ProgramArgs
    {
        [Option("hwnd", HelpText = "PID of the host to send message box", Required = true)]
        public long HostHWND { get; set; }

        [Option("ttl", HelpText = "TTL before application closes when no messages from the host", Required = true)]
        public long TTL { get; set; }

        [Option("encoding", HelpText = "Encoding for the messages (default windows-1251)", Default = "windows-1251")]
        public string encoding { get; set; }
    }
}
