using SAP.Middleware.Connector;

namespace PulseBackend.Services;

/// <summary>
/// Supplies SAP RFC connection parameters to the NCo destination manager.
/// Reads from the "SapSettings:MySapConnection" section in appsettings.json.
///
/// Authentication uses SNC (Secure Network Communications) SSO: the process
/// identity (Windows service account / Kerberos) is presented to SAP instead
/// of a username and password.  No User/Password keys are read or sent.
///
/// Required configuration keys:
///   SncPartnerName  – SAP server's SNC principal name, e.g. "p:CN=SID,O=Corp,C=US"
///   SncQop          – Quality of protection: 1=auth, 2=integrity, 3=privacy,
///                     8=system default (recommended), 9=maximum
///   SncLib          – (optional) absolute path to the GSSAPI/Kerberos library
///                     (e.g. gsskrb5.dll or sapcrypto.dll). When omitted the
///                     system-wide SNC_LIB environment variable is used.
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
        _parameters[RfcConfigParameters.Language]      = section["Language"]!;
        _parameters[RfcConfigParameters.PoolSize]      = section["PoolSize"]!;
        _parameters["MAX_POOL_SIZE"]                   = section["MaxPoolSize"]!;  // RfcConfigParameters.MaxPoolSize removed in NCo 3.1

        // SNC SSO — enables Kerberos/Windows-identity logon; User/Password are not used.
        _parameters["SNC_MODE"]        = "1";
        _parameters["SNC_PARTNERNAME"] = section["SncPartnerName"]!;
        _parameters["SNC_QOP"]         = section["SncQop"] ?? "8";

        var sncLib = section["SncLib"];
        if (!string.IsNullOrEmpty(sncLib))
            _parameters["SNC_LIB"] = sncLib;
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
