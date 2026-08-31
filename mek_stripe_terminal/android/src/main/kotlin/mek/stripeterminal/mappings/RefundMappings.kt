package mek.stripeterminal.mappings

import com.stripe.stripeterminal.external.models.Refund
import RefundApi
import RefundStatusApi
import mek.stripeterminal.toHashMap

fun Refund.toApi(): RefundApi {
    return RefundApi(
        id = id,
        amount = amount,
        chargeId = chargeId,
        createdInMilliseconds = created?.times(1000),
        currency = currency,
        metadata = metadata?.toHashMap(),
        reason = reason,
        status = when (status) {
            "succeeded" -> RefundStatusApi.SUCCEEDED
            "pending" -> RefundStatusApi.PENDING
            "failed" -> RefundStatusApi.FAILED
            else -> null
        },
        paymentMethodDetails = paymentMethodDetails?.toApi(),
        failureReason = failureReason
    )
}
