import StripeTerminal

extension ConnectionConfigurationApi {
    func toHost(_ delegate: ReaderDelegatePlugin) throws -> ConnectionConfiguration? {
        switch self {
        case let config as BluetoothConnectionConfigurationApi:
            return try BluetoothConnectionConfigurationBuilder(
                delegate: delegate,
                locationId: config.locationId
            )
            .setAutoReconnectOnUnexpectedDisconnect(config.autoReconnectOnUnexpectedDisconnect)
            .build()
        case let config as HandoffConnectionConfigurationApi:
            return nil
        case let config as InternetConnectionConfigurationApi:
            return try InternetConnectionConfigurationBuilder(
                delegate: delegate
            )
            .setFailIfInUse(config.failIfInUse)
            .build()
        case let config as TapToPayConnectionConfigurationApi:
            return try TapToPayConnectionConfigurationBuilder(
                delegate: delegate,
                locationId: config.locationId
            )
            .setAutoReconnectOnUnexpectedDisconnect(config.autoReconnectOnUnexpectedDisconnect)
            .setTosAcceptancePermitted(config.tosAcceptancePermitted)
            .build()
        case _ as UsbConnectionConfigurationApi:
            return nil
        default:
            fatalError()
        }
    }
}