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
  ];

  static List<ToolDefinition> get all => 
      _definitions.where((def) => _isPlatformSupported(def)).toList();

  static bool _isPlatformSupported(ToolDefinition def) {
    return true;
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
