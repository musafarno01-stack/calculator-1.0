
import 'package:flutter/material.dart';

import 'screens/calculator_screen.dart';
import 'services/ad_service.dart';
import 'services/history_service.dart';
import 'theme/app_theme.dart';

class SmartCalculatorApp extends StatefulWidget {
  const SmartCalculatorApp({super.key});

  @override
  State<SmartCalculatorApp> createState() => _SmartCalculatorAppState();
}

class _SmartCalculatorAppState extends State<SmartCalculatorApp> {
  final _history = HistoryService();
  final _ads = AdService();

  bool _dark = true;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _dark = await _history.loadDarkTheme();
    } catch (_) {
      _dark = true;
    }

    if (!mounted) return;
    setState(() => _ready = true);

    // A consent gate must be integrated here before production ad requests.
    // The default development configuration uses Google's test ad units.
    try {
      await _ads.initialize();
    } catch (_) {
      // Ad failures never block calculator use.
    }
  }

  Future<void> _changeTheme(bool value) async {
    setState(() => _dark = value);
    try {
      await _history.saveDarkTheme(value);
    } catch (_) {
      // Keep the current theme even if saving fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Calculator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
      home: !_ready
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : CalculatorScreen(
              historyService: _history,
              adService: _ads,
              isDark: _dark,
              onThemeChanged: _changeTheme,
            ),
    );
  }

  @override
  void dispose() {
    _ads.dispose();
    super.dispose();
  }
}
