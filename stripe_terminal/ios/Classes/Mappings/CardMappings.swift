import Foundation
import StripeTerminal

extension CardDetails {
    func toApi() -> CardDetailsApi {
        return CardDetailsApi(
            brand: brand.toApi(),
            country: country,
            expMonth: expMonth,
            expYear: expYear,
            funding: funding.toApi(),
            last4: last4
        )
    }
}

extension CardBrand {
    func toApi() -> CardBrandApi? {
        switch self {
        case .amex:
            return .amex
        case .dinersClub:
            return .dinersClub
        case .discover:
            return .discover
        case .JCB:
            return .jcb
        case .masterCard:
            return .masterCard
        case .unionPay:
            return .unionPay
        case .visa:
            return .visa
        case .unknown:
            return nil
        case .interac:
            return .interac
        case .eftposAu:
            return .eftposAu
        @unknown default:
            fatalError("WTF")
        }
    }
}

extension CardFundingType {
    func toApi() -> CardFundingTypeApi? {
        switch self {
        case .credit:
            return .credit
        case .debit:
            return .debit
        case .prepaid:
            return .prepaid
        case .other:
            return nil
        @unknown default:
            fatalError("WTF")
        }
    }
}


extension CardPresentDetails {
    func toApi() -> CardPresentDetailsApi {
        return CardPresentDetailsApi(
            brand: brand.toApi(),
            cardholderName: cardholderName,
            country: country,
            emvAuthData: emvAuthData,
            expMonth: expMonth,
            expYear: expYear,
            funding: funding.toApi(),
            generatedCard: generatedCard,
            incrementalAuthorizationStatus: incrementalAuthorizationStatus.toApi(),
            last4: last4,
            networks: networks?.toApi(),
            receipt: receipt?.toApi()
        )
    }
}

extension SCPIncrementalAuthorizationStatus {
    func toApi() -> IncrementalAuthorizationStatusApi? {
        switch self {
        case .unknown:
            return nil
        case .notSupported:
            return .notSupported
        case .supported:
            return .supported
        @unknown default:
            fatalError()
        }
    }
}

extension SCPNetworks {
    func toApi() -> CardNetworksApi {
        return CardNetworksApi(
            available: available?.compactMap { 
                guard let brand = CardBrand(rawValue: Int(truncating: $0)) else { return nil }
                return brand.toApi()
            } ?? [],
            preferred: nil
        )
    }
}

extension ReceiptDetails {
    func toApi() -> ReceiptDetailsApi {
        return ReceiptDetailsApi(
            accountType: accountType,
            applicationCryptogram: applicationCryptogram,
            applicationPreferredName: applicationPreferredName,
            authorizationCode: authorizationCode,
            authorizationResponseCode: authorizationResponseCode,
            dedicatedFileName: dedicatedFileName,
            terminalVerificationResults: terminalVerificationResults,
            transactionStatusInformation: transactionStatusInformation
        )
    }
}

// PARAMS

extension CardPresentParametersApi {
    func toHost() throws -> CardPresentParameters {
        let b = CardPresentParametersBuilder()
        if let it = captureMethod { b.setCaptureMethod(it.toHost()) }
        if let it = requestedPriority { b.setRequestedPriority(it.toHost()) }
        if let it = requestExtendedAuthorization { b.setRequestExtendedAuthorization(it) }
        if let it = requestIncrementalAuthorizationSupport { b.setRequestIncrementalAuthorizationSupport(it) }
        return try b.build()
    }
}

extension CardPresentCaptureMethodApi {
    func toHost() -> CardPresentCaptureMethod {
        switch self {
        case .manualPreferred:
            return .manualPreferred
        }
    }
}

extension CardPresentRoutingApi {
    func toHost() -> CardPresentRouting {
        switch self {
        case .domestic:
            return .domestic
        case .international:
            return .international
        }
    }
}
