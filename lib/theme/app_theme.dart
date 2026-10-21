
import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const orange = Color(0xFFFF9F0A);

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        background: const Color(0xFF101114),
        display: const Color(0xFF17191E),
        number: const Color(0xFF252830),
        function: const Color(0xFF414550),
        text: Colors.white,
        secondary: const Color(0xFFA6A9B2),
      );

  static ThemeData light() => _build(
        brightness: Brightness.light,
        background: const Color(0xFFF4F5F7),
        display: Colors.white,
        number: const Color(0xFFE7E9EE),
        function: const Color(0xFFD1D5DE),
        text: const Color(0xFF17191E),
        secondary: const Color(0xFF555B66),
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color display,
    required Color number,
    required Color function,
    required Color text,
    required Color secondary,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: orange,
      brightness: brightness,
      surface: background,
      primary: orange,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
      ),
      extensions: [
        CalculatorColors(
          background: background,
          display: display,
          number: number,
          function: function,
          text: text,
          secondary: secondary,
          operator: orange,
          error: const Color(0xFFFF6464),
          separator: const Color(0xFF30333B),
        ),
      ],
    );
  }
}

class CalculatorColors extends ThemeExtension<CalculatorColors> {
  const CalculatorColors({
    required this.background,
    required this.display,
    required this.number,
    required this.function,
    required this.text,
    required this.secondary,
    required this.operator,
    required this.error,
    required this.separator,
  });

  final Color background;
  final Color display;
  final Color number;
  final Color function;
  final Color text;
  final Color secondary;
  final Color operator;
  final Color error;
  final Color separator;

  @override
  CalculatorColors copyWith({
    Color? background,
    Color? display,
    Color? number,
    Color? function,
    Color? text,
    Color? secondary,
    Color? operator,
    Color? error,
    Color? separator,
  }) =>
      CalculatorColors(
        background: background ?? this.background,
        display: display ?? this.display,
        number: number ?? this.number,
        function: function ?? this.function,
        text: text ?? this.text,
        secondary: secondary ?? this.secondary,
        operator: operator ?? this.operator,
        error: error ?? this.error,
        separator: separator ?? this.separator,
      );

  @override
  CalculatorColors lerp(
    covariant CalculatorColors? other,
    double t,
  ) {
    if (other == null) return this;
    return CalculatorColors(
      background: Color.lerp(background, other.background, t)!,
      display: Color.lerp(display, other.display, t)!,
      number: Color.lerp(number, other.number, t)!,
      function: Color.lerp(function, other.function, t)!,
      text: Color.lerp(text, other.text, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      operator: Color.lerp(operator, other.operator, t)!,
      error: Color.lerp(error, other.error, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
    );
  }
}
