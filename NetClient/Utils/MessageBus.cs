using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NetClient.Utils;

namespace NetClient
{
    internal class MessageBus
    {
        public readonly Encoding encoding;
        public const string PREFIX = "AV_HTTP";
        public const int TYPE_LEN = 4;

        public MessageBus(ProgramArgs args)
        {
            encoding = args.Parsed.Encoding;
        }

        public byte[] Serialize(string type, string payload, byte[] binary = null)
        {
            if (type.Length != TYPE_LEN) throw new ArgumentException(
                $"Длина типа сообщения должна быть равна ${TYPE_LEN} символов!", nameof(type));
            using (var writer = new ByteArrayWriter(encoding))
            {
                writer.WriteString(PREFIX);
                writer.WriteString(type);
                writer.WriteInt(payload.Length);
                writer.WriteString(payload);
                writer.Write(binary ?? Array.Empty<byte>());
                return writer.ToArray();
            }
        }

        public Message Deserialize(byte[] input)
        {
            if (input.Length < PREFIX.Length + TYPE_LEN) return null;
            using (var reader = new ByteArrayReader(input, encoding))
            {
                var prefix = reader.ReadString(PREFIX.Length);
                if (prefix != PREFIX) return null;

                var type = reader.ReadString(TYPE_LEN);
                var payloadSize = reader.ReadInteger();
                var payload = reader.ReadString(payloadSize);
                var binary = reader.ReadToEnd();

                return new Message
                {
                    Type = type,
                    Payload = payload,
                    Binary = binary
                };
            }
        }

        public class Message
        {
            public string Type { get; set; }
            public string Payload { get; set; }
            public byte[] Binary { get; set; }
        }

        public static class Types
        {
            public const string Initialize = "INIT";
            public const string Response = "RESP";
            public const string Request = "REQT";
            public const string KeepAlive = "LIVE";
        }
    }
}
