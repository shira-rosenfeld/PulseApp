using PulseBackend.Models.DTOs;
using PulseBackend.Models.Enums;
using SAP.Middleware.Connector;

namespace PulseBackend.Services;

/// <summary>
/// Implements ISapApiService via direct RFC calls using SAP .NET Connector 3.1 (NCo).
///
/// All function module names, table names, and field names marked TODO must be confirmed
/// with the SAP ABAP team before this can run against a real SAP system.
///
/// RFC calls are synchronous (NCo design); wrapped in Task.Run to avoid blocking ASP.NET
/// Core thread pool threads.
/// </summary>
public class SapApiService : ISapApiService
{
    // Must match the key in appsettings.json under SapSettings and SapDestinationConfig.
    private const string DestinationName = "MySapConnection";

    private readonly ILogger<SapApiService> _logger;

    public SapApiService(ILogger<SapApiService> logger)
    {
        _logger = logger;
    }

    /// <summary>
    /// Fetches the full WBS hierarchy from SAP (Targets → Outputs → Work Items).
    /// </summary>
    public Task<List<TargetDto>> GetHierarchyAsync()
    {
        return Task.Run(() =>
        {
            _logger.LogInformation("Calling SAP RFC for WBS hierarchy.");

            var destination = RfcDestinationManager.GetDestination(DestinationName);

            // TODO: Replace with the actual RFC function module name.
            var func = destination.Repository.CreateFunction("Z_RFC_PULSE_GET_HIERARCHY");

            // TODO: Set any required IMPORT parameters before invoking, e.g.:
            // func.SetValue("IV_USER", currentUser);

            func.Invoke(destination);

            // TODO: Replace "ET_TARGETS", "ET_OUTPUTS", "ET_WORK_ITEMS" with actual
            //       ABAP table parameter names exported by the function module.
            var targetsTable   = func.GetTable("ET_TARGETS");
            var outputsTable   = func.GetTable("ET_OUTPUTS");
            var workItemsTable = func.GetTable("ET_WORK_ITEMS");

            var targets = new List<TargetDto>();

            for (int i = 0; i < targetsTable.Count; i++)
            {
                IRfcStructure targetRow = targetsTable[i];

                // TODO: Replace all field name strings with actual ABAP field names.
                var target = new TargetDto
                {
                    Id   = targetRow.GetString("TARGET_ID"),
                    Name = targetRow.GetString("TARGET_NAME"),
                    Type = "TARGET",
                    Stats = new TargetStatsDto
                    {
                        Total      = targetRow.GetInt("STAT_TOTAL"),
                        Done       = targetRow.GetInt("STAT_DONE"),
                        InProgress = targetRow.GetInt("STAT_IN_PROGRESS"),
                        New        = targetRow.GetInt("STAT_NEW"),
                    },
                };

                for (int j = 0; j < outputsTable.Count; j++)
                {
                    IRfcStructure outputRow = outputsTable[j];

                    // TODO: Replace "TARGET_ID" with the actual FK field linking outputs to targets.
                    if (outputRow.GetString("TARGET_ID") != target.Id) continue;

                    var output = new OutputDto
                    {
                        Id   = outputRow.GetString("OUTPUT_ID"),
                        Name = outputRow.GetString("OUTPUT_NAME"),
                        Type = "OUTPUT",
                    };

                    for (int k = 0; k < workItemsTable.Count; k++)
                    {
                        IRfcStructure wiRow = workItemsTable[k];

                        // TODO: Replace "OUTPUT_ID" with the actual FK field linking work items to outputs.
                        if (wiRow.GetString("OUTPUT_ID") != output.Id) continue;

                        output.Children.Add(new WorkItemDto
                        {
                            Id      = wiRow.GetString("TASK_ID"),
                            Desc    = wiRow.GetString("TASK_DESC"),
                            Type    = "WORK_ITEM",
                            Planned = wiRow.GetDecimal("PLANNED_DAYS"),
                            Actual  = wiRow.GetDecimal("ACTUAL_DAYS"),
                            // TODO: Confirm the field name and value mapping for WorkItemStatus.
                            Status  = MapWorkItemStatus(wiRow.GetString("STATUS")),
                            Worker  = new WorkerDto
                            {
                                // TODO: Confirm field names and value mapping for WorkerType.
                                Name = wiRow.GetString("WORKER_NAME"),
                                Type = MapWorkerType(wiRow.GetString("WORKER_TYPE")),
                            },
                        });
                    }

                    target.Children.Add(output);
                }

                targets.Add(target);
            }

            return targets;
        });
    }

    /// <summary>
    /// Cancels a task in SAP via RFC.
    /// </summary>
    public Task CancelTaskAsync(string taskId)
    {
        return Task.Run(() =>
        {
            _logger.LogInformation("Calling SAP RFC to cancel task {TaskId}.", taskId);

            var destination = RfcDestinationManager.GetDestination(DestinationName);

            // TODO: Replace with the actual RFC function module name.
            var func = destination.Repository.CreateFunction("Z_RFC_PULSE_CANCEL_TASK");

            // TODO: Replace "IV_TASK_ID" with the actual ABAP IMPORT parameter name.
            func.SetValue("IV_TASK_ID", taskId);

            func.Invoke(destination);

            // TODO: Check any EXPORT parameters or a BAPIRET2 return structure for
            //       application-level errors and throw if the RFC reports a failure.
        });
    }

    /// <summary>
    /// Reports days for a list of tasks in SAP via RFC.
    /// </summary>
    public Task ReportDaysAsync(List<ReportDaysDto> reportData)
    {
        return Task.Run(() =>
        {
            _logger.LogInformation("Calling SAP RFC to report days for {Count} tasks.", reportData.Count);

            var destination = RfcDestinationManager.GetDestination(DestinationName);

            // TODO: Replace with the actual RFC function module name.
            var func = destination.Repository.CreateFunction("Z_RFC_PULSE_REPORT_DAYS");

            // TODO: Replace "IT_REPORT_DATA" with the actual ABAP TABLE parameter name.
            var inputTable = func.GetTable("IT_REPORT_DATA");

            foreach (var item in reportData)
            {
                inputTable.Append();
                IRfcStructure row = inputTable.CurrentRow;

                // TODO: Replace "TASK_ID" and "DAYS_REPORTED" with actual ABAP field names
                //       in the table structure. If the RFC expects separate Planned/Actual
                //       fields, update ReportDaysDto and add both SetValue calls here.
                row.SetValue("TASK_ID",       item.TaskId);
                row.SetValue("DAYS_REPORTED", item.DaysReported);
            }

            func.Invoke(destination);

            // TODO: Check any EXPORT parameters or a BAPIRET2 return structure for
            //       application-level errors and throw if the RFC reports a failure.
        });
    }

    // -------------------------------------------------------------------------
    // Mapping helpers
    // -------------------------------------------------------------------------

    /// <summary>
    /// Maps a SAP status code string to WorkItemStatus.
    /// TODO: Confirm the exact SAP status values with the ABAP team.
    ///       Values below assume SAP returns the numeric code as a string ("10", "20", …).
    /// </summary>
    private static WorkItemStatus MapWorkItemStatus(string sapStatus) => sapStatus switch
    {
        "10" => WorkItemStatus.New,
        "20" => WorkItemStatus.InProgress,
        "30" => WorkItemStatus.OnHold,
        "40" => WorkItemStatus.Done,
        "90" => WorkItemStatus.Canceled,
        _    => WorkItemStatus.New, // TODO: Decide whether to throw on unknown values.
    };

    /// <summary>
    /// Maps a SAP worker type string to WorkerType.
    /// TODO: Confirm the exact SAP field values with the ABAP team.
    /// </summary>
    private static WorkerType MapWorkerType(string sapType) => sapType switch
    {
        "INT" => WorkerType.Internal,
        "EXT" => WorkerType.External,
        _     => WorkerType.Internal, // TODO: Decide whether to throw on unknown values.
    };
}
