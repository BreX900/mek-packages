import Foundation
import StripeTerminal

extension SCPTip {
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
