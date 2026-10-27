using System.Reflection;
using System.Runtime.CompilerServices;
using System.Text.Json;

namespace VeyraProbe;
public static class Entry
{
    public static void Main()
    {
        // Do not call upstream Main or constructor: no startup registration, monitoring or process control.
        var type = typeof(Skipify.SpotifyMonitorService);
        var instance = RuntimeHelpers.GetUninitializedObject(type);
        type.GetField("_debugLogPath", BindingFlags.NonPublic | BindingFlags.Instance)!
            .SetValue(instance, Path.Combine(Path.GetTempPath(), "veyra-p2-classifier.log"));
        var classify = type.GetMethod("IsAdvertisement", BindingFlags.NonPublic | BindingFlags.Instance)!;
        var cases = new[] {
            (Label: "empty", Title: "", Expected: false),
            (Label: "free-paused", Title: "Spotify Free", Expected: false),
            (Label: "premium-paused", Title: "Spotify Premium", Expected: false),
            (Label: "generic-loading", Title: "Spotify", Expected: false),
            (Label: "track", Title: "Artist - Song", Expected: false),
            (Label: "explicit-ad", Title: "Advertisement", Expected: true),
            (Label: "track-containing-keyword", Title: "Artist - Sponsored", Expected: false),
            (Label: "unknown-title", Title: "Loading", Expected: false)
        };
        var results = cases.Select(c => new {
            c.Label, c.Expected,
            Actual = (bool)classify.Invoke(instance, new object[] { c.Title })!
        }).ToArray();
        Console.WriteLine(JsonSerializer.Serialize(new {
            Mode = "upstream-classifier-only", Cases = results,
            Mismatches = results.Count(r => r.Expected != r.Actual),
            StartupInvoked = false, ProcessControlInvoked = false
        }));
    }
}
