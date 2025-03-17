import 'package:flutter_test/flutter_test.dart';
import 'package:test_1/services/game_state.service.dart';

void main() {
  group('formatResourceAmount tests', () {
    test('returns value as string when less than 1000', () {
      expect(GameState.formatResourceAmount(BigInt.from(999)), equals('999'));
    });

    test('formats 1000 as 1.00 A', () {
      expect(
        GameState.formatResourceAmount(BigInt.from(1000)),
        equals('1.00 A'),
      );
    });

    test('formats 2500 as 2.50 A', () {
      expect(
        GameState.formatResourceAmount(BigInt.from(2500)),
        equals('2.50 A'),
      );
    });

    test('formats 1,000,000 as 1.00 B', () {
      expect(
        GameState.formatResourceAmount(BigInt.from(1000000)),
        equals('1.00 B'),
      );
    });

    test('formats 1,500,000 as 1.50 B', () {
      expect(
        GameState.formatResourceAmount(BigInt.from(1500000)),
        equals('1.50 B'),
      );
    });

    test('formats 1,000,000,000 as 1.00 C', () {
      expect(
        GameState.formatResourceAmount(BigInt.from(1000000000)),
        equals('1.00 C'),
      );
    });

    test('formats a large number correctly', () {
      // Par exemple : 1,234,567,890,123
      // Divisions successives par 1000:
      // 1,234,567,890,123 / 1000 = 1,234,567,890.123  => divisions = 1
      // 1,234,567,890.123 / 1000 = 1,234,567.890123   => divisions = 2
      // 1,234,567.890123 / 1000 = 1,234.567890123     => divisions = 3
      // 1,234.567890123 / 1000 = 1.234567890123        => divisions = 4
      // Avec notre fonction _intToAlphabeticSuffix, pour 4 on obtient "D"
      // Donc le résultat attendu est "1.23 D"
      final amount = BigInt.parse('1234567890123');
      expect(GameState.formatResourceAmount(amount), equals('1.23 D'));
    });
  });
}
