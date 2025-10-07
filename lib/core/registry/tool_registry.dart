import 'package:devtools_plus/core/registry/tool_definition.dart';
import 'package:devtools_plus/models/tool_model.dart';
import 'package:devtools_plus/tools/base64/base64_screen.dart';
import 'package:devtools_plus/tools/epoch_converter/epoch_screen.dart';
import 'package:devtools_plus/tools/hash_generator/hash_screen.dart';
import 'package:devtools_plus/tools/json_formatter/json_screen.dart';
import 'package:devtools_plus/tools/jwt_decoder/jwt_screen.dart';
import 'package:devtools_plus/tools/pdf_generator/pdf_screen.dart';
import 'package:devtools_plus/tools/qr_code/qr_screen.dart';
import 'package:devtools_plus/tools/regex_tester/regex_screen.dart';
import 'package:devtools_plus/tools/text_case_converter/text_case_screen.dart';
import 'package:devtools_plus/tools/url_encoder/url_screen.dart';
import 'package:devtools_plus/tools/uuid_generator/uuid_screen.dart';
import 'package:devtools_plus/tools/yaml_json/yaml_json_screen.dart';
import 'package:devtools_plus/tools/csv_converter/csv_screen.dart';
import 'package:devtools_plus/tools/markdown/markdown_screen.dart';
import 'package:devtools_plus/tools/hmac/hmac_screen.dart';
import 'package:devtools_plus/tools/diff/diff_screen.dart';
import 'package:devtools_plus/tools/url_builder/url_builder_screen.dart';
import 'package:devtools_plus/tools/slug/slug_screen.dart';
import 'package:devtools_plus/tools/color_tools/color_screen.dart';
import 'package:devtools_plus/tools/image_format/image_format_screen.dart';
import 'package:devtools_plus/tools/exif/exif_screen.dart';
import 'package:devtools_plus/tools/pdf_split_merge/pdf_split_merge_screen.dart';
import 'package:devtools_plus/tools/whisper/whisper_screen.dart';
import 'package:devtools_plus/screens/youtube_downloader_screen.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:hugeicons/hugeicons.dart';

class ToolRegistry {
  static final List<ToolDefinition> _definitions = [
    ToolDefinition(
      id: 'base64',
      name: 'Base64 Converter',
      description: 'Encode or decode Base64 content instantly.',
      icon: HugeIcons.strokeRoundedCodeSquare,
      category: ToolCategory.data,
      screenBuilder: () => const Base64Screen(),
      keywords: ['base64', 'encode', 'decode', 'encoding'],
    ),
    ToolDefinition(
      id: 'json_formatter',
      name: 'JSON Formatter',
      description: 'Beautify, validate, and minify JSON payloads.',
      icon: HugeIcons.strokeRoundedSourceCode,
      category: ToolCategory.data,
      screenBuilder: () => const JsonFormatterScreen(),
      keywords: ['json', 'format', 'beautify', 'minify', 'validate'],
    ),
    ToolDefinition(
      id: 'pdf_generator',
      name: 'PDF Generator',
      description: 'Transform images into polished PDF documents.',
      icon: HugeIcons.strokeRoundedPdf02,
      category: ToolCategory.file,
      screenBuilder: () => const PdfGeneratorScreen(),
      keywords: ['pdf', 'generate', 'image', 'document'],
    ),
    ToolDefinition(
      id: 'pdf_split_merge',
      name: 'PDF Split & Merge',
      description: 'Split PDFs into ranges or merge multiple documents.',
      icon: HugeIcons.strokeRoundedPdf02,
      category: ToolCategory.file,
      screenBuilder: () => const PdfSplitMergeScreen(),
      keywords: ['pdf', 'split', 'merge', 'pages', 'document'],
    ),
    ToolDefinition(
      id: 'jwt_decoder',
      name: 'JWT Decoder',
      description: 'Inspect JWT headers, payloads, and signatures.',
      icon: HugeIcons.strokeRoundedShieldKey,
      category: ToolCategory.security,
      screenBuilder: () => const JwtDecoderScreen(),
      keywords: ['jwt', 'token', 'decode', 'auth', 'security'],
    ),
    ToolDefinition(
      id: 'hash_generator',
      name: 'Hash Generator',
      description: 'Generate MD5, SHA, and custom hashes rapidly.',
      icon: HugeIcons.strokeRoundedFingerPrint,
      category: ToolCategory.security,
      screenBuilder: () => const HashGeneratorScreen(),
      keywords: ['hash', 'md5', 'sha', 'checksum', 'security'],
    ),
    ToolDefinition(
      id: 'text_case',
      name: 'Text Case Studio',
      description: 'Switch sentences between cases with smart options.',
      icon: HugeIcons.strokeRoundedTextAlignCenter,
      category: ToolCategory.utility,
      screenBuilder: () => const TextCaseConverterScreen(),
      keywords: ['text', 'case', 'uppercase', 'lowercase', 'camelcase'],
    ),
    ToolDefinition(
      id: 'qr_toolkit',
      name: 'QR Toolkit',
      description: 'Create and scan QR codes for quick sharing.',
      icon: HugeIcons.strokeRoundedQrCode,
      category: ToolCategory.utility,
      screenBuilder: () => const QrCodeScreen(),
      keywords: ['qr', 'code', 'scan', 'generate', 'barcode'],
    ),
    ToolDefinition(
      id: 'uuid_generator',
      name: 'UUID Generator',
      description: 'Generate unique identifiers (v1, v4, v7) in bulk.',
      icon: HugeIcons.strokeRoundedFingerPrintScan,
      category: ToolCategory.utility,
      screenBuilder: () => const UuidGeneratorScreen(),
      keywords: ['uuid', 'guid', 'identifier', 'unique', 'generate'],
    ),
    ToolDefinition(
      id: 'epoch_converter',
      name: 'Epoch/Time Converter',
      description: 'Convert between UNIX timestamps and ISO 8601 formats.',
      icon: HugeIcons.strokeRoundedClock01,
      category: ToolCategory.utility,
      screenBuilder: () => const EpochConverterScreen(),
      keywords: ['epoch', 'time', 'unix', 'timestamp', 'date', 'convert'],
    ),
    ToolDefinition(
      id: 'url_encoder',
      name: 'URL Encoder/Decoder',
      description: 'Encode and decode URLs, query strings, and components.',
      icon: HugeIcons.strokeRoundedLink01,
      category: ToolCategory.data,
      screenBuilder: () => const UrlEncoderScreen(),
      keywords: ['url', 'encode', 'decode', 'query', 'string', 'uri'],
    ),
    ToolDefinition(
      id: 'regex_tester',
      name: 'Regex Tester',
      description: 'Test regular expressions with live matches and groups.',
      icon: HugeIcons.strokeRoundedSearch01,
      category: ToolCategory.utility,
      screenBuilder: () => const RegexTesterScreen(),
      keywords: ['regex', 'regexp', 'pattern', 'match', 'test', 'search'],
    ),
    ToolDefinition(
      id: 'yaml_json',
      name: 'YAML ⇄ JSON',
      description: 'Convert YAML and JSON with validation.',
      icon: HugeIcons.strokeRoundedSourceCode,
      category: ToolCategory.data,
      screenBuilder: () => const YamlJsonScreen(),
      keywords: ['yaml', 'json', 'convert', 'format', 'serialize'],
    ),
    ToolDefinition(
      id: 'csv_converter',
      name: 'CSV ⇄ JSON / TSV',
      description: 'Convert CSV/TSV and JSON with headers handling.',
      icon: HugeIcons.strokeRoundedTable02,
      category: ToolCategory.data,
      screenBuilder: () => const CsvConverterScreen(),
      keywords: ['csv', 'tsv', 'json', 'delimiter', 'convert'],
    ),
    ToolDefinition(
      id: 'markdown',
      name: 'Markdown Previewer',
      description: 'Live Markdown preview and export to PDF.',
      icon: HugeIcons.strokeRoundedBookOpen01,
      category: ToolCategory.utility,
      screenBuilder: () => const MarkdownScreen(),
      keywords: ['markdown', 'md', 'preview', 'pdf', 'export'],
    ),
    ToolDefinition(
      id: 'hmac',
      name: 'HMAC Generator',
      description: 'Generate HMAC signatures (SHA-1/256/512).',
      icon: HugeIcons.strokeRoundedShield02,
      category: ToolCategory.security,
      screenBuilder: () => const HmacScreen(),
      keywords: ['hmac', 'signature', 'sha256', 'sha512', 'sha1', 'security'],
    ),
    ToolDefinition(
      id: 'diff',
      name: 'Text Diff',
      description: 'Side-by-side text diff with highlights.',
      icon: HugeIcons.strokeRoundedSearch01,
      category: ToolCategory.utility,
      screenBuilder: () => const DiffScreen(),
      keywords: ['diff', 'compare', 'text', 'json'],
    ),
    ToolDefinition(
      id: 'url_builder',
      name: 'URL Builder',
      description: 'Parse and build URLs, query params, fragments.',
      icon: HugeIcons.strokeRoundedLink02,
      category: ToolCategory.utility,
      screenBuilder: () => const UrlBuilderScreen(),
      keywords: ['url', 'uri', 'query', 'builder', 'parser'],
    ),
    ToolDefinition(
      id: 'slug',
      name: 'Slugifier',
      description: 'Create URL-safe slugs; normalize whitespace.',
      icon: HugeIcons.strokeRoundedTextSquare,
      category: ToolCategory.utility,
      screenBuilder: () => const SlugScreen(),
      keywords: ['slug', 'normalize', 'text'],
    ),
    ToolDefinition(
      id: 'color_tools',
      name: 'Color Tools',
      description: 'HEX/RGB/HSL convert; palette from image.',
      icon: HugeIcons.strokeRoundedPenTool01,
      category: ToolCategory.design,
      screenBuilder: () => const ColorToolsScreen(),
      keywords: ['color', 'hex', 'rgb', 'hsl', 'palette', 'image'],
    ),
    ToolDefinition(
      id: 'image_format',
      name: 'Image Format Converter',
      description: 'Convert images PNG ⇄ JPG ⇄ WebP with quality.',
      icon: HugeIcons.strokeRoundedImage01,
      category: ToolCategory.file,
      screenBuilder: () => const ImageFormatScreen(),
      keywords: ['image', 'png', 'jpg', 'webp', 'convert'],
    ),
    ToolDefinition(
      id: 'exif_viewer',
      name: 'EXIF Viewer',
      description: 'Inspect and strip EXIF metadata from images.',
      icon: HugeIcons.strokeRoundedImage01,
      category: ToolCategory.file,
      screenBuilder: () => const ExifScreen(),
      keywords: ['exif', 'metadata', 'image', 'privacy'],
    ),
    ToolDefinition(
      id: 'whisper_transcription',
      name: 'Video Transcription',
      description: 'Transcribe videos using OpenAI Whisper (local model).',
      icon: HugeIcons.strokeRoundedVideo01,
      category: ToolCategory.file,
      screenBuilder: () => const WhisperScreen(),
      keywords: ['whisper', 'transcription', 'video', 'audio', 'speech', 'ai'],
    ),
    ToolDefinition(
      id: 'youtube_downloader',
      name: 'YouTube Downloader',
      description: 'Download YouTube videos and audio with yt-dlp integration.',
      icon: HugeIcons.strokeRoundedVideo01,
      category: ToolCategory.utility,
      screenBuilder: () => const YouTubeDownloaderScreen(),
      keywords: ['youtube', 'download', 'video', 'audio', 'mp4', 'mp3', 'yt-dlp'],
    ),
  ];

  static const Set<TargetPlatform> _desktopPlatforms = {
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  };

  static final Map<String, Set<TargetPlatform>> _toolPlatformAllowList = {
    'ffmpeg_transcoder': _desktopPlatforms,
    'pdf_split_merge': _desktopPlatforms,
    'image_format': {TargetPlatform.macOS, TargetPlatform.linux},
    'exif_viewer': _desktopPlatforms,
    'whisper_transcription': _desktopPlatforms,
    'youtube_downloader': _desktopPlatforms,
  };

  static const Set<String> _webExcludedTools = {
    'ffmpeg_transcoder',
    'pdf_split_merge',
    'image_format',
    'exif_viewer',
    'whisper_transcription',
  };

  static const Set<String> _temporarilyDisabledTools = {
    'whisper_transcription', // Temporarily disabled due to layout issues
  };

  static List<ToolDefinition> get all =>
      _definitions.where((def) => _isPlatformSupported(def) && !_temporarilyDisabledTools.contains(def.id)).toList();

  static bool _isPlatformSupported(ToolDefinition def) {
    if (kIsWeb && _webExcludedTools.contains(def.id)) {
      return false;
    }
    final allowList = _toolPlatformAllowList[def.id];
    if (allowList == null) {
      return true;
    }
    return allowList.contains(defaultTargetPlatform);
  }

  static ToolDefinition? findById(String id) {
    try {
      return all.firstWhere((def) => def.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<ToolDefinition> search(String query) {
    if (query.isEmpty) return all;
    return all.where((def) => def.matchesQuery(query)).toList();
  }

  static List<ToolDefinition> filterByCategory(ToolCategory category) {
    return all.where((def) => def.category == category).toList();
  }

  static List<ToolModel> allAsModels() {
    return all.map((def) => def.toToolModel()).toList();
  }
}
