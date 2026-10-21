
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({
    super.key,
    required this.expression,
    required this.result,
    this.error = false,
  });

  final String expression;
  final String result;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CalculatorColors>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: colors.display,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: Align(
              alignment: Alignment.bottomRight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  expression,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 24,
                    color: colors.secondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Align(
              alignment: Alignment.bottomRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  result,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: error ? colors.error : colors.text,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
