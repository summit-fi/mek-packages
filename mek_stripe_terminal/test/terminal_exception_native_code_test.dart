import 'package:flutter_test/flutter_test.dart';
import 'package:mek_stripe_terminal/mek_stripe_terminal.dart';
import 'package:mek_stripe_terminal/src/terminal_api.g.dart';

void main() {
  test('native exception code survives the platform api round trip', () {
    final source = TerminalExceptionApi(
      code: TerminalExceptionCodeApi.invalidParameter,
      message: 'Invalid reader configuration',
      nativeCode: 'INVALID_MOTO_CONFIGURATION',
    );

    final decoded = TerminalExceptionApi.decode(source.encode());

    expect(decoded, source);
    expect(decoded.nativeCode, 'INVALID_MOTO_CONFIGURATION');
  });

  test('public exception preserves normalized and native codes', () {
    final exception = TerminalException.fromApi(
      TerminalExceptionApi(
        code: TerminalExceptionCodeApi.canceledByReader,
        message: 'The reader canceled the operation',
        nativeCode: 'CANCELED_BY_READER',
      ),
    );

    expect(exception.code, TerminalExceptionCodeApi.canceledByReader);
    expect(exception.nativeCode, 'CANCELED_BY_READER');
    expect(exception.toString(), contains('canceledByReader'));
    expect(exception.toString(), contains('CANCELED_BY_READER'));
  });

  test('new platform codes are exposed by the public enum', () {
    expect(
      <TerminalExceptionCodeApi>[
        TerminalExceptionCodeApi.missingPrerequisite,
        TerminalExceptionCodeApi.tapToPayLibraryNotIncluded,
        TerminalExceptionCodeApi.canceledByReader,
        TerminalExceptionCodeApi.cancelFailedAlreadyCompleted,
        TerminalExceptionCodeApi.connectionTokenProviderCompletedWithNothing,
        TerminalExceptionCodeApi.nilPaymentIntent,
        TerminalExceptionCodeApi.nilSetupIntent,
        TerminalExceptionCodeApi.nilRefundPaymentMethod,
        TerminalExceptionCodeApi.invalidDiscoveryConfiguration,
      ],
      hasLength(9),
    );
  });
}
