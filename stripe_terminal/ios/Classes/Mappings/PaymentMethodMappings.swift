import Foundation
import StripeTerminal

extension PaymentMethod {
    func toApi() -> PaymentMethodApi {
        return PaymentMethodApi(
            id: stripeId,
            card: card?.toApi(),
            cardPresent: cardPresent?.toApi(),
            interacPresent: interacPresent?.toApi(),
            customerId: customer,
            metadata: metadata
        )
    }
}
