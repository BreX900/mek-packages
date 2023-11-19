import Foundation
import StripeTerminal

extension ChargeStatus {
    func toApi() -> ChargeStatusApi {
        switch (self) {
        case ChargeStatus.pending:
            return ChargeStatusApi.pending
        case ChargeStatus.failed:
            return ChargeStatusApi.failed
        case ChargeStatus.succeeded:
            return ChargeStatusApi.succeeded
        @unknown default:
            fatalError("Unkown charge status")
        }
    }
}

extension Charge {
    func toApi() -> ChargeApi {
        return ChargeApi(
            amount: amount.intValue,
            currency: currency,
            status: status.toApi(),
            paymentMethodDetails: paymentMethodDetails?.toApi(),
            description: description,
            id: stripeId,
            metadata: metadata,
            statementDescriptorSuffix: statementDescriptorSuffix,
            calculatedStatementDescriptor: calculatedStatementDescriptor,
            authorizationCode: authorizationCode
        )
    }
}
