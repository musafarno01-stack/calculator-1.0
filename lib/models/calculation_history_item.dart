
class CalculationHistoryItem {
  const CalculationHistoryItem({
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  final String expression;
  final String result;
  final DateTime timestamp;

  Map<String, Object?> toJson() => {
        'expression': expression,
        'result': result,
        'timestamp': timestamp.toIso8601String(),
      };

  factory CalculationHistoryItem.fromJson(Map<String, dynamic> json) {
    final expression = json['expression'];
    final result = json['result'];
    final timestamp = DateTime.tryParse(
      json['timestamp']?.toString() ?? '',
    );

    if (expression is! String ||
        result is! String ||
        timestamp == null) {
      throw const FormatException('Invalid history item.');
    }

    return CalculationHistoryItem(
      expression: expression,
      result: result,
      timestamp: timestamp,
    );
  }
}
