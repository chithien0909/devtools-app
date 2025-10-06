import 'dart:io' show Platform;

import 'package:devtools_plus/models/tool_model.dart';
import 'package:devtools_plus/tools/base64/base64_screen.dart';
import 'package:devtools_plus/tools/epoch_converter/epoch_screen.dart';
import 'package:devtools_plus/tools/hash_generator/hash_screen.dart';
import 'package:devtools_plus/tools/image_compressor/compressor_screen.dart';
import 'package:devtools_plus/tools/json_formatter/json_screen.dart';
import 'package:devtools_plus/tools/jwt_decoder/jwt_screen.dart';
import 'package:devtools_plus/tools/pdf_generator/pdf_screen.dart';
import 'package:devtools_plus/tools/qr_code/qr_screen.dart';
import 'package:devtools_plus/tools/regex_tester/regex_screen.dart';
import 'package:devtools_plus/tools/text_case_converter/text_case_screen.dart';
import 'package:devtools_plus/tools/url_encoder/url_screen.dart';
import 'package:devtools_plus/tools/uuid_generator/uuid_screen.dart';
import 'package:hugeicons/hugeicons.dart';

final List<ToolModel> tools = [
  const ToolModel(
    id: 'base64',
    name: 'Base64 Converter',
    description: 'Encode or decode Base64 content instantly.',
    icon: HugeIcons.strokeRoundedCodeSquare,
    category: ToolCategory.data,
    screen: Base64Screen(),
  ),
  const ToolModel(
    id: 'json_formatter',
    name: 'JSON Formatter',
    description: 'Beautify, validate, and minify JSON payloads.',
    icon: HugeIcons.strokeRoundedSourceCode,
    category: ToolCategory.data,
    screen: JsonFormatterScreen(),
  ),
  const ToolModel(
    id: 'pdf_generator',
    name: 'PDF Generator',
    description: 'Transform images into polished PDF documents.',
    icon: HugeIcons.strokeRoundedPdf02,
    category: ToolCategory.file,
    screen: PdfGeneratorScreen(),
  ),
  if (!Platform.isWindows)
    const ToolModel(
      id: 'image_compressor',
      name: 'Image Compressor',
      description: 'Shrink image size without sacrificing quality.',
      icon: HugeIcons.strokeRoundedImageComposition,
      category: ToolCategory.file,
      screen: ImageCompressorScreen(),
    ),
  const ToolModel(
    id: 'jwt_decoder',
    name: 'JWT Decoder',
    description: 'Inspect JWT headers, payloads, and signatures.',
    icon: HugeIcons.strokeRoundedShieldKey,
    category: ToolCategory.security,
    screen: JwtDecoderScreen(),
  ),
  const ToolModel(
    id: 'hash_generator',
    name: 'Hash Generator',
    description: 'Generate MD5, SHA, and custom hashes rapidly.',
    icon: HugeIcons.strokeRoundedFingerPrint,
    category: ToolCategory.security,
    screen: HashGeneratorScreen(),
  ),
  const ToolModel(
    id: 'text_case',
    name: 'Text Case Studio',
    description: 'Switch sentences between cases with smart options.',
    icon: HugeIcons.strokeRoundedTextAlignCenter,
    category: ToolCategory.utility,
    screen: TextCaseConverterScreen(),
  ),
  const ToolModel(
    id: 'qr_toolkit',
    name: 'QR Toolkit',
    description: 'Create and scan QR codes for quick sharing.',
    icon: HugeIcons.strokeRoundedQrCode,
    category: ToolCategory.utility,
    screen: QrCodeScreen(),
  ),
  const ToolModel(
    id: 'uuid_generator',
    name: 'UUID Generator',
    description: 'Generate unique identifiers (v1, v4, v7) in bulk.',
    icon: HugeIcons.strokeRoundedFingerPrintScan,
    category: ToolCategory.utility,
    screen: UuidGeneratorScreen(),
  ),
  const ToolModel(
    id: 'epoch_converter',
    name: 'Epoch/Time Converter',
    description: 'Convert between UNIX timestamps and ISO 8601 formats.',
    icon: HugeIcons.strokeRoundedClock01,
    category: ToolCategory.utility,
    screen: EpochConverterScreen(),
  ),
  const ToolModel(
    id: 'url_encoder',
    name: 'URL Encoder/Decoder',
    description: 'Encode and decode URLs, query strings, and components.',
    icon: HugeIcons.strokeRoundedLink01,
    category: ToolCategory.data,
    screen: UrlEncoderScreen(),
  ),
  const ToolModel(
    id: 'regex_tester',
    name: 'Regex Tester',
    description: 'Test regular expressions with live matches and groups.',
    icon: HugeIcons.strokeRoundedSearch01,
    category: ToolCategory.utility,
    screen: RegexTesterScreen(),
  ),
];
