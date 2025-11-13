import Foundation
import StripeTerminal

extension SetupIntent {
    func toApi() -> SetupIntentApi {
        return SetupIntentApi(
            created: created,
            customerId: customer,
            id: stripeId!,
            latestAttempt: latestAttempt?.toApi(),
            metadata: metadata ?? [:],
            status: status.toApi(),
            usage: usage.toApi()
        )
    }
}

extension SetupIntentUsage {
    func toApi() -> SetupIntentUsageApi {
        switch self {
        case .offSession:
            return .offSession
        case .onSession:
            return .onSession
        @unknown default:
            fatalError()
        }
    }
}

extension SetupIntentStatus {
    func toApi() -> SetupIntentStatusApi {
        switch self {
        case .requiresPaymentMethod:
            return .requiresPaymentMethod
        case .requiresConfirmation:
            return .requiresConfirmation
        case .requiresAction:
            return .requiresAction
        case .processing:
            return .processing
        case .canceled:
            return .cancelled
        case .succeeded:
            return .succeeded
        @unknown default:
            fatalError()
        }
    }
}

extension SetupAttempt {
    func toApi() -> SetupAttemptApi {
        let statusApi: SetupAttemptStatusApi
        switch status {
        case "requires_confirmation":
            statusApi = .requiresConfirmation
        case "requires_action":
            statusApi = .requiresAction
        case "processing":
            statusApi = .processing
        case "succeeded":
            statusApi = .succeeded
        case "failed":
            statusApi = .failed
        case "abandoned":
            statusApi = .abandoned
        default:
            fatalError()
        }
        return SetupAttemptApi(
            applicationId: application,
            created: created,
            customerId: customer,
            id : stripeId,
            onBehalfOf: onBehalfOf,
            paymentMethodDetails: paymentMethodDetails?.toApi(),
            paymentMethodId: paymentMethod,
            setupIntentId: setupIntent,
            status: statusApi
        )
    }
}

extension SetupAttemptPaymentMethodDetails {
    func toApi() -> SetupAttemptPaymentMethodDetailsApi {
        return SetupAttemptPaymentMethodDetailsApi(
            cardPresent: cardPresent?.toApi(),
            interacPresent: interacPresent?.toApi()
        )
    }
}

extension SetupAttemptCardPresentDetails {
    func toApi() -> SetupAttemptCardPresentDetailsApi {
        return SetupAttemptCardPresentDetailsApi(
            emvAuthData: emvAuthData ?? "",
            generatedCard: generatedCard ?? ""
        )
    }
}

// PARAMS

extension SetupIntentUsageApi {
    func toHost() -> SetupIntentUsage {
        switch self {
        case .offSession:
            return .offSession
        case .onSession:
            return .onSession
        }
    }
}

extension AllowRedisplayApi {
    func toHost() -> AllowRedisplay {
        switch self {
        case .always:
            return .always
        case .limited:
            return .limited
        case .unspecified:
            return .unspecified
        @unknown default:
            fatalError()
        }
    }
}
