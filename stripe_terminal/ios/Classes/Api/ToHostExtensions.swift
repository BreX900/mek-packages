import Foundation
import StripeTerminal

extension PaymentIntentParametersApi {
    func toHost() throws -> PaymentIntentParameters {
        return try PaymentIntentParametersBuilder(
                amount: UInt(amount),
                currency: currency
            )
            .setPaymentMethodTypes(paymentMethodTypes.map { $0.toHost() })
            .setCaptureMethod(captureMethod.toHost())
            .build()
    }
}

extension PaymentMethodTypeApi {
    func toHost() -> String {
        switch (self) {
        case .cardPresent:
            return "card_present"
        case .card:
            return "card"
        case .interactPresent:
            return "interact_present"
        }
    }
}

extension CaptureMethodApi {
    func toHost() -> CaptureMethod {
        switch (self) {
        case .automatic:
            return .automatic
        case .manual:
            return .manual
        }
    }
}

extension DiscoveryConfigurationApi {
    func toHost() throws -> DiscoveryConfiguration? {
        switch self {
        case let config as BluetoothDiscoveryConfigurationApi:
            return try BluetoothScanDiscoveryConfigurationBuilder()
                .setTimeout(UInt(config.timeout ?? 0))
                .setSimulated(config.isSimulated)
                .build()
        case let config as BluetoothProximityDiscoveryConfigurationApi:
            return try BluetoothProximityDiscoveryConfigurationBuilder()
                .setSimulated(config.isSimulated)
                .build()
        case _ as HandoffDiscoveryConfigurationApi:
            return nil
        case let config as InternetDiscoveryConfigurationApi:
            return try InternetDiscoveryConfigurationBuilder()
                .setSimulated(config.isSimulated)
                .setLocationId(config.locationId)
                .build()
        case let config as LocalMobileDiscoveryConfigurationApi:
            return try LocalMobileDiscoveryConfigurationBuilder()
                .setSimulated(config.isSimulated)
                .build()
        case _ as UsbDiscoveryConfigurationApi:
            return nil
        default:
            fatalError()
        }
    }
    
    func toHostDiscoveryMethod() -> DiscoveryMethod? {
        switch self {
        case _ as BluetoothDiscoveryConfigurationApi:
            return .bluetoothScan
        case _ as BluetoothProximityDiscoveryConfigurationApi:
            return .bluetoothProximity
        case _ as HandoffDiscoveryConfigurationApi:
            return nil
        case _ as InternetDiscoveryConfigurationApi:
            return .internet
        case _ as LocalMobileDiscoveryConfigurationApi:
            return .localMobile
        case _ as UsbDiscoveryConfigurationApi:
            return nil
        default:
            fatalError()
        }
    }
    
    func toHostSimulated() -> Bool {
        switch self {
        case let config as BluetoothDiscoveryConfigurationApi:
            return config.isSimulated
        case let config as BluetoothProximityDiscoveryConfigurationApi:
            return config.isSimulated
        case _ as HandoffDiscoveryConfigurationApi:
            return false
        case let config as InternetDiscoveryConfigurationApi:
            return config.isSimulated
        case let config as LocalMobileDiscoveryConfigurationApi:
            return config.isSimulated
        case _ as UsbDiscoveryConfigurationApi:
            return false
        default:
            fatalError()
        }
    }
}

extension DeviceTypeApi {
    func toHost() -> DeviceType? {
        switch self {
        case .chipper2X:
            return .chipper2X
        case .verifoneP400:
            return .verifoneP400
        case .wisePad3:
            return .wisePad3
        case .stripeM2:
            return .stripeM2
        case .wisePosE:
            return .wisePosE
        case .wisePosEDevkit:
            return .wisePosEDevKit
        case .etna:
            return .etna
        case .chipper1X:
            return .chipper1X
        case .wiseCube:
            return .wiseCube
        case .stripeS700:
            return .stripeS700
        case .stripeS700Devkit:
            return .stripeS700DevKit
        case .appleBuiltIn:
            return .appleBuiltIn
        case .cotsDevice, .wisePad3s:
            return nil
        }
    }
}


extension CartApi {
    func toHost() throws -> Cart {
        return try CartBuilder(currency: currency)
            .setTax(tax)
            .setTotal(total)
            .setLineItems(lineItems.map { try $0.toHost()} )
            .build()
    }
}

extension CartLineItemApi {
    func toHost() throws -> CartLineItem {
        return try CartLineItemBuilder(displayName: description)
            .setAmount(amount)
            .setQuantity(quantity)
            .build()
    }
}

extension SetupIntentUsageApi {
    func toHost() -> SetupIntentUsage {
        switch self {
        case .offSession:
            return .offSession
        case .onSession:
            return .onSession
        }
    }
}
