using PulseBackend.Models.DTOs;

namespace PulseBackend.Services;

public interface ISapApiService
{
    Task<List<TargetDto>> GetHierarchyAsync();
    Task CancelTaskAsync(string taskId);
    Task ReportDaysAsync(List<ReportDaysDto> reportData);
}
