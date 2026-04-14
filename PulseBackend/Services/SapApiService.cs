using PulseBackend.Models.DTOs;

namespace PulseBackend.Services;

public class SapApiService : ISapApiService
{
    private readonly HttpClient _client;

    public SapApiService(IHttpClientFactory httpClientFactory)
    {
        _client = httpClientFactory.CreateClient("SapApi");
    }

    public async Task<List<TargetDto>> GetHierarchyAsync()
    {
        // TODO: Uncomment once SAP API is available
        // var response = await _client.GetAsync("Z_API_PULSE_GET_HIERARCHY");
        // response.EnsureSuccessStatusCode();
        // return await response.Content.ReadFromJsonAsync<List<TargetDto>>() ?? [];
        return await Task.FromResult(new List<TargetDto>());
    }

    public async Task CancelTaskAsync(string taskId)
    {
        // TODO: Uncomment once SAP API is available
        // var response = await _client.DeleteAsync($"Z_API_PULSE_CANCEL_TASK/{taskId}");
        // response.EnsureSuccessStatusCode();
        await Task.CompletedTask;
    }

    public async Task ReportDaysAsync(List<ReportDaysDto> reportData)
    {
        // TODO: Uncomment once SAP API is available
        // var response = await _client.PostAsJsonAsync("Z_API_PULSE_REPORT_DAYS", reportData);
        // response.EnsureSuccessStatusCode();
        await Task.CompletedTask;
    }
}
