import Foundation
import StripeTerminal


extension Reader {
    func toApi() -> ReaderApi {
        return ReaderApi(
            availableUpdate: availableUpdate != nil,
            batteryLevel: batteryLevel?.doubleValue ?? -1.0,
            deviceType: deviceType.toApi(),
            label: label,
            location: location?.toApi(),
            locationId: locationId,
            locationStatus: locationStatus.toApi(),
            serialNumber: serialNumber,
            simulated: simulated
        )
    }
}

extension Location {
    func toApi() -> LocationApi {
        return LocationApi(
            address: address?.toApi(),
            displayName: displayName,
            id: stripeId,
            livemode: livemode,
            metadata: metadata ?? [:]
        )
    }
}


extension Address {
    func toApi() -> AddressApi? {
        return AddressApi(
            city: city,
            country: country,
            line1: line1,
            line2: line2,
            postalCode: postalCode,
            state: state
        )
    }
}


extension LocationStatus {
    func toApi() -> LocationStatusApi? {
        switch self {
        case .unknown:
            return nil
        case .set:
            return .set
        case .notSet:
            return .notSet
        @unknown default:
            fatalError("WTF")
        }
    }
}

extension DeviceType {
    func toApi() -> DeviceTypeApi {
        switch self {
        case .chipper1X:
            return .chipper1X
        case .chipper2X:
            return .chipper2X
        case .stripeM2:
            return .stripeM2
        case .tapToPay:
            return .tapToPay
        case .verifoneP400:
            return .verifoneP400
        case .wisePad3:
            return .wisePad3
        case .wisePosE:
            return .wisePosE
        case .wisePosEDevKit:
            return .wisePosEDevkit
        case .etna:
            return .etna
        case .wiseCube:
            return .wiseCube
        case .stripeS700:
            return .stripeS700
        case .stripeS700DevKit:
            return .stripeS700Devkit
        case .verifoneV660p:
            return .verifoneV660p
        case .verifoneM425:
            return .verifoneM425
        case .verifoneM450:
            return .verifoneM450
        case .verifoneP630:
            return .verifoneP630
        case .verifoneUX700:
            return .verifoneUX700
        @unknown default:
            fatalError("DeviceType \(self) not supported.")
        }
    }
}

extension ReaderEvent {
    func toApi() -> ReaderEventApi {
        switch (self) {
        case .cardInserted:
            return .cardInserted
        case .cardRemoved:
            return .cardRemoved
        @unknown default:
            fatalError("ReaderEvent \(self) not supported.")
        }
    }
}

extension ReaderDisplayMessage {
    func toApi() -> ReaderDisplayMessageApi {
        switch (self) {
        case .retryCard:
            return .retryCard
        case .insertCard:
            return .insertCard
        case .insertOrSwipeCard:
            return .insertOrSwipeCard
        case .swipeCard:
            return .swipeCard
        case .removeCard:
            return .removeCard
        case .multipleContactlessCardsDetected:
            return .multipleContactlessCardsDetected
        case .tryAnotherReadMethod:
            return .tryAnotherReadMethod
        case .tryAnotherCard:
            return .tryAnotherCard
        case .cardRemovedTooEarly:
            return .cardRemovedTooEarly
        @unknown default:
            fatalError("ReaderDisplayMessage \(self) not supported.")
        }
    }
}

extension ReaderInputOptions {
    func toApi() -> [ReaderInputOptionApi] {
        var options: [ReaderInputOptionApi] = []
        if (contains(ReaderInputOptions.insertCard)) { options.append(ReaderInputOptionApi.insertCard) }
        if (contains(ReaderInputOptions.swipeCard)) { options.append(ReaderInputOptionApi.swipeCard) }
        if (contains(ReaderInputOptions.tapCard)) { options.append(ReaderInputOptionApi.tapCard) }
        return options
    }
}

extension BatteryStatus {
    func toApi() -> BatteryStatusApi? {
        switch (self) {
        case .critical:
            return .critical
        case .low:
            return .low
        case .nominal:
            return .nominal
        case .unknown:
            return nil
        @unknown default:
            fatalError("BatteryStatys \(self) not supported.")
        }
    }
}

extension ReaderSoftwareUpdate {
    func toApi() -> ReaderSoftwareUpdateApi {
        return ReaderSoftwareUpdateApi(
            components: components.toApi(),
            keyProfileName: nil,
            onlyInstallRequiredUpdates: false,
            requiredAt: requiredAt,
            settingsVersion: nil,
            timeEstimate: durationEstimate.toApi(),
            version: deviceSoftwareVersion
        )
    }
}

extension UpdateComponent {
    func toApi() -> [UpdateComponentApi] {
        var components: [UpdateComponentApi] = []
        if (contains(UpdateComponent.incremental)) {components.append(UpdateComponentApi.incremental)}
        if (contains(UpdateComponent.firmware)) {components.append(UpdateComponentApi.firmware)}
        if (contains(UpdateComponent.config)) {components.append(UpdateComponentApi.config)}
        if (contains(UpdateComponent.keys)) {components.append(UpdateComponentApi.keys)}
        return components
    }
}
    
extension UpdateTimeEstimate {
    func toApi() -> UpdateTimeEstimateApi {
        switch self {
        case .estimateLessThan1Minute:
            return .lessThanOneMinute
        case .estimate1To2Minutes:
            return .oneToTwoMinutes
        case .estimate2To5Minutes:
            return .twoToFiveMinutes
        case .estimate5To15Minutes:
            return .fiveToFifteenMinutes
        @unknown default:
            fatalError("UpdateTimeEstimate \(self) not supported.")
        }
    }
}

// PARAMS

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
        case let config as TapToPayDiscoveryConfigurationApi:
            return try TapToPayDiscoveryConfigurationBuilder()
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
        case _ as TapToPayDiscoveryConfigurationApi:
            return .tapToPay
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
        case let config as TapToPayDiscoveryConfigurationApi:
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
        case .tapToPay:
            return .tapToPay
        case .stripeS710, .stripeS710Devkit, .wisePad3s:
            return nil
        case .verifoneV660p:
            return .verifoneV660p
        case .verifoneM425:
            return .verifoneM425
        case .verifoneM450:
            return .verifoneM450
        case .verifoneP630:
            return .verifoneP630
        case .verifoneUX700:
            return .verifoneUX700
        case .verifoneV660pDevkit:
            return .verifoneV660pDevKit
        case .verifoneUX700Devkit:
            return .verifoneUX700DevKit
        @unknown default:
            fatalError("DeviceType \(self) not supported.")
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

// EXTRA

extension ConnectionStatus {
    func toApi() -> ConnectionStatusApi {
        switch self {
        case .notConnected:
            return .notConnected
        case .discovering:
            return .discovering
        case .connecting:
            return .connecting
        case .connected:
            return .connected
        @unknown default:
            fatalError("WTF")
        }
    }
}
