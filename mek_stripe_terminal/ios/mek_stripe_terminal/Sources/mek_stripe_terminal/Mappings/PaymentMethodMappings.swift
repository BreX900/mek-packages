import Foundation
import StripeTerminal

extension PaymentMethod {
    func toApi() -> PaymentMethodApi {
        return PaymentMethodApi(
            card: card?.toApi(),
            cardPresent: cardPresent?.toApi(),
            customerId: customer,
            id: stripeId,
            interacPresent: interacPresent?.toApi(),
            metadata: metadata
        )
    }
}

// PARAMS

extension PaymentMethodOptionsParametersApi {
    func toHost() throws -> PaymentMethodOptionsParameters {
        return try PaymentMethodOptionsParametersBuilder(
            cardPresentParameters: try cardPresentParameters.toHost()
        )
            .build()
    }
}
