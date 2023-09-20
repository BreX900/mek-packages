import Foundation
import StripeTerminal

extension Location {
    func toApi() -> LocationApi {
        return LocationApi(
            address: address?.toApi(),
            displayName: displayName,
            id: stripeId,
            livemode: livemode,
            metadata: metadata ?? [:]
        )
    }
}

extension Reader {
    func toApi() -> ReaderApi {
        return ReaderApi(
            locationStatus: locationStatus.toApi(),
            deviceType: deviceType.toApi(),
            simulated: simulated,
            locationId: locationId,
            serialNumber: serialNumber,
            availableUpdate: availableUpdate != nil,
            batteryLevel: batteryLevel?.doubleValue ?? -1.0,
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
            return .bluetoothProximity
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
    func toApi() -> LocationStatusApi? {
        switch self {
        case .unknown:
            return nil
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
            return .wisePad3
        case .stripeM2:
            return .stripeM2
        case .wisePosE:
            return .wisePosE
        case .wisePosEDevKit:
            return .wisePosEDevkit
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
            return .appleBuiltIn
        @unknown default:
            fatalError("WTF")
        }
    }
}

extension ReaderEvent {
    func toApi() -> ReaderEventApi {
        switch (self) {
        case .cardInserted:
            return .cardInserted
        case .cardRemoved:
            return .cardRemoved
        @unknown default:
            fatalError()
        }
    }
}

extension ReaderDisplayMessage {
    func toApi() -> ReaderDisplayMessageApi {
        switch (self) {
        case .retryCard:
            return .retryCard
        case .insertCard:
            return .insertCard
        case .insertOrSwipeCard:
            return .insertOrSwipeCard
        case .swipeCard:
            return .swipeCard
        case .removeCard:
            return .removeCard
        case .multipleContactlessCardsDetected:
            return .multipleContactlessCardsDetected
        case .tryAnotherReadMethod:
            return .tryAnotherReadMethod
        case .tryAnotherCard:
            return .tryAnotherCard
        case .cardRemovedTooEarly:
            return .cardRemovedTooEarly
        @unknown default:
            fatalError()
        }
    }
}

extension ReaderInputOptions {
    func toApi() -> [ReaderInputOptionApi] {
        var options: [ReaderInputOptionApi] = []
        if (contains(ReaderInputOptions.insertCard)) { options.append(ReaderInputOptionApi.insertCard) }
        if (contains(ReaderInputOptions.swipeCard)) { options.append(ReaderInputOptionApi.swipeCard) }
        if (contains(ReaderInputOptions.tapCard)) { options.append(ReaderInputOptionApi.tapCard) }
        return options
    }
}

extension BatteryStatus {
    func toApi() -> BatteryStatusApi? {
        switch (self) {
        case .critical:
            return .critical
        case .low:
            return .low
        case .nominal:
            return .nominal
        case .unknown:
            return nil
        @unknown default:
            fatalError()
        }
    }
}

extension ReaderSoftwareUpdate {
    func toApi() -> ReaderSoftwareUpdateApi {
        return ReaderSoftwareUpdateApi(
            components: components.toApi(),
            keyProfileName: nil,
            onlyInstallRequiredUpdates: false,
            requiredAt: requiredAt,
            settingsVersion: nil,
            timeEstimate: estimatedUpdateTime.toApi(),
            version: deviceSoftwareVersion
        )
    }
}

extension UpdateComponent {
    func toApi() -> [UpdateComponentApi] {
        var components: [UpdateComponentApi] = []
        if (contains(UpdateComponent.incremental)) {components.append(UpdateComponentApi.incremental)}
        if (contains(UpdateComponent.firmware)) {components.append(UpdateComponentApi.firmware)}
        if (contains(UpdateComponent.config)) {components.append(UpdateComponentApi.config)}
        if (contains(UpdateComponent.keys)) {components.append(UpdateComponentApi.keys)}
        return components
    }
}
    
extension UpdateTimeEstimate {
    func toApi() -> UpdateTimeEstimateApi {
        switch self {
        case .estimateLessThan1Minute:
            return .lessThanOneMinute
        case .estimate1To2Minutes:
            return .oneToTwoMinutes
        case .estimate2To5Minutes:
            return .twoToFiveMinutes
        case .estimate5To15Minutes:
            return .fiveToFifteenMinutes
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
    func toApi() -> PaymentMethodApi {
        return PaymentMethodApi(
            id: stripeId,
            card: card?.toApi(),
            cardPresent: cardPresent?.toApi(),
            interacPresent: interacPresent?.toApi(),
            customer: customer,
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

extension CardPresentDetails {
    func toApi() -> CardPresentDetailsApi {
        return CardPresentDetailsApi(
            brand: brand.toApi(),
            country: country,
            expMonth: expMonth,
            expYear: expYear,
            fingerprint: fingerprint,
            funding: funding.toApi(),
            last4: last4,
            cardholderName: cardholderName,
            emvAuthData: emvAuthData,
            generatedCard: generatedCard,
            incrementalAuthorizationStatus: incrementalAuthorizationStatus.toApi(),
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
            available: available?.map { CardBrand(rawValue: Int(truncating: $0))!.toApi()! } ?? [],
            preferred: nil
        )
    }
}

extension ReceiptDetails {
    func toApi() -> ReceiptDetailsApi {
        return ReceiptDetailsApi(
            accountType: accountType,
            applicationPreferredName: applicationPreferredName,
            authorizationCode: authorizationCode,
            authorizationResponseCode: authorizationResponseCode,
            applicationCryptogram: applicationCryptogram,
            dedicatedFileName: dedicatedFileName,
            transactionStatusInformation: transactionStatusInformation,
            terminalVerificationResults: terminalVerificationResults
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

extension PaymentIntent {
    func toApi() -> PaymentIntentApi {
        return PaymentIntentApi(
            id: stripeId,
            created: created,
            status: status.toApi(),
            amount: Double(amount),
            captureMethod: captureMethod.toApi(),
            currency: currency,
            metadata: metadata ?? [:],
            paymentMethodId: paymentMethod?.stripeId,
            amountTip: amountTip != nil ? Double(truncating: amountTip!) : nil,
            statementDescriptor: statementDescriptor,
            statementDescriptorSuffix: statementDescriptorSuffix,
            // Only Android
            amountCapturable: nil,
            amountReceived: nil,
            application: nil,
            applicationFeeAmount: nil,
            cancellationReason: nil,
            canceledAt: nil,
            clientSecret: nil,
            confirmationMethod: nil,
            customer: nil,
            description: description,
            invoice: nil,
            onBehalfOf: nil,
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

extension SetupIntent {
    func toApi() -> SetupIntentApi {
        return SetupIntentApi(
            id : stripeId,
            created: created,
            customerId: customer,
            metadata: metadata ?? [:],
            usage: usage.toApi(),
            status: status.toApi(),
            latestAttempt: latestAttempt?.toApi()
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
            id : stripeId,
            applicationId: application,
            created: created,
            customerId: customer,
            onBehalfOfId: onBehalfOf,
            paymentMethodId: paymentMethod,
            paymentMethodDetails: paymentMethodDetails?.toApi(),
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
            emvAuthData: emvAuthData,
            generatedCard: generatedCard
        )
    }
}

extension Refund {
    func toApi() -> RefundApi {
        return RefundApi(
            id: stripeId,
            amount: Int(amount),
            chargeId: charge,
            created: created,
            currency: currency,
            metadata: metadata,
            reason: reason,
            status: status.toApi(),
            paymentMethodDetails: paymentMethodDetails?.toApi(),
            failureReason: failureReason
        )
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



extension Error {
    func toApi() -> PlatformError {
        let error = self
        if let error = error as? NSError {
            return error.toApi()
        }
        return PlatformError("", self.localizedDescription, "\(self)")
    }
}

extension NSError {
    func toApi() -> PlatformError {
        guard self.scp_isAppleBuiltInReaderError else {
            return PlatformError("\(self.code)", self.localizedDescription, "\(self)")
        }
        return PlatformError(self.toApiCode(), self.localizedDescription, "\(self)")
    }

    func toApiCode() -> String {
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
            return TerminalExceptionCodeApi.localMobileUnsupportedAndroidVersion.rawValue // TODO: fix my name
        case .modelNotSupported:
            return TerminalExceptionCodeApi.unsupportedOperation.rawValue
        case .networkError:
            return TerminalExceptionCodeApi.stripeApiConnectionError.rawValue
        case .networkAuthenticationError:
            return TerminalExceptionCodeApi.stripeApiError.rawValue
        case .serviceConnectionError:
            return "serviceConnectionError"
        case .notReady:
            return TerminalExceptionCodeApi.sessionExpired.rawValue
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
            return TerminalExceptionCodeApi.readerBusy.rawValue
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
            return TerminalExceptionCodeApi.readerBusy.rawValue
        case .readCancelled:
            return "readCancelled"
        case .invalidAmount:
            return "invalidAmount"
        case .invalidCurrency:
            return "invalidCurrency"
        case .nfcDisabled:
            return TerminalExceptionCodeApi.localMobileNfcDisabled.rawValue
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
