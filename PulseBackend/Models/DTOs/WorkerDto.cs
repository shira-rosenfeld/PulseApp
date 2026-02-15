using PulseBackend.Models.Enums;

namespace PulseBackend.Models.DTOs
{
    public class WorkerDto
    {
        public string Name { get; set; } = string.Empty;
        public WorkerType Type { get; set; }
    }
}