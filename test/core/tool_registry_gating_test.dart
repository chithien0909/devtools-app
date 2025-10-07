import 'package:devtools_plus/core/registry/tool_registry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => TestWidgetsFlutterBinding.ensureInitialized());

  tearDown(() => debugDefaultTargetPlatformOverride = null);

  test('FFmpeg is desktop only', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    expect(
      ToolRegistry.all.where((tool) => tool.id == 'ffmpeg_transcoder'),
      isEmpty,
    );

    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    expect(
      ToolRegistry.all.where((tool) => tool.id == 'ffmpeg_transcoder'),
      isNotEmpty,
    );
  });
}
