import Foundation
import StripeTerminal

extension SCPTip {
    func toApi() -> TipApi {
        return TipApi(
            amount: amount?.intValue
        )
    }
}
