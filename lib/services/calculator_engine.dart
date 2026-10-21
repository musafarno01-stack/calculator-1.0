
class CalculatorEngine {
  const CalculatorEngine();

  double evaluate(String input) {
    final normalized = input
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll(' ', '');

    if (normalized.isEmpty) {
      throw const FormatException('Enter a calculation.');
    }

    final parser = _ExpressionParser(normalized);
    final result = parser.parse();

    if (!result.isFinite) {
      throw const FormatException('Result is out of range.');
    }

    return result.abs() < 1e-12 ? 0 : result;
  }

  String format(double value) {
    if (!value.isFinite) {
      throw const FormatException('Result is out of range.');
    }
    if (value == 0 || value.abs() < 1e-12) return '0';

    // Avoid showing floating-point artifacts such as 0.30000000004.
    final rounded = double.parse(value.toStringAsPrecision(12));
    if (rounded.abs() >= 1e12 || rounded.abs() < 1e-7) {
      return rounded.toStringAsExponential(6)
          .replaceFirst(RegExp(r'\.?0+e'), 'e');
    }

    return rounded.toString().replaceFirst(RegExp(r'\.0$'), '');
  }
}

class _ExpressionParser {
  _ExpressionParser(this.source);

  final String source;
  int index = 0;

  double parse() {
    final value = _expression();
    if (index != source.length) {
      throw const FormatException('Invalid expression.');
    }
    return value;
  }

  double _expression() {
    var value = _term();

    while (index < source.length) {
      final op = source[index];
      if (op != '+' && op != '-') break;
      index++;
      final right = _term();
      value = op == '+' ? value + right : value - right;
    }
    return value;
  }

  double _term() {
    var value = _unary();

    while (index < source.length) {
      final op = source[index];
      if (op != '*' && op != '/') break;
      index++;
      final right = _unary();

      if (op == '/' && right == 0) {
        throw const FormatException('Cannot divide by zero.');
      }
      value = op == '*' ? value * right : value / right;

      if (!value.isFinite) {
        throw const FormatException('Result is out of range.');
      }
    }
    return value;
  }

  double _unary() {
    if (index < source.length && source[index] == '+') {
      index++;
      return _unary();
    }
    if (index < source.length && source[index] == '-') {
      index++;
      return -_unary();
    }
    return _primary();
  }

  double _primary() {
    if (index < source.length && source[index] == '(') {
      index++;
      final value = _expression();
      if (index >= source.length || source[index] != ')') {
        throw const FormatException('Missing closing parenthesis.');
      }
      index++;
      return _percentage(value);
    }

    final start = index;
    var decimalSeen = false;

    while (index < source.length) {
      final char = source[index];
      if (char == '.') {
        if (decimalSeen) {
          throw const FormatException('Invalid decimal number.');
        }
        decimalSeen = true;
        index++;
      } else if (char.codeUnitAt(0) >= 48 &&
          char.codeUnitAt(0) <= 57) {
        index++;
      } else {
        break;
      }
    }

    if (start == index || source.substring(start, index) == '.') {
      throw const FormatException('Expected a number.');
    }

    final value = double.tryParse(source.substring(start, index));
    if (value == null || !value.isFinite) {
      throw const FormatException('Invalid number.');
    }
    return _percentage(value);
  }

  double _percentage(double value) {
    if (index < source.length && source[index] == '%') {
      index++;
      return value / 100;
    }
    return value;
  }
}
