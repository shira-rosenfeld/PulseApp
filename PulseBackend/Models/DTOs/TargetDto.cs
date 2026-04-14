namespace PulseBackend.Models.DTOs;

public class TargetDto
{
    public string Id { get; set; } = string.Empty;
    public string Type { get; set; } = "TARGET";
    public string Name { get; set; } = string.Empty;
    public TargetStatsDto Stats { get; set; } = new();
    public List<OutputDto> Children { get; set; } = new();
}