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
            location: location?.toApi(),
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
        case .requiresAction:
            return .requiresAction
        @unknown default:
            fatalError("Not supported payment intent status: \(self)")
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

extension CardPresentDetails {
    func toApi() -> CardPresentDetailsApi {
        return CardPresentDetailsApi(
            brand: brand.toApi(),
            country: country,
            expMonth: expMonth,
            expYear: expYear,
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
            id: stripeId!,
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
            applicationId: nil,
            applicationFeeAmount: nil,
            cancellationReason: nil,
            canceledAt: nil,
            clientSecret: nil,
            confirmationMethod: nil,
            customerId: nil,
            description: description,
            invoiceId: nil,
            onBehalfOf: nil,
            reviewId: nil,
            receiptEmail: nil,
            setupFutureUsage: nil,
            transferGroup: nil
        )
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
            onBehalfOf: onBehalfOf,
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

extension TerminalExceptionApi {
    func toPlatformError() -> PlatformError {
        return PlatformError("mek_stripe_terminal", nil, serialize())
    }
}

extension NSError {
    func toPlatformError(apiError: Error? = nil, paymentIntent: PaymentIntent? = nil) -> PlatformError {
        if (self.domain != "com.stripe-terminal") {
            return PlatformError("\(self.domain):\(self.code)", self.localizedDescription, "\(self)")
        }
        let apiException = toApi(apiError: apiError, paymentIntent: paymentIntent)
        return apiException.toPlatformError()
    }
    
    func toApi(apiError: Error? = nil, paymentIntent: PaymentIntent? = nil) -> TerminalExceptionApi {
        let code = self.toApiCode();
        if let code {
            return TerminalExceptionApi(
                code: code,
                message: localizedDescription,
                stackTrace: nil,
                paymentIntent: paymentIntent?.toApi(),
                apiError: apiError?.localizedDescription
            )
        }
        return createApiException(TerminalExceptionCodeApi.unknown, "Unsupported Terminal exception code: \(self.code)")
    }
    
    private func toApiCode() -> TerminalExceptionCodeApi? {
        let error = ErrorCode(_nsError: self)
        
        switch error.code {
        case .cancelFailedAlreadyCompleted:
            // Ignore this error, the plugin does not allow you to undo an operation more than once
            return nil
        case .notConnectedToReader:
            return .notConnectedToReader
        case .alreadyConnectedToReader:
            return .alreadyConnectedToReader
        case .connectionTokenProviderCompletedWithNothing:
            return nil
        case .connectionTokenProviderCompletedWithNothingWhileForwarding:
            return .connectionTokenProviderErrorWhileForwarding
        case .confirmInvalidPaymentIntent:
            return .confirmInvalidPaymentIntent
        case .nilPaymentIntent:
            return nil
        case .nilSetupIntent:
            return nil
        case .nilRefundPaymentMethod:
            return nil
        case .invalidRefundParameters:
            return .invalidParameter
        case .invalidClientSecret:
            return .invalidClientSecret
        case .invalidDiscoveryConfiguration:
            return nil
        case .invalidReaderForUpdate:
            return .invalidReaderForUpdate
        case .unsupportedSDK:
            return .unsupportedSdk
        case .featureNotAvailableWithConnectedReader:
            return .featureNotAvailableWithConnectedReader
        case .featureNotAvailable:
            return .featureNotEnabledOnAccount
        case .invalidListLocationsLimitParameter:
            return .invalidParameter
        case .bluetoothConnectionInvalidLocationIdParameter:
            return .invalidParameter
        case .invalidRequiredParameter:
            return .invalidRequiredParameter
        case .accountIdMismatchWhileForwarding:
            return .accountIdMismatchWhileForwarding
        case .updatePaymentIntentUnavailableWhileOffline:
            return .updatePaymentIntentUnavailableWhileOffline
        case .updatePaymentIntentUnavailableWhileOfflineModeEnabled:
            return .updatePaymentIntentUnavailableWhileOfflineModeEnabled
        case .forwardingTestModePaymentInLiveMode:
            return .forwardingTestModePaymentInLiveMode
        case .forwardingLiveModePaymentInTestMode:
            return .forwardingLiveModePaymentInTestMode
        case .readerConnectionConfigurationInvalid:
            return .invalidParameter
        case .readerTippingParameterInvalid:
            return .invalidTipParameter
        case .invalidLocationIdParameter:
            return .invalidParameter
        case .canceled:
            return .canceled
        case .locationServicesDisabled:
            return .locationServicesDisabled
        case .bluetoothDisabled:
            return .bluetoothDisabled
        case .bluetoothAccessDenied:
            return .bluetoothPermissionDenied
        case .bluetoothScanTimedOut:
            return .bluetoothScanTimedOut
        case .bluetoothLowEnergyUnsupported:
            return .bluetoothLowEnergyUnsupported
        case .readerSoftwareUpdateFailedBatteryLow:
            return .readerSoftwareUpdateFailedBatteryLow
        case .readerSoftwareUpdateFailedInterrupted:
            return .readerSoftwareUpdateFailedInterrupted
        case .readerSoftwareUpdateFailedExpiredUpdate:
            return .readerSoftwareUpdateFailedExpiredUpdate
        case .bluetoothConnectionFailedBatteryCriticallyLow:
            return .bluetoothConnectionFailedBatteryCriticallyLow
        case .cardInsertNotRead:
            return .cardInsertNotRead
        case .cardSwipeNotRead:
            return .cardSwipeNotRead
        case .cardReadTimedOut:
            return .cardReadTimedOut
        case .cardRemoved:
            return .cardRemoved
        case .cardLeftInReader:
            return .cardLeftInReader
        case .offlinePaymentsDatabaseTooLarge:
            return .offlinePaymentsDatabaseTooLarge
        case .readerConnectionNotAvailableOffline:
            return .readerConnectionNotAvailableOffline
        case .readerConnectionOfflineLocationMismatch:
            return .readerConnectionOfflineLocationMismatch
        case .noLastSeenAccount:
            return .noLastSeenAccount
        case .amountExceedsMaxOfflineAmount:
            return .amountExceedsMaxOfflineAmount
        case .invalidOfflineCurrency:
            return .invalidOfflineCurrency
        case .missingEMVData:
            return .missingEmvData
        case .commandNotAllowed:
            return .commandNotAllowed
        case .unsupportedMobileDeviceConfiguration:
            return .unsupportedMobileDeviceConfiguration
        case .passcodeNotEnabled:
            return .passcodeNotEnabled
        case .commandNotAllowedDuringCall:
            return .commandNotAllowedDuringCall
        case .invalidAmount:
            return .invalidAmount
        case .invalidCurrency:
            return .invalidCurrency
        case .appleBuiltInReaderTOSAcceptanceRequiresiCloudSignIn:
            return .appleBuiltInReaderTOSAcceptanceRequiresiCloudSignIn
        case .appleBuiltInReaderTOSAcceptanceCanceled:
            return .appleBuiltInReaderTOSAcceptanceCanceled
        case .readerBusy:
            return .readerBusy
        case .incompatibleReader:
            return .incompatibleReader
        case .readerCommunicationError:
            return .readerCommunicationError
        case .nfcDisabled:
            return .nfcDisabled
        case .bluetoothError:
            return .bluetoothError
        case .bluetoothConnectTimedOut:
            return .bluetoothConnectTimedOut
        case .bluetoothDisconnected:
            return .bluetoothDisconnected
        case .bluetoothPeerRemovedPairingInformation:
            return .bluetoothPeerRemovedPairingInformation
        case .bluetoothAlreadyPairedWithAnotherDevice:
            return .bluetoothAlreadyPairedWithAnotherDevice
        case .readerSoftwareUpdateFailed:
            return .readerSoftwareUpdateFailed
        case .readerSoftwareUpdateFailedReaderError:
            return .readerSoftwareUpdateFailedReaderError
        case .readerSoftwareUpdateFailedServerError:
            return .readerSoftwareUpdateFailedServerError
        case .unsupportedReaderVersion:
            return .unsupportedReaderVersion
        case .unknownReaderIpAddress:
            return .unknownReaderIpAddress
        case .internetConnectTimeOut:
            return .internetConnectTimeOut
        case .connectFailedReaderIsInUse:
            return .connectFailedReaderIsInUse
        case .bluetoothReconnectStarted:
            return .bluetoothReconnectStarted
        case .readerNotAccessibleInBackground:
            return .readerNotAccessibleInBackground
        case .appleBuiltInReaderFailedToPrepare:
            return .appleBuiltInReaderFailedToPrepare
        case .appleBuiltInReaderDeviceBanned:
            return .appleBuiltInReaderDeviceBanned
        case .appleBuiltInReaderTOSNotYetAccepted:
            return .appleBuiltInReaderTOSNotYetAccepted
        case .appleBuiltInReaderTOSAcceptanceFailed:
            return .appleBuiltInReaderTOSAcceptanceFailed
        case .appleBuiltInReaderMerchantBlocked:
            return .appleBuiltInReaderMerchantBlocked
        case .appleBuiltInReaderInvalidMerchant:
            return .appleBuiltInReaderInvalidMerchant
        case .unexpectedSdkError:
            return .unexpectedSdkError
        case .unexpectedReaderError:
            return .unexpectedReaderError
        case .declinedByStripeAPI:
            return .declinedByStripeApi
        case .declinedByReader:
            return .declinedByReader
        case .commandRequiresCardholderConsent:
            return .customerConsentRequired
        case .refundFailed:
            return .refundFailed
        case .cardSwipeNotAvailable:
            return .cardSwipeNotAvailable
        case .interacNotSupportedOffline:
            return .interacNotSupportedOffline
        case .offlineAndCardExpired:
            return .offlineAndCardExpired
        case .offlineTransactionDeclined:
            return .offlineTransactionDeclined
        case .offlineCollectAndConfirmMismatch:
            return .offlineCollectAndConfirmMismatch
        case .notConnectedToInternet:
            return .notConnectedToInternet
        case .requestTimedOut:
            return .requestTimedOut
        case .stripeAPIError:
            return .stripeApiError
        case .stripeAPIResponseDecodingError:
            return .stripeApiResponseDecodingError
        case .internalNetworkError:
            return .internalNetworkError
        case .connectionTokenProviderCompletedWithError:
            return .connectionTokenProviderError
        case .connectionTokenProviderCompletedWithErrorWhileForwarding:
            return .connectionTokenProviderErrorWhileForwarding
        case .connectionTokenProviderTimedOut:
            return .connectionTokenProviderTimedOut
        case .sessionExpired:
            return .sessionExpired
        case .notConnectedToInternetAndOfflineBehaviorRequireOnline:
            return .notConnectedToInternetAndOfflineBehaviorRequireOnline
        case .offlineBehaviorForceOfflineWithFeatureDisabled:
            return .offlineBehaviorForceOfflineWithFeatureDisabled
        @unknown default:
            fatalError()
        }
    }
}
