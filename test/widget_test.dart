import 'package:devtools_plus/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts and displays dashboard', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the dashboard title is present.
    expect(find.text('Dashboard'), findsOneWidget);

    // Verify that at least one tool card is present.
    expect(find.byType(Card), findsWidgets);
  });
}