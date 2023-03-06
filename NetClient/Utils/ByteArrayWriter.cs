using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NetClient.Utils
{
    internal class ByteArrayWriter : IDisposable
    {
        private readonly MemoryStream stream;
        private readonly Encoding encoding;

        public ByteArrayWriter(Encoding encoding = null)
        {
            stream = new MemoryStream();
            this.encoding = encoding;
        }

        public void Write(byte[] target) => stream.Write(target, 0, target.Length);

        public ByteArrayWriter WriteString(string input)
        {
            Write(encoding.GetBytes(input));
            return this;
        }

        public ByteArrayWriter WriteInt(int number)
        {
            Write(BitConverter.GetBytes(number));
            return this;
        }

        public byte[] ToArray() => stream.ToArray();

        public void Dispose()
        {
            stream?.Dispose();
        }
    }
}
