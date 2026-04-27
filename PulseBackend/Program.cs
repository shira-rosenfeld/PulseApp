// using Microsoft.AspNetCore.Authentication.Negotiate; // Re-enable with auth
using System.Reflection;
using PulseBackend.Models.DTOs;
using PulseBackend.Services;
using SAP.Middleware.Connector;

// SAP NCo 3.1 is a C++/CLI (IJW) assembly. When its native layer loads managed
// compat shims (System.Configuration.ConfigurationManager, Microsoft.Win32.Registry)
// by strong name, the .NET runtime's base-directory probing does not fire, so the
// assemblies are not found even though they are physically present next to the .exe.
// This resolver bridges that gap: it catches any resolution failure and loads the
// matching .dll from the application directory. Must be registered before any NCo
// type is first accessed (i.e. before WebApplication.CreateBuilder).
AppDomain.CurrentDomain.AssemblyResolve += (_, args) =>
{
    string name = new AssemblyName(args.Name!).Name!;
    string path = Path.Combine(AppContext.BaseDirectory, name + ".dll");
    return File.Exists(path) ? Assembly.LoadFrom(path) : null;
};

var builder = WebApplication.CreateBuilder(args);

// Configure Windows Authentication for AD SSO
// TODO: Re-enable for production (requires Active Directory / Windows host)
// builder.Services.AddAuthentication(NegotiateDefaults.AuthenticationScheme).AddNegotiate();
// builder.Services.AddAuthorization(options =>
// {
//     options.FallbackPolicy = options.DefaultPolicy;
// });

RfcDestinationManager.RegisterDestinationConfiguration(new SapDestinationConfig(builder.Configuration));

// SapApiService has no per-request state; Singleton matches the NCo destination lifetime.
builder.Services.AddSingleton<ISapApiService, SapApiService>();

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
        // TODO: Replace with an actual confirmation reference returned from the SAP RFC
        //       (e.g., a document number from an EXPORT parameter of Z_RFC_PULSE_CANCEL_TASK).
        //       CancelTaskAsync must be updated to return that value once the RFC contract is known.
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
