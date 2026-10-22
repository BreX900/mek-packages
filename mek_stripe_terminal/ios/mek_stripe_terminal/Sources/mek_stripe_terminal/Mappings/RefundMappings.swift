import Foundation
import StripeTerminal

extension Refund {
    func toApi() -> RefundApi {
        return RefundApi(
            id: stripeId,
            amount: amount.toInt64(),
            chargeId: chargeId ?? "",
            createdInMilliseconds: created.toMillisecondsSinceEpoch(),
            currency: currency,
            metadata: metadata,
            reason: reason,
            status: status.toApi(),
            paymentMethodDetails: paymentMethodDetails?.toApi(),
            failureReason: failureReason
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
            interactPresent: interacPresent?.toApi()
        )
    }
}
