import Foundation
import StripeTerminal

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
        return TerminalExceptionApi(
            apiError: apiError?.localizedDescription,
            code: code ?? TerminalExceptionCodeApi.unknown,
            message: localizedDescription,
            paymentIntent: paymentIntent?.toApi(),
            stackTrace: nil
        )
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
        case .invalidRequiredParameterOnBehalfOf:
            return .invalidParameter
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
        case .requestDynamicCurrencyConversionRequiresUpdatePaymentIntent:
            return .requestDynamicCurrencyConversionRequiresUpdatePaymentIntent
        case .dynamicCurrencyConversionNotAvailable:
            return .dynamicCurrencyConversionNotAvailable
        case .readerTippingParameterInvalid:
            return .invalidTipParameter
        case .invalidLocationIdParameter:
            return .invalidParameter
        case .collectInputsInvalidParameter:
            return .invalidParameter
        case .collectInputsUnsupported:
            return .collectInputsUnsupported
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
            return .readerBatteryCriticallyLow
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
        case .readerConnectionOfflineNeedsUpdate:
            return .readerConnectionOfflineNeedsUpdate
        case .readerConnectionOfflinePairingUnseenDisabled:
            return .locationConnectionNotAvailableOffline
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
        case .collectInputsTimedOut:
            return .collectInputsTimedOut
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
        case .appleBuiltInReaderAccountDeactivated:
            return .appleBuiltInReaderAccountDeactivated
        case .readerMissingEncryptionKeys:
            return .readerMissingEncryptionKeys
        case .unexpectedSdkError:
            return .unexpectedSdkError
        case .unexpectedReaderError:
            return .unexpectedReaderError
        case .encryptionKeyFailure:
            return .encryptionKeyFailure
        case .encryptionKeyStillInitializing:
            return .encryptionKeyStillInitializing
        case .collectInputsApplicationError:
            return .collectInputsApplicationError
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
        case .onlinePinNotSupportedOffline:
            return .onlinePinNotSupportedOffline
        case .offlineTestCardInLivemode:
            return .testCardInLiveMode
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
