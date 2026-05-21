import Foundation
import StripeTerminal

extension Tip {
    func toApi() -> TipApi {
        return TipApi(
            amount: amount?.intValue
        )
    }
}

// PARAMS

extension TippingConfigurationApi {
    func toHost() throws -> TippingConfiguration {
        return try TippingConfigurationBuilder()
            .setEligibleAmount(eligibleAmount)
            .build()
    }
}
