import StripeTerminal

extension ConnectionConfigurationApi {
    func toHost() throws -> ConnectionConfiguration? {
        switch self {
        case let config as BluetoothConnectionConfigurationApi:
            return try BluetoothConnectionConfigurationBuilder()
                .setTimeout(UInt(config.timeout ?? 0))
                .setSimulated(config.isSimulated)
                .build()
        case let config as HandoffConnectionConfigurationApi:
            return try BluetoothConnectionConfigurationBuilder()
                .setTimeout(UInt(config.timeout ?? 0))
                .setSimulated(config.isSimulated)
                .build()
        case _ as HandoffDiscoveryConfigurationApi:
            return nil
        case let config as InternetConnectionConfigurationApi:
            return try BluetoothConnectionConfigurationBuilder()
                .setTimeout(UInt(config.timeout ?? 0))
                .setSimulated(config.isSimulated)
                .build()
        case let config as TapToPayConnectionConfigurationApi:
            return try BluetoothConnectionConfigurationBuilder()
                .setTimeout(UInt(config.timeout ?? 0))
                .setSimulated(config.isSimulated)
                .build()
        case _ as UsbConnectionConfigurationApi:
            return nil
        default:
            fatalError()
        }
    }
}
