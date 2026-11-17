import 'package:flutter_test/flutter_test.dart';
import 'package:inside_scoop/inside_scoop.dart';

void main() {
  group('ScoopResult', () {
    test('ScoopAvailable holding value properties', () {
      const result = ScoopResult.available('sample_value');

      expect(result.isAvailable, isTrue);
      expect(result.isUnavailable, isFalse);
      expect(result.valueOrNull, equals('sample_value'));

      // Pattern matching
      final extracted = switch (result) {
        ScoopAvailable(:final value) => value,
        ScoopUnavailable() => 'fallback',
      };
      expect(extracted, equals('sample_value'));
    });

    test('ScoopUnavailable properties and reasons', () {
      const result = ScoopResult<String>.unavailable(
        ScoopUnavailableReason.unsupportedOnPlatform,
        'Linux unsupported',
      );

      expect(result.isAvailable, isFalse);
      expect(result.isUnavailable, isTrue);
      expect(result.valueOrNull, isNull);

      final unavailable = result as ScoopUnavailable<String>;
      expect(
        unavailable.reason,
        equals(ScoopUnavailableReason.unsupportedOnPlatform),
      );
      expect(unavailable.message, equals('Linux unsupported'));
    });

    test('map transforms available value and preserves unavailable state', () {
      const available = ScoopResult.available(10);
      final mappedAvailable = available.map((v) => v * 2);

      expect(mappedAvailable.valueOrNull, equals(20));

      const unavailable = ScoopResult<int>.unavailable(
        ScoopUnavailableReason.sensorNotPresent,
      );
      final mappedUnavailable = unavailable.map((v) => v * 2);

      expect(mappedUnavailable.isUnavailable, isTrue);
      expect(
        (mappedUnavailable as ScoopUnavailable<int>).reason,
        equals(ScoopUnavailableReason.sensorNotPresent),
      );
    });

    test('when matches branches correctly', () {
      const available = ScoopResult.available('ok');
      final availableOutput = available.when(
        available: (v) => 'got: $v',
        unavailable: (r, m) => 'err: $r',
      );
      expect(availableOutput, equals('got: ok'));

      const unavailable = ScoopResult<String>.unavailable(
        ScoopUnavailableReason.permissionDenied,
        'need permission',
      );
      final unavailableOutput = unavailable.when(
        available: (v) => 'got: $v',
        unavailable: (r, m) => '$r - $m',
      );
      expect(
        unavailableOutput,
        equals('ScoopUnavailableReason.permissionDenied - need permission'),
      );
    });

    test('equality and toString verification', () {
      const a1 = ScoopAvailable<int>(42);
      const a2 = ScoopAvailable<int>(42);
      const a3 = ScoopAvailable<int>(99);

      expect(a1, equals(a2));
      expect(a1.hashCode, equals(a2.hashCode));
      expect(a1, isNot(equals(a3)));
      expect(a1.toString(), contains('42'));

      const u1 = ScoopUnavailable<int>(
        ScoopUnavailableReason.restrictedBySystem,
        'sandbox',
      );
      const u2 = ScoopUnavailable<int>(
        ScoopUnavailableReason.restrictedBySystem,
        'sandbox',
      );
      const u3 = ScoopUnavailable<int>(
        ScoopUnavailableReason.temporarilyUnavailable,
      );

      expect(u1, equals(u2));
      expect(u1.hashCode, equals(u2.hashCode));
      expect(u1, isNot(equals(u3)));
      expect(u1.toString(), contains('restrictedBySystem'));
    });
  });

  group('ScoopException', () {
    test('formats toString with message, reason, and cause', () {
      const exception = ScoopException(
        'Failed query',
        reason: ScoopUnavailableReason.internalError,
        cause: 'Native error -1',
      );

      expect(exception.message, equals('Failed query'));
      expect(exception.reason, equals(ScoopUnavailableReason.internalError));
      expect(exception.cause, equals('Native error -1'));
      expect(exception.toString(), contains('Failed query'));
      expect(exception.toString(), contains('internalError'));
      expect(exception.toString(), contains('Native error -1'));
    });
  });
}
