import Foundation
import StripeTerminal


extension Reader {
    func toApi() -> ReaderApi {
        return ReaderApi(
            id: stripeId,
            locationStatus: locationStatus.toApi(),
            deviceType: deviceType.toApi(),
            simulated: simulated,
            locationId: locationId,
            location: location?.toApi(),
            serialNumber: serialNumber,
            deviceSoftwareVersion: deviceSoftwareVersion,
            availableUpdate: availableUpdate != nil,
            batteryLevel: batteryLevel?.doubleValue ?? -1.0,
            ipAddress: ipAddress,
            networkStatus: status.toApi(),
            label: label
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

extension ReaderNetworkStatus {
    func toApi() -> NetworkStatusApi? {
        switch self {
        case .offline:
            return .offline
        case .online:
            return .online
        case .unknown:
            return nil
        @unknown default:
            fatalError("ReaderNetworkStatus \(self) not supported.")
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
        case .verifoneV660pDevKit:
            return .verifoneV660p
        case .verifoneUX700:
            return .verifoneUx700
        case .verifoneUX700DevKit:
            return .verifoneUx700Devkit
        case .stripeU200:
            return .stripeU200
        case .stripeS710:
            return .stripeS710
        case .stripeS710DevKit:
            return .stripeS710Devkit
        case .verifoneVM100:
            return .verifoneVm100
        case .verifoneVP100:
            return .verifoneVp100
        case .verifoneVL110:
            return .verifoneVl110
        case .verifoneVM110:
            return .verifoneVm110
        case .verifoneVP110:
            return .verifoneVp110
        case .stripeT600:
            return .stripeT600
        case .stripeT600DevKit:
            return .stripeT600Devkit
        case .stripeT610:
            return .stripeT610
        case .stripeT610DevKit:
            return .stripeT610Devkit
        @unknown default:
            fatalError("DeviceType->DeviceTypeApi \(self) not supported.")
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
            requiredAtInMilliseconds: requiredAt.toMillisecondsSinceEpoch(),
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
                .setTimeout(config.timeoutInSeconds?.toUInt() ?? 0)
                .setSimulated(config.isSimulated)
                .build()
        case let config as BluetoothProximityDiscoveryConfigurationApi:
            return try BluetoothProximityDiscoveryConfigurationBuilder()
                .setSimulated(config.isSimulated)
                .build()
        //case _ as HandoffDiscoveryConfigurationApi:
        //    return nil
        case let config as InternetDiscoveryConfigurationApi:
            return try InternetDiscoveryConfigurationBuilder()
                .setSimulated(config.isSimulated)
                .setLocationId(config.locationId)
                .setTimeout(config.timeoutInSeconds?.toUInt() ?? 0)
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
        //case _ as HandoffDiscoveryConfigurationApi:
        //    return nil
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
        //case _ as HandoffDiscoveryConfigurationApi:
        //    return false
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
            return nil
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
        case .verifoneV660p:
            return .verifoneV660p
        case .verifoneM425:
            return .verifoneM425
        case .verifoneM450:
            return .verifoneM450
        case .verifoneP630:
            return .verifoneP630
        case .verifoneUx700:
            return .verifoneUX700
        case .verifoneV660pDevkit:
            return .verifoneV660pDevKit
        case .verifoneUx700Devkit:
            return .verifoneUX700DevKit
        case .stripeS710:
            return .stripeS710
        case .stripeS710Devkit:
            return .stripeS710DevKit
        case .wisePad3s:
            return nil
        case .stripeT600:
            return .stripeT600
        case .stripeT600Devkit:
            return .stripeT600DevKit
        case .stripeT610:
            return .stripeT610
        case .stripeT610Devkit:
            return .stripeT610DevKit
        case .verifoneV660pa:
            return nil
        case .verifoneVm100:
            return .verifoneVM100
        case .verifoneVp100:
            return .verifoneVP100
        case .stripeU200:
            return .stripeU200
        case .verifoneVm110:
            return .verifoneVM110
        case .verifoneVp110:
            return .verifoneVP110
        case .verifoneVl110:
            return .verifoneVL110
        }
    }
}


extension CartApi {
    func toHost() throws -> Cart {
        return try CartBuilder(currency: currency)
            .setTax(tax.toInt())
            .setTotal(total.toInt())
            .setLineItems(lineItems.map { try $0.toHost()} )
            .build()
    }
}

extension CartLineItemApi {
    func toHost() throws -> CartLineItem {
        return try CartLineItemBuilder(displayName: description)
            .setAmount(amount.toInt())
            .setQuantity(quantity.toInt())
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
        case .reconnecting:
            return .reconnecting
        @unknown default:
            fatalError("ConnectionStatus->ConnectionStatusApi \(self) not supported.")
        }
    }
}
