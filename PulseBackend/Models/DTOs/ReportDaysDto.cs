namespace PulseBackend.Models.DTOs
{
    public class ReportDaysDto
    {
        public string TaskId { get; set; } = string.Empty;
        public decimal DaysReported { get; set; }
    }
}
