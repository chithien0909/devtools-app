import 'package:devtools_plus/tools/pdf_split_merge/pdf_split_merge_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows split and merge scaffolding', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PdfSplitMergeScreen()));
    expect(find.text('PDF Split & Merge'), findsOneWidget);
    expect(find.textContaining('Split ranges'), findsOneWidget);
    expect(find.textContaining('Merge queue'), findsOneWidget);
  });
}
