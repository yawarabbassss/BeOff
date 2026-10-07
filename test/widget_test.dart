import 'package:beoff/presentation/widgets/custom_button.dart';
import 'package:beoff/presentation/widgets/status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CustomButton renders text and triggers callback', (WidgetTester tester) async {
    bool wasPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: 'Turn Protection On',
            onPressed: () => wasPressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Turn Protection On'), findsOneWidget);

    await tester.tap(find.text('Turn Protection On'));
    expect(wasPressed, isTrue);
  });

  testWidgets('StatusBadge renders text properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(
            text: 'DNS Filter ON',
            type: BadgeType.success,
          ),
        ),
      ),
    );

    expect(find.text('DNS Filter ON'), findsOneWidget);
  });
}
