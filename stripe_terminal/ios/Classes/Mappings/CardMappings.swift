import Foundation
import StripeTerminal

extension CardDetails {
    func toApi() -> CardDetailsApi {
        return CardDetailsApi(
            brand: brand.toApi(),
            country: country,
            expMonth: expMonth,
            expYear: expYear,
            funding: funding.toApi(),
            last4: last4
        )
    }
}
