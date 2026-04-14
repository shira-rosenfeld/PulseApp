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

        _parameters = new RfcConfigParameters
        {
            { RfcConfigParameters.AppServerHost, section["AppServerHost"]! },
            { RfcConfigParameters.SystemNumber,  section["SystemNumber"]!  },
            { RfcConfigParameters.SystemID,      section["SystemID"]!      },
            { RfcConfigParameters.Client,        section["Client"]!        },
            { RfcConfigParameters.User,          section["User"]!          },
            { RfcConfigParameters.Password,      section["Password"]!      },
            { RfcConfigParameters.Language,      section["Language"]!      },
            { RfcConfigParameters.PoolSize,      section["PoolSize"]!      },
            { RfcConfigParameters.MaxPoolSize,   section["MaxPoolSize"]!   },
        };
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
