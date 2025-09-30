import 'dart:ui';

import 'package:devtools_plus/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the tool selector overview', (tester) async {
    final view = tester.view;
    view.physicalSize = const Size(1200, 2200);
    view.devicePixelRatio = 1;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const DevToolsApp());
    await tester.pumpAndSettle();

    expect(find.text('DevTools+'), findsOneWidget);
    expect(find.text('Base64 Studio'), findsWidgets);
  });
}
