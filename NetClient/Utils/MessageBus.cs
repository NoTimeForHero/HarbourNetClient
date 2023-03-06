﻿using System;
using System.Collections.Generic;
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
            using (var reader = new ByteArrayReader(input))
            {
                var prefix = reader.ReadString(PREFIX.Length, encoding);
                if (prefix != PREFIX) return null;

                var type = reader.ReadString(TYPE_LEN, encoding);
                var payloadSize = reader.ReadInteger();
                var payload = reader.ReadString(payloadSize, encoding);
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
