namespace PulseBackend.Models.DTOs
{
    public class OutputDto
    {
        public string Id { get; set; } = string.Empty;
        public string Type { get; set; } = "OUTPUT";
        public string Name { get; set; } = string.Empty;
        public List<WorkItemDto> Children { get; set; } = new();
    }
}