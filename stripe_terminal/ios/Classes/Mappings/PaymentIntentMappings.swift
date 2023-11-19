import Foundation
import StripeTerminal

extension SCPAmountDetails {
    func toApi() -> AmountDetailsApi {
        return AmountDetailsApi(
            tip: tip?.toApi()
        )
    }
}
