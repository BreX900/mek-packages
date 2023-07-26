import Foundation
import StripeTerminal

extension DiscoveryMethodApi {
    func toHost() -> DiscoveryMethod? {
        switch self {
        case .bluetoothScan:
            return .bluetoothScan
        case .internet:
            return .internet
        case .localMobile:
            return .localMobile
        case .handOff, .embedded, .usb:
            return nil
        }
    }
}

extension CartApi {
    func toHost() -> Cart {
        return Cart(
            currency: currency,
            tax: tax,
            total: total
        )
    }
}
