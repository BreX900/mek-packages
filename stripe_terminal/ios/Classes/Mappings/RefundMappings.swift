import Foundation
import StripeTerminal

extension Refund {
    func toApi() -> RefundApi {
        return RefundApi(
            amount: Int(amount),
            chargeId: charge,
            created: created,
            currency: currency,
            failureReason: failureReason,
            id: stripeId,
            metadata: metadata,
            paymentMethodDetails: paymentMethodDetails?.toApi(),
            reason: reason,
            status: status.toApi()
        )
    }
}

extension RefundStatus {
    func toApi() -> RefundStatusApi? {
        switch self {
        case .succeeded:
            return .succeeded
        case .pending:
            return .pending
        case .failed:
            return .failed
        case .unknown:
            return nil
        @unknown default:
            fatalError()
        }
    }
}

extension PaymentMethodDetails {
    func toApi() -> PaymentMethodDetailsApi {
        return PaymentMethodDetailsApi(
            cardPresent: cardPresent?.toApi(),
            interacPresent: interacPresent?.toApi()
        )
    }
}
