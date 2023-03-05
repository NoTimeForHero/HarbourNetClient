using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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

        public byte[] Serialize(string type, string payload)
        {
            if (type.Length != TYPE_LEN) throw new ArgumentException(
                $"Длина типа сообщения должна быть равна ${TYPE_LEN} символов!", nameof(type));
            var builder = new StringBuilder(PREFIX.Length + TYPE_LEN + payload.Length);
            builder.Append(PREFIX);
            builder.Append(type);
            builder.Append(payload);
            return encoding.GetBytes(builder.ToString());
        }

        public Message Deserialize(byte[] input)
        {
            if (input.Length < PREFIX.Length + TYPE_LEN) return null;
            var stream = input;

            var prefix = encoding.GetString(stream.Skip(0).Take(PREFIX.Length).ToArray());
            if (prefix != PREFIX) return null;

            var type = encoding.GetString(stream.Skip(PREFIX.Length).Take(TYPE_LEN).ToArray());
            var payload = encoding.GetString(stream.Skip(PREFIX.Length + TYPE_LEN).ToArray());

            return new Message { Type = type, Payload = payload};
        }

        public class Message
        {
            public string Type { get; set; }
            public string Payload { get; set; }
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
