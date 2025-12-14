//
//  SimulatorConfigurationMappings.swift
//  mek_stripe_terminal
//
//  Created by Kuama on 25/11/23.
//

import Foundation
import StripeTerminal

extension SimulateReaderUpdateApi {
    func toHost() -> SimulateReaderUpdate {
        switch self {
        case SimulateReaderUpdateApi.available:
            return SimulateReaderUpdate.available
        case SimulateReaderUpdateApi.none:
            return SimulateReaderUpdate.none
        case SimulateReaderUpdateApi.required:
            return SimulateReaderUpdate.required
        case SimulateReaderUpdateApi.random:
            return SimulateReaderUpdate.random
        }
    }
}

extension SimulatedCardApi {
    func toHost() -> SimulatedCard {
        if let type {
            return SimulatedCard(type: type.toHost())
        }
        return SimulatedCard(testCardNumber: testCardNumber ?? "")
    }

}

extension SimulatedCardTypeApi {
    func toHost() -> SimulatedCardType {
        switch self {
        case SimulatedCardTypeApi.visa:
            return SimulatedCardType.visa
        case SimulatedCardTypeApi.visaDebit:
            return SimulatedCardType.visaDebit
        case SimulatedCardTypeApi.visaUsCommonDebit:
            return SimulatedCardType.visaUsCommonDebit
        case SimulatedCardTypeApi.mastercard:
            return SimulatedCardType.mastercard
        case SimulatedCardTypeApi.masterDebit:
            return SimulatedCardType.masterDebit
        case SimulatedCardTypeApi.mastercardPrepaid:
            return SimulatedCardType.mastercardPrepaid
        case SimulatedCardTypeApi.amex:
            return SimulatedCardType.amex
        case SimulatedCardTypeApi.amex2:
            return SimulatedCardType.amex2
        case SimulatedCardTypeApi.discover:
            return SimulatedCardType.discover
        case SimulatedCardTypeApi.discover2:
            return SimulatedCardType.discover2
        case SimulatedCardTypeApi.diners:
            return SimulatedCardType.diners
        case SimulatedCardTypeApi.diners14Digit:
            return SimulatedCardType.diners14Digit
        case SimulatedCardTypeApi.jbc:
            return SimulatedCardType.jcb
        case SimulatedCardTypeApi.unionPay:
            return SimulatedCardType.unionPay
        case SimulatedCardTypeApi.interac:
            return SimulatedCardType.interac
        case SimulatedCardTypeApi.eftposAuDebit:
            return SimulatedCardType.eftposAuDebit
        case SimulatedCardTypeApi.eftposAuVisaDebit:
            return SimulatedCardType.eftposAuDebit
        case SimulatedCardTypeApi.eftposAuDebitMastercard:
            return SimulatedCardType.eftposAuDebitMastercard
        case SimulatedCardTypeApi.chargeDeclined:
            return SimulatedCardType.chargeDeclined
        case SimulatedCardTypeApi.chargeDeclinedInsufficientFunds:
            return SimulatedCardType.chargeDeclinedInsufficientFunds
        case SimulatedCardTypeApi.chargeDeclinedLostCard:
            return SimulatedCardType.chargeDeclinedLostCard
        case SimulatedCardTypeApi.chargeDeclinedStolenCard:
            return SimulatedCardType.chargeDeclinedStolenCard
        case SimulatedCardTypeApi.chargeDeclinedExpiredCard:
            return SimulatedCardType.chargeDeclinedExpiredCard
        case SimulatedCardTypeApi.chargeDeclinedProcessingError:
            return SimulatedCardType.chargeDeclinedProcessingError
        case SimulatedCardTypeApi.onlinePinCvm:
            return SimulatedCardType.onlinePinCvm
        case SimulatedCardTypeApi.onlinePinScaRetry:
            return SimulatedCardType.onlinePinScaRetry
        case SimulatedCardTypeApi.offlinePinCvm:
            return SimulatedCardType.offlinePinCvm
        case SimulatedCardTypeApi.offlinePinScaRetry:
            return SimulatedCardType.offlinePinScaRetry
        }
    }
}
