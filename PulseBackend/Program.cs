// using Microsoft.AspNetCore.Authentication.Negotiate; // Re-enable with auth
using PulseBackend.Models.DTOs;

var builder = WebApplication.CreateBuilder(args);

// Configure Windows Authentication for AD SSO
// TODO: Re-enable for production (requires Active Directory / Windows host)
// builder.Services.AddAuthentication(NegotiateDefaults.AuthenticationScheme).AddNegotiate();
// builder.Services.AddAuthorization(options =>
// {
//     options.FallbackPolicy = options.DefaultPolicy;
// });

// Configure internal SAP API connection
builder.Services.AddHttpClient("SapApi", client =>
{
    client.BaseAddress = new Uri("https://sap-internal.network/api/");
});

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
app.MapGet("/api/v1/wbs/hierarchy", async (IHttpClientFactory clientFactory) =>
{
    var client = clientFactory.CreateClient("SapApi");
    // var response = await client.GetAsync("Z_API_PULSE_GET_HIERARCHY");
    return Results.Ok(new List<TargetDto>()); // Placeholder mock return
});

// 3. Delete / Cancel Task
app.MapDelete("/api/v1/tasks/{taskId}", async (string taskId, IHttpClientFactory clientFactory) =>
{
    var client = clientFactory.CreateClient("SapApi");
    return Results.Ok(new 
    { 
        message = $"Task {taskId} successfully canceled.",
        confirmationUrl = $"https://sap-internal.network/api/confirmations/{Guid.NewGuid()}"
    });
});

// 4. Report Hours
app.MapPost("/api/v1/tasks/report-hours", async (List<ReportHoursDto> reportData, IHttpClientFactory clientFactory) =>
{
    var client = clientFactory.CreateClient("SapApi");
    // Example: await client.PostAsJsonAsync("Z_API_PULSE_REPORT_HOURS", reportData);
    return Results.Ok(new { message = "Hours updated successfully." });
});

app.Run();