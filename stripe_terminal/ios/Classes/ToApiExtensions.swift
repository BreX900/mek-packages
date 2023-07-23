import Foundation
import StripeTerminal

extension Location {
    func toApi() -> LocationApi {
        return LocationApi(
            address: address?.toApi(),
            displayName: displayName,
            id: stripeId,
            livemode: livemode,
            metadata: metadata
        )
    }
}

extension Reader {
    func toApi() -> StripeReaderApi {
        return StripeReaderApi(
            locationStatus: locationStatus.toApi(),
            batteryLevel: batteryLevel?.doubleValue ?? -1.0,
            deviceType: deviceType.toApi(),
            simulated: simulated,
            availableUpdate: availableUpdate != nil,
            locationId: locationId,
            serialNumber: serialNumber,
            label: label
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
        @unknown default:
            fatalError("WTF")
        }
    }
}

extension Address {
    func toApi() -> AddressApi? {
        return AddressApi(
            city: city,
            country: country,
            line1: line1,
            line2: line2,
            postalCode: postalCode,
            state: state
        )
    }
}

extension ConnectionStatus {
    func toApi() -> ConnectionStatusApi {
        switch self {
        case .notConnected:
            return .notConnected
        case .connected:
            return .connected
        case .connecting:
            return .connecting
        @unknown default:
            fatalError("WTF")
        }
    }
}

extension DiscoveryMethod {
    func toApi() -> DiscoveryMethodApi {
        switch self {
        case .bluetoothScan:
            return .bluetoothScan
        case .bluetoothProximity:
            fatalError("Not supported DiscoveryMethod.bluetoothProximity")
        case .internet:
            return .internet
        case .localMobile:
            return .localMobile
        @unknown default:
            fatalError("WTF")
        }
    }
}

extension LocationStatus {
    func toApi() -> LocationStatusApi {
        switch self {
        case .unknown:
            return .unknown
        case .set:
            return .set
        case .notSet:
            return .notSet
        @unknown default:
            fatalError("WTF")
        }
    }
}

extension DeviceType {
    func toApi() -> DeviceTypeApi {
        switch self {
        case .chipper2X:
            return .chipper2X
        case .verifoneP400:
            return .verifoneP400
        case .wisePad3:
            return .wisepad3
        case .stripeM2:
            return .stripeM2
        case .wisePosE:
            return .wiseposE
        case .wisePosEDevKit:
            return .wiseposEDevkit
        case .etna:
            return .etna
        case .chipper1X:
            return .chipper1X
        case .wiseCube:
            return .wiseCube
        case .stripeS700:
            return .stripeS700
        case .stripeS700DevKit:
            return .stripeS700Devkit
        case .appleBuiltIn:
            fatalError("Not supported DeviceType.appleBuiltIn")
        @unknown default:
            fatalError("WTF")
        }
    }
}

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

extension PaymentMethod {
    func toApi() -> StripePaymentMethodApi {
        return StripePaymentMethodApi(
            id: stripeId,
            cardDetails: card?.toApi(),
            customer: customer,
            livemode: true,
            metadata: metadata
        )
    }
}

extension CardDetails {
    func toApi() -> CardDetailsApi {
        return CardDetailsApi(
            brand: brand.toApi(),
            country: country,
            expMonth: expMonth,
            expYear: expYear,
            fingerprint: fingerprint,
            funding: funding.toApi(),
            last4: last4
        )
    }
}

extension CardBrand {
    func toApi() -> String {
        switch self {
        case .amex:
            return "amex"
        case .dinersClub:
            return "diners"
        case .discover:
            return "discover"
        case .JCB:
            return "jcb"
        case .masterCard:
            return "mastercard"
        case .unionPay:
            return "unionpay"
        case .visa:
            return "visa"
        case .unknown:
            return "unknown"
        case .interac:
            return "interac"
        case .eftposAu:
            return "eftposau"
        @unknown default:
            fatalError("WTF")
        }
    }
}

extension CardFundingType {
    func toApi() -> String {
        switch self {
        case .credit:
            return "credit"
        case .debit:
            return "debit"
        case .prepaid:
            return "prepaid"
        case .other:
            return "unknown"
        @unknown default:
            fatalError("WTF")
        }
    }
}

extension PaymentIntent {
    func toApi() -> StripePaymentIntentApi {
        return StripePaymentIntentApi(
            id: stripeId,
            amount: Double(amount),
            amountCapturable: 0,
            amountReceived: 0,
            application: nil,
            applicationFeeAmount: nil,
            captureMethod: captureMethod.toApi(),
            cancellationReason: nil,
            canceledAt: nil,
            clientSecret: nil,
            confirmationMethod: nil,
            created: created,
            currency: currency,
            customer: nil,
            description: description,
            invoice: nil,
            livemode: false,
            metadata: metadata,
            onBehalfOf: nil,
            paymentMethodId: nil,
            status: status.toApi(),
            review: nil,
            receiptEmail: nil,
            setupFutureUsage: nil,
            transferGroup: nil
        )
    }
}

extension CaptureMethod {
    func toApi() -> String {
        switch self {
        case .manual:
            return "manual"
        case .automatic:
            return "automatic"
        @unknown default:
            fatalError("WTF")
        }
    }
}

extension NSError {
    func toApi() -> String {
        let code = AppleBuiltInReaderErrorCode(rawValue: self.code)
        switch code! {
        case .unknown:
            return "unknown"
        case .unexpectedNil:
            return "unexpectedNil"
        case .invalidTransactionType:
            return "invalidTransactionType"
        case .passcodeDisabled:
            return "passcodeDisabled"
        case .notAllowed:
            return "notAllowed"
        case .backgroundRequestNotAllowed:
            return "backgroundRequestNotAllowed"
        case .unsupported:
            return "unsupported"
        case .osVersionNotSupported:
            return StripeTerminalExceptionCodeApi.localMobileUnsupportedAndroidVersion.rawValue // TODO: fix my name
        case .modelNotSupported:
            return StripeTerminalExceptionCodeApi.unsupportedOperation.rawValue
        case .networkError:
            return StripeTerminalExceptionCodeApi.stripeApiConnectionError.rawValue
        case .networkAuthenticationError:
            return StripeTerminalExceptionCodeApi.stripeApiError.rawValue
        case .serviceConnectionError:
            return "serviceConnectionError"
        case .notReady:
            return StripeTerminalExceptionCodeApi.sessionExpired.rawValue
        case .emptyReaderToken:
            return "emptyReaderToken"
        case .invalidReaderToken:
            return "invalidReaderToken"
        case .prepareFailed:
            return "prepareFailed"
        case .prepareExpired:
            return "prepareExpired"
        case .tokenExpired:
            return "tokenExpired"
        case .deviceBanned:
            return "deviceBanned"
        case .readerMemoryFull:
            return "readerMemoryFull"
        case .readerBusy:
            return StripeTerminalExceptionCodeApi.readerBusy.rawValue
        case .accountNotLinked:
            return "accountNotLinked"
        case .accountLinkingFailed:
            return "accountLinkingFailed"
        case .accountLinkingRequiresiCloudSignIn:
            return "accountLinkingRequiresiCloudSignIn"
        case .accountLinkingCancelled:
            return "accountLinkingCancelled"
        case .merchantBlocked:
            return "merchantBlocked"
        case .invalidMerchant:
            return "invalidMerchant"
        case .readNotAllowed:
            return "readNotAllowed"
        case .readFromBackgroundError:
            return "readFromBackgroundError"
        case .readerServiceConnectionError:
            return "readerServiceConnectionError"
        case .readerServiceError:
            return "readerServiceError"
        case .noReaderSession:
            return "noReaderSession"
        case .readerSessionExpired:
            return "readerSessionExpired"
        case .readerTokenExpired:
            return "readerTokenExpired"
        case .readerSessionNetworkError:
            return "readerSessionNetworkError"
        case .readerSessionAuthenticationError:
            return "readerSessionAuthenticationError"
        case .readerSessionBusy:
            return StripeTerminalExceptionCodeApi.readerBusy.rawValue
        case .readCancelled:
            return "readCancelled"
        case .invalidAmount:
            return "invalidAmount"
        case .invalidCurrency:
            return "invalidCurrency"
        case .nfcDisabled:
            return StripeTerminalExceptionCodeApi.localMobileNfcDisabled.rawValue
        case .readNotAllowedDuringCall:
            return "readNotAllowedDuringCall"
        case .cardReadFailed:
            return "cardReadFailed"
        case .paymentReadFailed:
            return "paymentReadFailed"
        case .paymentCardDeclined:
            return "paymentCardDeclined"
        case .pinEntryFailed:
            return "pinEntryFailed"
        case .pinTokenInvalid:
            return "pinTokenInvalid"
        case .pinEntryTimeout:
            return "pinEntryTimeout"
        case .pinCancelled:
            return "pinCancelled"
        case .pinNotAllowed:
            return "pinNotAllowed"
        default:
            return ""
        }
    }
}
