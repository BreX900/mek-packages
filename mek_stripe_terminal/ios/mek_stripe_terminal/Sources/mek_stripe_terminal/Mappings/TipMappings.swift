import Foundation
import StripeTerminal

extension Tip {
    func toApi() -> TipApi {
        return TipApi(
            amount: amount?.toInt64()
        )
    }
}

// PARAMS

extension TippingConfigurationApi {
    func toHost() throws -> TippingConfiguration {
        return try TippingConfigurationBuilder()
            .setEligibleAmount(eligibleAmount.toInt())
            .build()
    }
}
