using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using CommandLine;
using CommandLine.Text;

namespace NetClient
{
    internal static class Extensions
    {

        public static IEnumerable<string> GetHumanReadableErrors<T>(this ParserResult<T> result)
        {
            if (!(result is NotParsed<T>)) return Enumerable.Empty<string>();
            var builder = SentenceBuilder.Create();
            return HelpText.RenderParsingErrorsTextAsLines(result, builder.FormatError, builder.FormatMutuallyExclusiveSetErrors, 1);
        }

        public static string ToString(this byte[] bytes, Encoding encoding)
            => encoding.GetString(bytes);

    }
}
