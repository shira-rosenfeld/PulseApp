using SAP.Middleware.Connector;

namespace PulseBackend.Services;

/// <summary>
/// Supplies SAP RFC connection parameters to the NCo destination manager.
/// Reads from the "SapSettings:MySapConnection" section in appsettings.json.
///
/// For production: move credentials out of appsettings.json into a secrets manager
/// (Azure Key Vault, AWS Secrets Manager, environment variables, etc.) and read
/// them here via IConfiguration — no code changes required.
/// </summary>
public sealed class SapDestinationConfig : IDestinationConfiguration
{
    private const string DestinationName = "MySapConnection";

    private readonly RfcConfigParameters _parameters;

    public SapDestinationConfig(IConfiguration configuration)
    {
        var section = configuration.GetSection($"SapSettings:{DestinationName}");

        // Use explicit indexer assignment (the documented NCo pattern) rather than
        // collection initializer syntax, which requires Add(string,string) and is
        // not guaranteed by the RfcConfigParameters API contract.
        _parameters = new RfcConfigParameters();
        _parameters[RfcConfigParameters.AppServerHost] = section["AppServerHost"]!;
        _parameters[RfcConfigParameters.SystemNumber]  = section["SystemNumber"]!;
        _parameters[RfcConfigParameters.SystemID]      = section["SystemID"]!;
        _parameters[RfcConfigParameters.Client]        = section["Client"]!;
        _parameters[RfcConfigParameters.User]          = section["User"]!;
        _parameters[RfcConfigParameters.Password]      = section["Password"]!;
        _parameters[RfcConfigParameters.Language]      = section["Language"]!;
        _parameters[RfcConfigParameters.PoolSize]      = section["PoolSize"]!;
        _parameters["MAX_POOL_SIZE"]                   = section["MaxPoolSize"]!;  // RfcConfigParameters.MaxPoolSize removed in NCo 3.1
    }

    public RfcConfigParameters GetParameters(string destinationName)
    {
        if (destinationName == DestinationName)
            return _parameters;

        throw new InvalidOperationException(
            $"Unknown SAP destination: '{destinationName}'. Expected '{DestinationName}'.");
    }

    // Static configuration does not fire change events.
    public bool ChangeEventsSupported() => false;

#pragma warning disable 67
    public event RfcDestinationManager.ConfigurationChangeHandler? ConfigurationChanged;
#pragma warning restore 67
}
