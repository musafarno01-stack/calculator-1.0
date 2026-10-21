
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'calculator_button.dart';

class CalculatorKeypad extends StatelessWidget {
  const CalculatorKeypad({
    super.key,
    required this.onKey,
  });

  final ValueChanged<String> onKey;

  static const _rows = [
    ['AC', '+/-', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['⌫', '0', '.', '='],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CalculatorColors>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final rowHeight =
            ((constraints.maxHeight - gap * 4) / 5).clamp(0.0, 1000.0);

        return Column(
          children: [
            for (var r = 0; r < _rows.length; r++) ...[
              if (r > 0) const SizedBox(height: gap),
              SizedBox(
                height: rowHeight,
                child: Row(
                  children: [
                    for (var c = 0; c < 4; c++) ...[
                      if (c > 0) const SizedBox(width: gap),
                      Expanded(
                        child: _buildButton(
                          _rows[r][c],
                          colors,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildButton(String label, CalculatorColors colors) {
    final isOperator = const ['÷', '×', '−', '+'].contains(label);
    final isFunction = const ['AC', '+/-', '%', '⌫'].contains(label);
    final isEquals = label == '=';

    return CalculatorButton(
      label: label,
      onPressed: () => onKey(label),
      background: isEquals || isOperator
          ? colors.operator
          : isFunction
              ? colors.function
              : colors.number,
      foreground: isOperator || isEquals ? Colors.white : colors.text,
      fontSize: isFunction ? 19 : isOperator ? 28 : 24,
      semanticLabel: label == '⌫'
          ? 'Backspace'
          : label == '+/-'
              ? 'Toggle sign'
              : label == '='
                  ? 'Calculate'
                  : label,
    );
  }
}
