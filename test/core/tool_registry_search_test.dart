import 'package:devtools_plus/core/registry/tool_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PDF Split & Merge is searchable', () {
    final results = ToolRegistry.search('split pdf');
    expect(results.any((tool) => tool.id == 'pdf_split_merge'), isTrue);
  });
}
