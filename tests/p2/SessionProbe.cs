using System.Text.Json;
using Windows.Media.Control;

var manager = await GlobalSystemMediaTransportControlsSessionManager.RequestAsync();
var sessions = manager.GetSessions().Where(s => s.SourceAppUserModelId.Contains("Spotify", StringComparison.OrdinalIgnoreCase)).ToArray();
if (args.Contains("--play"))
{
    if (sessions.Length != 1) throw new InvalidOperationException("Expected one Spotify multimedia session before playback control.");
    Console.WriteLine(JsonSerializer.Serialize(new { Action = "TargetedPlay", Success = await sessions[0].TryPlayAsync() }));
}
Console.WriteLine(JsonSerializer.Serialize(new {
    SpotifySessions = sessions.Length,
    Sessions = sessions.Select(s => new {
        Status = s.GetPlaybackInfo().PlaybackStatus.ToString(),
        Position = s.GetTimelineProperties().Position.TotalMilliseconds,
        UpdatedAt = s.GetTimelineProperties().LastUpdatedTime
    })
}));
