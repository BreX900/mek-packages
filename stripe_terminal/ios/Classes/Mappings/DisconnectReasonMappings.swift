import Foundation
import StripeTerminal

extension DisconnectReason {
    func toApi() -> DisconnectReasonApi {
        switch self {
        case .unknown:
            return .unknown
        case .disconnectRequested:
            return .disconnectRequested
        case .rebootRequested:
            return .rebootRequested
        case .securityReboot:
            return .securityReboot
        case .criticallyLowBattery:
            return .criticallyLowBattery
        case .poweredOff:
            return .poweredOff
        case .bluetoothDisabled:
            return .bluetoothDisabled
        @unknown default:
            fatalError("WTF")
        }
    }
}
