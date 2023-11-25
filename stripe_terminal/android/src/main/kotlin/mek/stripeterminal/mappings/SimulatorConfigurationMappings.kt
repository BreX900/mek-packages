package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.SimulateReaderUpdate
import com.stripe.stripeterminal.external.models.SimulatedCard
import com.stripe.stripeterminal.external.models.SimulatedCardType
import com.stripe.stripeterminal.external.models.SimulatorConfiguration
import mek.stripeterminal.api.SimulateReaderUpdateApi
import mek.stripeterminal.api.SimulatedCardApi
import mek.stripeterminal.api.SimulatedCardTypeApi
import mek.stripeterminal.api.SimulatorConfigurationApi

fun SimulatorConfigurationApi.toHost(): SimulatorConfiguration {
    return SimulatorConfiguration(
        update = update.toHost(),
        simulatedCard = simulatedCard.toHost(),
        simulatedTipAmount = simulatedTipAmount,
    )
}

fun SimulateReaderUpdateApi.toHost(): SimulateReaderUpdate {
    return when (this) {
        SimulateReaderUpdateApi.AVAILABLE -> SimulateReaderUpdate.UPDATE_AVAILABLE
        SimulateReaderUpdateApi.NONE -> SimulateReaderUpdate.NONE
        SimulateReaderUpdateApi.REQUIRED -> SimulateReaderUpdate.REQUIRED
        SimulateReaderUpdateApi.RANDOM -> SimulateReaderUpdate.RANDOM
    }
}

fun SimulatedCardApi.toHost(): SimulatedCard {
    if (type != null) return SimulatedCard(type.toHost())
    return SimulatedCard(testCardNumber!!)
}

fun SimulatedCardTypeApi.toHost(): SimulatedCardType {
    return when (this) {
        SimulatedCardTypeApi.VISA -> SimulatedCardType.VISA
        SimulatedCardTypeApi.VISA_DEBIT -> SimulatedCardType.VISA_DEBIT
        SimulatedCardTypeApi.VISA_US_COMMON_DEBIT -> SimulatedCardType.VISA_US_COMMON_DEBIT
        SimulatedCardTypeApi.MASTERCARD -> SimulatedCardType.MASTERCARD
        SimulatedCardTypeApi.MASTER_DEBIT -> SimulatedCardType.MASTERCARD_DEBIT
        SimulatedCardTypeApi.MASTERCARD_PREPAID -> SimulatedCardType.MASTERCARD_PREPAID
        SimulatedCardTypeApi.AMEX -> SimulatedCardType.AMEX
        SimulatedCardTypeApi.AMEX2 -> SimulatedCardType.AMEX_2
        SimulatedCardTypeApi.DISCOVER -> SimulatedCardType.DISCOVER
        SimulatedCardTypeApi.DISCOVER2 -> SimulatedCardType.DISCOVER_2
        SimulatedCardTypeApi.DINERS -> SimulatedCardType.DINERS
        SimulatedCardTypeApi.DINERS14_DIGIT -> SimulatedCardType.DINERS_14_DIGITS
        SimulatedCardTypeApi.JBC -> SimulatedCardType.JCB
        SimulatedCardTypeApi.UNION_PAY -> SimulatedCardType.UNION_PAY
        SimulatedCardTypeApi.INTERAC -> SimulatedCardType.INTERAC
        SimulatedCardTypeApi.EFTPOS_AU_DEBIT -> SimulatedCardType.EFTPOS_AU_DEBIT
        SimulatedCardTypeApi.EFTPOS_AU_VISA_DEBIT -> SimulatedCardType.EFTPOS_AU_VISA_DEBIT
        SimulatedCardTypeApi.EFTPOS_AU_DEBIT_MASTERCARD -> SimulatedCardType.EFTPOS_AU_DEBIT_MASTERCARD
        SimulatedCardTypeApi.CHARGE_DECLINED -> SimulatedCardType.CHARGE_DECLINED
        SimulatedCardTypeApi.CHARGE_DECLINED_INSUFFICIENT_FUNDS -> SimulatedCardType.CHARGE_DECLINED_INSUFFICIENT_FUNDS
        SimulatedCardTypeApi.CHARGE_DECLINED_LOST_CARD -> SimulatedCardType.CHARGE_DECLINED_LOST_CARD
        SimulatedCardTypeApi.CHARGE_DECLINED_STOLEN_CARD -> SimulatedCardType.CHARGE_DECLINED_STOLEN_CARD
        SimulatedCardTypeApi.CHARGE_DECLINED_EXPIRED_CARD -> SimulatedCardType.CHARGE_DECLINED_EXPIRED_CARD
        SimulatedCardTypeApi.CHARGE_DECLINED_PROCESSING_ERROR -> SimulatedCardType.CHARGE_DECLINED_PROCESSING_ERROR
        SimulatedCardTypeApi.ONLINE_PIN_CVM -> SimulatedCardType.ONLINE_PIN_CVM
        SimulatedCardTypeApi.ONLINE_PIN_SCA_RETRY -> SimulatedCardType.ONLINE_PIN_SCA_RETRY
        SimulatedCardTypeApi.OFFLINE_PIN_CVM -> SimulatedCardType.OFFLINE_PIN_CVM
        SimulatedCardTypeApi.OFFLINE_PIN_SCA_RETRY -> SimulatedCardType.OFFLINE_PIN_SCA_RETRY
    }
}
