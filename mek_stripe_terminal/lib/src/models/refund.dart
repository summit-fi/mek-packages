import 'package:mek_stripe_terminal/src/terminal_api.g.dart';

typedef Refund = RefundApi;

typedef RefundStatus = RefundStatusApi;

typedef PaymentMethodDetails = PaymentMethodDetailsApi;

extension RefundUtils on RefundApi {
  DateTime? get created => createdInMilliseconds != null
      ? DateTime.fromMillisecondsSinceEpoch(createdInMilliseconds!, isUtc: true)
      : null;
}
