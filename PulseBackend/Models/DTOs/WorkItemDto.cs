using PulseBackend.Models.Enums;

namespace PulseBackend.Models.DTOs
{
    public class WorkItemDto
    {
        public string Id { get; set; } = string.Empty;
        public string Type { get; set; } = "WORK_ITEM";
        public string Desc { get; set; } = string.Empty;
        public WorkItemStatus Status { get; set; }
        public WorkerDto Worker { get; set; } = new();
        public decimal Planned { get; set; }
        public decimal Actual { get; set; }
    }
}