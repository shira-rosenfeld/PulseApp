// using Microsoft.AspNetCore.Authentication.Negotiate; // Re-enable with auth
using PulseBackend.Models.DTOs;
using PulseBackend.Services;

var builder = WebApplication.CreateBuilder(args);

// Configure Windows Authentication for AD SSO
// TODO: Re-enable for production (requires Active Directory / Windows host)
// builder.Services.AddAuthentication(NegotiateDefaults.AuthenticationScheme).AddNegotiate();
// builder.Services.AddAuthorization(options =>
// {
//     options.FallbackPolicy = options.DefaultPolicy;
// });

// Configure internal SAP API connection (base URL loaded from appsettings.json)
builder.Services.AddHttpClient("SapApi", (sp, client) =>
{
    var config = sp.GetRequiredService<IConfiguration>();
    client.BaseAddress = new Uri(config["SapApi:BaseUrl"]!);
});

builder.Services.AddScoped<ISapApiService, SapApiService>();

var app = builder.Build();

// app.UseAuthentication();
// app.UseAuthorization();

// 1. User Profile Endpoint (Determines Manager vs Worker)
// TODO: When auth is re-enabled, replace mock with AD group check:
//   bool isManager = context.User.IsInRole("Pulse_Managers");
//   Username = context.User.Identity?.Name
app.MapGet("/api/v1/user/profile", (HttpContext context) =>
{
    return Results.Ok(new
    {
        Username = "anonymous",
        Role = "Worker"  // Change to "Manager" to test the manager view
    });
});

// 2. Fetch Hierarchy
app.MapGet("/api/v1/wbs/hierarchy", async (ISapApiService sapApi) =>
{
    var hierarchy = await sapApi.GetHierarchyAsync();
    return Results.Ok(hierarchy);
});

// 3. Delete / Cancel Task
app.MapDelete("/api/v1/tasks/{taskId}", async (string taskId, ISapApiService sapApi) =>
{
    if (string.IsNullOrWhiteSpace(taskId))
        return Results.BadRequest(new { error = "taskId is required." });

    await sapApi.CancelTaskAsync(taskId);
    return Results.Ok(new
    {
        message = $"Task {taskId} successfully canceled.",
        confirmationUrl = $"https://sap-internal.network/api/confirmations/{Guid.NewGuid()}"
    });
});

// 4. Report Days
app.MapPost("/api/v1/tasks/report-days", async (List<ReportDaysDto> reportData, ISapApiService sapApi) =>
{
    if (reportData is null || reportData.Count == 0)
        return Results.BadRequest(new { error = "reportData must not be empty." });

    await sapApi.ReportDaysAsync(reportData);
    return Results.Ok(new { message = "Days updated successfully." });
});

app.Run();
