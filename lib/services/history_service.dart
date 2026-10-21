
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/calculation_history_item.dart';

class HistoryService {
  HistoryService({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const _historyKey = 'calculation_history_v1';
  static const _themeKey = 'dark_theme_v1';
  static const int _maxHistoryItems = 300;

  final SharedPreferencesAsync _preferences;

  Future<List<CalculationHistoryItem>> loadHistory() async {
    final raw = await _preferences.getString(_historyKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      final items = <CalculationHistoryItem>[];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        try {
          items.add(
            CalculationHistoryItem.fromJson(
              Map<String, dynamic>.from(entry),
            ),
          );
        } on FormatException {
          continue;
        }
      }
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return items;
    } on FormatException {
      return [];
    }
  }

  Future<void> add(CalculationHistoryItem item) async {
    final items = await loadHistory();
    items.insert(0, item);
    final limited = items.take(_maxHistoryItems).toList();
    await _preferences.setString(
      _historyKey,
      jsonEncode(limited.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> clearHistory() =>
      _preferences.remove(_historyKey);

  Future<bool> loadDarkTheme() async =>
      await _preferences.getBool(_themeKey) ?? true;

  Future<void> saveDarkTheme(bool isDark) =>
      _preferences.setBool(_themeKey, isDark);
}
