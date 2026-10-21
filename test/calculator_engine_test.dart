
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_calculator/services/calculator_engine.dart';

void main() {
  const engine = CalculatorEngine();

  group('CalculatorEngine', () {
    test('addition, subtraction, multiplication and division', () {
      expect(engine.evaluate('2+3'), 5);
      expect(engine.evaluate('9-4'), 5);
      expect(engine.evaluate('6*7'), 42);
      expect(engine.evaluate('8/2'), 4);
    });

    test('operator precedence', () {
      expect(engine.evaluate('2+3*4'), 14);
      expect(engine.evaluate('(2+3)*4'), 20);
    });

    test('decimals and floating point formatting', () {
      expect(engine.evaluate('0.1+0.2'), closeTo(0.3, 1e-10));
      expect(engine.format(engine.evaluate('0.1+0.2')), '0.3');
      expect(engine.evaluate('1.25*2'), 2.5);
    });

    test('negative numbers', () {
      expect(engine.evaluate('-5+2'), -3);
      expect(engine.evaluate('-(2+3)'), -5);
      expect(engine.evaluate('2*-3'), -6);
    });

    test('percentage uses standalone percentage semantics', () {
      expect(engine.evaluate('50%'), 0.5);
      expect(engine.evaluate('200+10%'), 200.1);
      expect(engine.evaluate('50%*200'), 100);
    });

    test('division by zero is rejected', () {
      expect(
        () => engine.evaluate('10/0'),
        throwsA(isA<FormatException>()),
      );
    });

    test('invalid input is rejected', () {
      for (final input in ['', '2+', '1..2', 'abc', '(2+3']) {
        expect(
          () => engine.evaluate(input),
          throwsA(isA<FormatException>()),
          reason: 'Input "$input" should be rejected',
        );
      }
    });

    test('large values and small values are formatted safely', () {
      expect(engine.format(1000000000000), contains('e'));
      expect(engine.format(0.00000001), contains('e'));
      expect(engine.format(0), '0');
      expect(
        () => engine.format(double.infinity),
        throwsA(isA<FormatException>()),
      );
    });

    test('chained arithmetic evaluates left to right by precedence', () {
      expect(engine.evaluate('10-2-3'), 5);
      expect(engine.evaluate('20/2/2'), 5);
    });
  });
}
