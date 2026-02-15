namespace PulseBackend.Models.DTOs
{
    public class TargetDto
    {
        public string Id { get; set; } = string.Empty;
        public string Type { get; set; } = "TARGET";
        public string Name { get; set; } = string.Empty;
        public object Stats { get; set; } = new { total = 0, done = 0 };
        public List<OutputDto> Children { get; set; } = new();
    }
}