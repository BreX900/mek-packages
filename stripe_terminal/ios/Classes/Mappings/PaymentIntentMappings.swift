import Foundation
import StripeTerminal

extension PaymentIntent {
    func toApi() -> PaymentIntentApi {
        return PaymentIntentApi(
            amount: Int(amount),
            amountCapturable: nil,
            amountDetails: amountDetails?.toApi(),
            amountReceived: nil,
            amountTip: amountTip?.intValue,
            applicationFeeAmount: nil,
            applicationId: nil,
            canceledAt: nil,
            cancellationReason: nil,
            captureMethod: captureMethod.toApi(),
            charges: charges.map { $0.toApi() },
            clientSecret: nil,
            confirmationMethod: nil,
            created: created,
            currency: currency,
            customerId: nil,
            description: description,
            id: stripeId,
            invoiceId: nil,
            metadata: metadata,
            onBehalfOf: nil,
            paymentMethod: paymentMethod?.toApi(),
            paymentMethodId: paymentMethodId,
            receiptEmail: nil,
            reviewId: nil,
            setupFutureUsage: nil,
            statementDescriptor: statementDescriptor,
            statementDescriptorSuffix: statementDescriptorSuffix,
            status: status.toApi(),
            transferGroup: nil
        )
    }
}

extension PaymentIntentStatus {
    func toApi() -> PaymentIntentStatusApi {
        switch self {
        case .requiresPaymentMethod:
            return .requiresPaymentMethod
        case .requiresConfirmation:
            return .requiresConfirmation
        case .requiresCapture:
            return .requiresCapture
        case .processing:
            return .processing
        case .canceled:
            return .canceled
        case .succeeded:
            return .succeeded
        case .requiresAction:
            return .requiresAction
        @unknown default:
            fatalError("Not supported payment intent status: \(self)")
        }
    }
}

extension CaptureMethod {
    func toApi() -> CaptureMethodApi {
        switch self {
        case .manual:
            return CaptureMethodApi.manual
        case .automatic:
            return CaptureMethodApi.automatic
        @unknown default:
            fatalError("Not supported CaptureMethodApi '\(self)'")
        }
    }
}

extension SCPAmountDetails {
    func toApi() -> AmountDetailsApi {
        return AmountDetailsApi(
            tip: tip?.toApi()
        )
    }
}

// PARAMS


extension PaymentIntentParametersApi {
    func toHost() throws -> PaymentIntentParameters {
        let b = PaymentIntentParametersBuilder(
                amount: UInt(amount),
                currency: currency
            )
            .setPaymentMethodTypes(paymentMethodTypes.map { $0.toHost() })
            .setCaptureMethod(captureMethod.toHost())
            .setMetadata(metadata ?? [:])
            .setStripeDescription(description)
            .setStatementDescriptor(statementDescriptor)
            .setStatementDescriptorSuffix(statementDescriptorSuffix)
            .setReceiptEmail(receiptEmail)
            .setCustomer(customerId)
            .setApplicationFeeAmount(applicationFeeAmount?.nsNumberValue)
            .setTransferDataDestination(transferDataDestination)
            .setTransferGroup(transferGroup)
            .setOnBehalfOf(onBehalfOf)
            .setSetupFutureUsage(setupFutureUsage?.toHost())
        if let it = paymentMethodOptionsParameters { b.setPaymentMethodOptionsParameters(try it.toHost()) }
        return try b.build()
    }
}

extension PaymentMethodTypeApi {
    func toHost() -> PaymentMethodType {
        switch (self) {
        case .cardPresent:
            return .cardPresent
        case .card:
            return .card
        case .interactPresent:
            return .interacPresent
        }
    }
}

extension CaptureMethodApi {
    func toHost() -> CaptureMethod {
        switch self {
        case .automatic:
            return .automatic
        case .manual:
            return .manual
        }
    }
}

extension PaymentIntentUsageApi {
    func toHost() -> String {
        switch self {
        case .offSession:
            return "off_session"
        case .onSession:
            return "on_session"
        }
    }
}

// EXTRA

extension PaymentStatus {
    func toApi() -> PaymentStatusApi {
        switch self {
        case .notReady:
            return .notReady
        case .ready:
            return .ready
        case .waitingForInput:
            return .waitingForInput
        case .processing:
            return .processing
        @unknown default:
            fatalError("WTF")
        }
    }
}
