
import 'package:flutter/material.dart';

import '../models/calculation_history_item.dart';
import '../services/ad_service.dart';
import '../services/calculator_engine.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/calculator_display.dart';
import '../widgets/calculator_keypad.dart';
import 'history_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({
    super.key,
    required this.historyService,
    required this.adService,
    required this.isDark,
    required this.onThemeChanged,
  });

  final HistoryService historyService;
  final AdService adService;
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _engine = const CalculatorEngine();

  String _input = '';
  String _result = '0';
  String? _error;
  bool _justEvaluated = false;

  bool get _endsWithOperator =>
      _input.isNotEmpty &&
      const ['+', '-', '×', '÷'].contains(_input.characters.last);

  void _key(String key) {
    setState(() {
      _error = null;

      switch (key) {
        case 'AC':
          _input = '';
          _result = '0';
          _justEvaluated = false;
          return;
        case '⌫':
          if (_justEvaluated) {
            _input = '';
            _result = '0';
            _justEvaluated = false;
          } else if (_input.isNotEmpty) {
            _input = _input.substring(0, _input.length - 1);
            _preview();
          }
          return;
        case '+/-':
          _toggleSign();
          _preview();
          return;
        case '%':
          if (_input.isNotEmpty && !_endsWithOperator) {
            _input += '%';
            _justEvaluated = false;
            _preview();
          }
          return;
        case '=':
          _calculate();
          return;
      }

      if (const ['+', '−', '×', '÷'].contains(key)) {
        _operator(key);
        return;
      }

      if (key == '.') {
        if (_justEvaluated) {
          _input = '0';
          _justEvaluated = false;
        }
        final token = _lastNumberToken();
        if (token.contains('.') || token.contains('%')) return;
        if (token.isEmpty) _input += '0';
        _input += '.';
        _preview();
        return;
      }

      if (RegExp(r'^[0-9]$').hasMatch(key)) {
        if (_justEvaluated) {
          _input = '';
          _justEvaluated = false;
        }
        final token = _lastNumberToken();
        if (token == '0' && key == '0') return;
        if (token == '0' && !token.contains('.')) {
          _input = _input.substring(0, _input.length - 1) + key;
        } else {
          _input += key;
        }
        _preview();
      }
    });
  }

  String _lastNumberToken() {
    final match = RegExp(r'(\d*\.?\d+\.?\d*%?)$').firstMatch(_input);
    return match?.group(0) ?? '';
  }

  void _operator(String op) {
    if (_input.isEmpty) {
      if (op == '−') _input = '-';
      return;
    }

    if (_endsWithOperator) {
      _input = _input.substring(0, _input.length - 1) + op;
    } else if (!_input.endsWith('.')) {
      _input += op;
    }
    _justEvaluated = false;
    _preview();
  }

  void _toggleSign() {
    if (_input.isEmpty) {
      _input = '-';
      return;
    }

    final match = RegExp(r'(\d*\.?\d+%?)$').firstMatch(_input);
    if (match == null) {
      if (_input.endsWith('−') || _input.endsWith('+') ||
          _input.endsWith('×') || _input.endsWith('÷')) {
        if (_input.endsWith('−')) {
          _input = _input.substring(0, _input.length - 1);
        } else {
          _input += '−';
        }
      }
      return;
    }

    final token = match.group(0)!;
    final start = match.start;
    final before = _input.substring(0, start);

    if (before.endsWith('−') &&
        (before.length == 1 ||
            const ['+', '−', '×', '÷'].contains(before[before.length - 2]))) {
      _input = before.substring(0, before.length - 1) + token;
    } else {
      _input = '$before−$token';
    }
  }

  void _preview() {
    if (_input.isEmpty || _endsWithOperator || _input.endsWith('.')) {
      _result = '0';
      return;
    }

    try {
      _result = _engine.format(_engine.evaluate(_input));
    } on FormatException {
      _result = '0';
    }
  }

  Future<void> _calculate() async {
    if (_input.isEmpty || _endsWithOperator || _input.endsWith('.')) return;

    final expression = _input;
    try {
      final value = _engine.evaluate(expression);
      final result = _engine.format(value);

      setState(() {
        _result = result;
        _input = expression;
        _justEvaluated = true;
      });

      widget.adService.recordSuccessfulCalculation();

      try {
        await widget.historyService.add(
          CalculationHistoryItem(
            expression: expression,
            result: result,
            timestamp: DateTime.now(),
          ),
        );
      } catch (_) {
        // Local storage failure must not block the calculator.
      }
    } on FormatException catch (e) {
      setState(() {
        _error = e.message;
        _result = 'Error';
      });
    }
  }

  Future<void> _openHistory() async {
    // Navigation never depends on ad availability.
    final navigation = Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => HistoryScreen(
          service: widget.historyService,
          onSelect: (item) {
            Navigator.of(context).pop();
            setState(() {
              _input = item.expression;
              _result = item.result;
              _error = null;
              _justEvaluated = true;
            });
          },
        ),
      ),
    );

    await widget.adService.showOnHistoryTransition();
    if (!mounted) return;
    await navigation;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CalculatorColors>()!;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 520;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calculate_rounded,
                        color: colors.operator,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Smart Calculator',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: widget.isDark
                            ? 'Switch to light theme'
                            : 'Switch to dark theme',
                        onPressed: () =>
                            widget.onThemeChanged(!widget.isDark),
                        icon: Icon(
                          widget.isDark
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Calculation history',
                        onPressed: _openHistory,
                        icon: const Icon(Icons.history),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: compact ? 2 : 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: CalculatorDisplay(
                      expression: _error ?? _input,
                      result: _result,
                      error: _error != null,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: CalculatorKeypad(onKey: _key),
                  ),
                ),
                const BannerAdWidget(),
              ],
            );
          },
        ),
      ),
    );
  }
}
