
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_calculator/theme/app_theme.dart';
import 'package:smart_calculator/widgets/calculator_keypad.dart';

void main() {
  testWidgets('renders all five keypad rows and sends key presses',
      (tester) async {
    final keys = <String>[];

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SizedBox(
            height: 600,
            child: CalculatorKeypad(onKey: keys.add),
          ),
        ),
      ),
    );

    expect(find.text('AC'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('='), findsOneWidget);

    await tester.tap(find.text('7'));
    await tester.pump();
    expect(keys, contains('7'));

    await tester.tap(find.text('='));
    await tester.pump();
    expect(keys, contains('='));
  });

  testWidgets('keypad renders on a narrow surface', (tester) async {
    await tester.binding.setSurfaceSize(const Size(280, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: SizedBox(
            height: 480,
            child: CalculatorKeypad(onKey: (_) {}),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('⌫'), findsOneWidget);
  });
}
