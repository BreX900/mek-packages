import Foundation
import StripeTerminal

extension CartApi {
    func toHost() -> Cart {
        return Cart(
            currency: currency,
            tax: tax,
            total: total
        )
    }
}
