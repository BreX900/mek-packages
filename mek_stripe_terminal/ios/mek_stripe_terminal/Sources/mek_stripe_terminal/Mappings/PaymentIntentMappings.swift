import Foundation
import StripeTerminal

extension PaymentIntent {
    func toApi() -> PaymentIntentApi {
        return PaymentIntentApi(
            id: stripeId!,
            createdInMilliseconds: created.toMillisecondsSinceEpoch(),
            status: status.toApi(),
            amount: Double(amount),
            captureMethod: captureMethod.toApi(),
            currency: currency,
            metadata: metadata ?? [:],
            charges: charges.map { $0.toApi() },
            paymentMethod: paymentMethod?.toApi(),
            paymentMethodId: paymentMethodId,
            amountDetails: amountDetails?.toApi(),
            amountTip: amountTip != nil ? Double(truncating: amountTip!) : nil,
            statementDescriptor: statementDescriptor,
            statementDescriptorSuffix: statementDescriptorSuffix,
            amountCapturable: nil,
            amountReceived: nil,
            applicationId: nil,
            applicationFeeAmount: nil,
            cancellationReason: nil,
            canceledAt: nil,
            clientSecret: nil,
            confirmationMethod: nil,
            customerId: nil,
            descriptionX: description,
            invoiceId: nil,
            onBehalfOf: nil,
            reviewId: nil,
            receiptEmail: nil,
            setupFutureUsage: nil,
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

extension AmountDetails {
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
            .setMetadata(metadata)
            .setStripeDescription(description)
            .setStatementDescriptor(statementDescriptor)
            .setStatementDescriptorSuffix(statementDescriptorSuffix)
            .setReceiptEmail(receiptEmail)
            .setCustomer(customerId)
            .setApplicationFeeAmount(applicationFeeAmount?.toNsNumber())
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

extension ConfirmPaymentIntentConfigurationApi {
    func toHost() throws -> ConfirmPaymentIntentConfiguration {
        let configuration = ConfirmPaymentIntentConfigurationBuilder();
        if let returnUrl = returnUrl { configuration.setReturnUrl(returnUrl) }
        return try configuration.build()
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
