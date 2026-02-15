namespace PulseBackend.Models.DTOs
{
    public class ReportHoursDto
    {
        public string TaskId { get; set; } = string.Empty;
        public decimal HoursReported { get; set; }
    }
}