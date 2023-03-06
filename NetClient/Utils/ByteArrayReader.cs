using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NetClient.Utils
{
    internal class ByteArrayReader : IDisposable
    {
        private readonly int maxLength;
        private readonly MemoryStream stream;

        public ByteArrayReader(byte[] input)
        {
            maxLength = input.Length;
            stream = new MemoryStream(input);
        }

        private byte[] Slice(int length)
        {
            byte[] slice = new byte[length];
            int readed = stream.Read(slice, 0, length);
            if (readed < length) throw new InvalidOperationException($"Readed only {readed} bytes instead of {length}!");
            return slice;
        }

        public int ReadInteger()
            => BitConverter.ToInt32(Slice(4), 0);

        public string ReadString(int length, Encoding encoding)
            => encoding.GetString(Slice(length));

        public byte[] Read(int length) => Slice(length);

        public byte[] ReadToEnd()
        {
            int length = (int)(maxLength - stream.Position);
            return Slice(length);
        }

        public void Dispose()
        {
            stream?.Dispose();
        }
    }
}
