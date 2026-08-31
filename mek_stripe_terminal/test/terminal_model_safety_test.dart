import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:mek_stripe_terminal/src/terminal_api.g.dart';

const _channelPrefix = 'dev.flutter.pigeon.mek_stripe_terminal.TerminalPlatformApi.';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const codec = TerminalPlatformApi.pigeonChannelCodec;

  void mockChannel(String method, Future<Object?> Function(Object?) handler) {
    final channel = BasicMessageChannel<Object?>('$_channelPrefix$method', codec);
    messenger.setMockDecodedMessageHandler<Object?>(channel, handler);
  }

  setUpAll(() async {
    mockChannel('initialize', (_) async => <Object?>[null]);
    await Terminal.init(fetchToken: () async => 'test-token');
  });

  tearDownAll(() {
    for (final method in <String>['initialize', 'startProcessRefund']) {
      final channel = BasicMessageChannel<Object?>('$_channelPrefix$method', codec);
      messenger.setMockDecodedMessageHandler<Object?>(channel, null);
    }
  });

  test('reader reports an unknown battery level without throwing', () {
    final reader = ReaderApi(simulated: false);

    expect(reader.batteryStatus, isNull);
  });

  test('refund with unavailable created date is represented as null', () {
    final refund = RefundApi(id: 're_test');

    expect(refund.created, isNull);
  });

  test('processRefund accepts a charge ID and forwards it to the host', () async {
    mockChannel('startProcessRefund', (message) async {
      final args = message! as List<Object?>;
      expect(args[1], 'ch_test');
      expect(args[2], isNull);
      expect(args[3], isNull);
      return <Object?>[RefundApi(id: 're_test')];
    });

    final refund = await Terminal.instance.processRefund(
      chargeId: 'ch_test',
      amount: 100,
      currency: 'cad',
    );

    expect(refund.id, 're_test');
  });

  test('processRefund accepts a PaymentIntent ID with its client secret', () async {
    mockChannel('startProcessRefund', (message) async {
      final args = message! as List<Object?>;
      expect(args[1], isNull);
      expect(args[2], 'pi_test');
      expect(args[3], 'pi_test_secret');
      return <Object?>[RefundApi(id: 're_test')];
    });

    final refund = await Terminal.instance.processRefund(
      paymentIntentId: 'pi_test',
      paymentIntentClientSecret: 'pi_test_secret',
      amount: 100,
      currency: 'cad',
    );

    expect(refund.id, 're_test');
  });

  test('processRefund rejects absent, partial, and ambiguous refund targets', () {
    void expectInvalid({
      String? chargeId,
      String? paymentIntentId,
      String? paymentIntentClientSecret,
    }) {
      expect(
        () => Terminal.instance.processRefund(
          chargeId: chargeId,
          paymentIntentId: paymentIntentId,
          paymentIntentClientSecret: paymentIntentClientSecret,
          amount: 100,
          currency: 'cad',
        ),
        throwsArgumentError,
      );
    }

    expectInvalid();
    expectInvalid(paymentIntentId: 'pi_test');
    expectInvalid(paymentIntentClientSecret: 'pi_test_secret');
    expectInvalid(chargeId: 'ch_test', paymentIntentId: 'pi_test');
    expectInvalid(chargeId: 'ch_test', paymentIntentClientSecret: 'pi_test_secret');
    expectInvalid(
      chargeId: 'ch_test',
      paymentIntentId: 'pi_test',
      paymentIntentClientSecret: 'pi_test_secret',
    );
  });
}
