import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';

import '../../services/base64_service.dart';
import '../../services/hash_service.dart';
import '../../services/json_formatter_service.dart';
import '../../services/log_parser_service.dart';
import '../../services/timestamp_service.dart';
import '../../services/url_codec_service.dart';
import '../../services/uuid_service.dart';
import '../../services/aes_service.dart';
import '../../services/rsa_service.dart';
import '../../services/api_tester_service.dart';
import '../../services/qr_code_service.dart';
import '../../services/diff_service.dart';
import '../../services/data_tools_service.dart';

typedef ToolExecutor = Future<String> Function(String input);

class ToolOperation {
  ToolOperation({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.executor,
    this.placeholder,
    this.isImplemented = true,
  });

  final String id;
  final String label;
  final String description;
  final IconData icon;
  final ToolExecutor executor;
  final String? placeholder;
  final bool isImplemented;
}

class DeveloperTool {
  DeveloperTool({
    required this.id,
    required this.title,
    required this.tagline,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    required this.category,
    required this.operations,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String tagline;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final String category;
  final List<ToolOperation> operations;
  bool isFavorite;
}

class DeveloperToolCatalog {
  const DeveloperToolCatalog._();

  static List<DeveloperTool> build() {
    const base64Service = Base64Service();
    const jsonFormatterService = JsonFormatterService();
    const urlCodecService = UrlCodecService();
    const hashService = HashService();
    const logParserService = LogParserService();
    const uuidService = UuidService();
    const timestampService = TimestampService();
    const aesService = AesService();
    const rsaService = RsaService();
    const qrCodeService = QrCodeService();
    const diffService = DiffService();
    const dataToolsService = DataToolsService();

    return [
      DeveloperTool(
        id: 'security_tools',
        title: 'Security / Dev Tools',
        tagline: 'JWT, passwords, crypto and API testing.',
        primaryColor: const Color(0xFF0EA5E9),
        secondaryColor: const Color(0xFF6366F1),
        icon: Icons.security,
        category: 'Security',
        operations: [
          ToolOperation(
            id: 'jwt_decode',
            label: 'JWT Decoder',
            description: 'Decode header and payload of a JWT.',
            icon: Icons.vpn_key_outlined,
            placeholder: 'Paste a JWT (header.payload.signature)',
            executor: (input) async {
              final token = input.trim();
              if (token.isEmpty) {
                throw const FormatException('Provide a JWT');
              }
              final parts = token.split('.');
              if (parts.length < 2) {
                throw const FormatException('Invalid JWT format');
              }
              String decodePart(String s) {
                String normalized = s.replaceAll('-', '+').replaceAll('_', '/');
                while (normalized.length % 4 != 0) {
                  normalized += '=';
                }
                final bytes = base64.decode(normalized);
                return utf8.decode(bytes);
              }

              final header = decodePart(parts[0]);
              final payload = decodePart(parts[1]);
              final signature = parts.length > 2 ? parts[2] : '';
              return 'Header:\n$header\n\nPayload:\n$payload\n\nSignature:\n$signature';
            },
          ),
          ToolOperation(
            id: 'password_generate',
            label: 'Password Generator',
            description: 'Generate secure random passwords.',
            icon: Icons.password_outlined,
            placeholder: '{"length":16,"symbols":true,"numbers":true}',
            executor: (input) async {
              int length = 16;
              bool includeSymbols = true;
              bool includeNumbers = true;
              try {
                if (input.trim().isNotEmpty) {
                  final cfg = json.decode(input) as Map<String, dynamic>;
                  length = (cfg['length'] as num?)?.toInt() ?? length;
                  includeSymbols = (cfg['symbols'] as bool?) ?? includeSymbols;
                  includeNumbers = (cfg['numbers'] as bool?) ?? includeNumbers;
                }
              } catch (_) {}
              const lettersLower = 'abcdefghijklmnopqrstuvwxyz';
              const lettersUpper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
              const digits = '0123456789';
              const symbols = '!@#\$%^&*()_-+=[]{};:,.<>?/';
              String pool = lettersLower + lettersUpper;
              if (includeNumbers) pool += digits;
              if (includeSymbols) pool += symbols;
              if (length < 8) {
                length = 8;
              }
              final rand = Random.secure();
              final chars = List.generate(
                length,
                (_) => pool[rand.nextInt(pool.length)],
              );
              return chars.join();
            },
          ),
          ToolOperation(
            id: 'aes_encrypt',
            label: 'AES Encrypt',
            description: 'Encrypt text with a key.',
            icon: Icons.lock_outline,
            placeholder:
                'Enter text to encrypt and a key like so: {"text": "your text", "key": "your key"}',
            executor: (input) async {
              try {
                final data = json.decode(input) as Map<String, dynamic>;
                final text = data['text'] as String;
                final key = data['key'] as String;
                return await aesService.encrypt(text, key);
              } catch (e) {
                throw const FormatException(
                  'Invalid input. Expected JSON like: {"text": "your text", "key": "your key"}',
                );
              }
            },
            isImplemented: true,
          ),
          ToolOperation(
            id: 'aes_decrypt',
            label: 'AES Decrypt',
            description: 'Decrypt text with a key.',
            icon: Icons.lock_open_outlined,
            placeholder:
                'Enter text to decrypt and a key like so: {"text": "your text", "key": "your key"}',
            executor: (input) async {
              try {
                final data = json.decode(input) as Map<String, dynamic>;
                final text = data['text'] as String;
                final key = data['key'] as String;
                return await aesService.decrypt(text, key);
              } catch (e) {
                throw const FormatException(
                  'Invalid input. Expected JSON like: {"text": "your text", "key": "your key"}',
                );
              }
            },
            isImplemented: true,
          ),
          ToolOperation(
            id: 'rsa_encrypt',
            label: 'RSA Encrypt',
            description: 'Encrypt text with a public key.',
            icon: Icons.enhanced_encryption_outlined,
            placeholder:
                'Enter text to encrypt and a public key like so: {"text": "your text", "key": "your public key"}',
            executor: (input) async {
              try {
                final data = json.decode(input) as Map<String, dynamic>;
                final text = data['text'] as String;
                final key = data['key'] as String;
                return await rsaService.encrypt(text, key);
              } catch (e) {
                throw const FormatException(
                  'Invalid input. Expected JSON like: {"text": "your text", "key": "your public key"}',
                );
              }
            },
            isImplemented: true,
          ),
          ToolOperation(
            id: 'rsa_decrypt',
            label: 'RSA Decrypt',
            description: 'Decrypt text with a private key.',
            icon: Icons.enhanced_encryption_outlined,
            placeholder:
                'Enter text to decrypt and a private key like so: {"text": "your text", "key": "your private key"}',
            executor: (input) async {
              try {
                final data = json.decode(input) as Map<String, dynamic>;
                final text = data['text'] as String;
                final key = data['key'] as String;
                return await rsaService.decrypt(text, key);
              } catch (e) {
                throw const FormatException(
                  'Invalid input. Expected JSON like: {"text": "your text", "key": "your private key"}',
                );
              }
            },
            isImplemented: true,
          ),
          ToolOperation(
            id: 'api_tester',
            label: 'API Tester',
            description:
                'Compose requests, inspect responses, and copy results instantly.',
            icon: Icons.http_outlined,
            placeholder:
                'Use the API tester workspace below to craft your HTTP request.',
            executor: (input) async => const ApiTesterService().get(input),
            isImplemented: true,
          ),
        ],
      ),
      DeveloperTool(
        id: 'base64',
        title: 'Base64 Studio',
        tagline: 'Encode or decode payloads effortlessly.',
        primaryColor: const Color(0xFF6A5AE0),
        secondaryColor: const Color(0xFF9C6FE4),
        icon: Icons.layers_outlined,
        category: 'Encoding',
        operations: [
          ToolOperation(
            id: 'encode',
            label: 'Encode',
            description: 'Convert raw text to Base64 strings.',
            icon: Icons.lock_outline,
            placeholder: 'Enter text to encode',
            executor: base64Service.encode,
          ),
          ToolOperation(
            id: 'decode',
            label: 'Decode',
            description: 'Recover text from Base64 input.',
            icon: Icons.lock_open_outlined,
            placeholder: 'Paste Base64 data',
            executor: base64Service.decode,
          ),
        ],
      ),
      DeveloperTool(
        id: 'json',
        title: 'JSON Lab',
        tagline: 'Beautify or compress JSON payloads.',
        primaryColor: const Color(0xFF13C2C2),
        secondaryColor: const Color(0xFF52E5E5),
        icon: Icons.data_object,
        category: 'Data',
        operations: [
          ToolOperation(
            id: 'prettify',
            label: 'Prettify',
            description: 'Indent JSON for readability.',
            icon: Icons.auto_fix_high_outlined,
            placeholder: 'Paste JSON to pretty print',
            executor: jsonFormatterService.prettify,
          ),
          ToolOperation(
            id: 'minify',
            label: 'Minify',
            description: 'Strip whitespace without affecting structure.',
            icon: Icons.vertical_align_center,
            placeholder: 'Paste JSON to minify',
            executor: jsonFormatterService.minify,
          ),
        ],
      ),
      DeveloperTool(
        id: 'log',
        title: 'Log Inspector',
        tagline: 'Parse structured JSON log entries into readable text.',
        primaryColor: const Color(0xFF8E8DFF),
        secondaryColor: const Color(0xFFB3B2FF),
        icon: Icons.receipt_long_outlined,
        category: 'Monitoring',
        operations: [
          ToolOperation(
            id: 'parse',
            label: 'Parse Log',
            description: 'Extract fields from structured log JSON.',
            icon: Icons.article_outlined,
            placeholder: 'Paste one JSON log line',
            executor: logParserService.parse,
          ),
        ],
      ),
      DeveloperTool(
        id: 'url',
        title: 'URL Toolkit',
        tagline: 'Encode or decode URL fragments safely.',
        primaryColor: const Color(0xFFFF8A65),
        secondaryColor: const Color(0xFFFFAB91),
        icon: Icons.link_outlined,
        category: 'Web',
        operations: [
          ToolOperation(
            id: 'encode',
            label: 'Encode',
            description: 'Escape reserved characters.',
            icon: Icons.link,
            placeholder: 'Paste a string to URL encode',
            executor: urlCodecService.encode,
          ),
          ToolOperation(
            id: 'decode',
            label: 'Decode',
            description: 'Decode percent-encoded strings.',
            icon: Icons.link_off_outlined,
            placeholder: 'Paste a URL-encoded string',
            executor: urlCodecService.decode,
          ),
        ],
      ),
      DeveloperTool(
        id: 'hash',
        title: 'Hash Forge',
        tagline: 'Generate MD5, SHA1, or SHA256 digests.',
        primaryColor: const Color(0xFF4CB782),
        secondaryColor: const Color(0xFF7EE2A9),
        icon: Icons.shield_outlined,
        category: 'Security',
        operations: [
          ToolOperation(
            id: 'md5',
            label: 'MD5',
            description: 'Fast 128-bit hash.',
            icon: Icons.shield,
            placeholder: 'Enter text to hash',
            executor: hashService.md5Hash,
          ),
          ToolOperation(
            id: 'sha1',
            label: 'SHA1',
            description: '160-bit secure hash.',
            icon: Icons.security_outlined,
            placeholder: 'Enter text to hash',
            executor: hashService.sha1Hash,
          ),
          ToolOperation(
            id: 'sha256',
            label: 'SHA256',
            description: '256-bit secure hash.',
            icon: Icons.health_and_safety_outlined,
            placeholder: 'Enter text to hash',
            executor: hashService.sha256Hash,
          ),
        ],
      ),
      DeveloperTool(
        id: 'uuid',
        title: 'UUID Generator',
        tagline: 'Produce unique identifiers instantly.',
        primaryColor: const Color(0xFF6DB6FF),
        secondaryColor: const Color(0xFF99D4FF),
        icon: Icons.confirmation_num_outlined,
        category: 'Identifiers',
        operations: [
          ToolOperation(
            id: 'v4',
            label: 'Version 4',
            description: 'Random UUID v4.',
            icon: Icons.casino_outlined,
            placeholder: 'Input optional entropy seed',
            executor: uuidService.generateV4,
          ),
          ToolOperation(
            id: 'v5',
            label: 'Version 5',
            description: 'Name-based UUID using URL namespace.',
            icon: Icons.public,
            placeholder: 'Enter a URL or name for v5 seed',
            executor: uuidService.generateV5,
          ),
        ],
      ),
      DeveloperTool(
        id: 'time',
        title: 'Time Converter',
        tagline: 'Move between timestamps and human dates.',
        primaryColor: const Color(0xFFF7B500),
        secondaryColor: const Color(0xFFFFD25F),
        icon: Icons.schedule_outlined,
        category: 'Utilities',
        operations: [
          ToolOperation(
            id: 'ts_to_date',
            label: 'Timestamp → Date',
            description: 'Convert Unix timestamp (ms) to readable time.',
            icon: Icons.timelapse_outlined,
            placeholder: '1696016132000',
            executor: timestampService.timestampToDate,
          ),
          ToolOperation(
            id: 'date_to_ts',
            label: 'Date → Timestamp',
            description: 'Convert yyyy-MM-dd HH:mm:ss to Unix timestamp.',
            icon: Icons.event_outlined,
            placeholder: '2025-09-30 18:04:00',
            executor: timestampService.dateToTimestamp,
          ),
        ],
      ),
      DeveloperTool(
        id: 'qr',
        title: 'QR Studio',
        tagline: 'Generate or scan QR codes.',
        primaryColor: const Color(0xFF5E5CE6),
        secondaryColor: const Color(0xFF8E8DFF),
        icon: Icons.qr_code_2_outlined,
        category: 'Communication',
        operations: [
          ToolOperation(
            id: 'qr_generate',
            label: 'Generate QR',
            description: 'Turn text into scannable QR codes.',
            icon: Icons.qr_code,
            placeholder: 'Text to convert into QR',
            executor: qrCodeService.generate,
            isImplemented: true,
          ),
          ToolOperation(
            id: 'qr_scan',
            label: 'Scan QR',
            description: 'Use device camera to scan codes.',
            icon: Icons.qr_code_scanner,
            placeholder:
                'Use the live camera panel below to capture QR codes instantly.',
            executor: (_) async =>
                'Open the scanner below to capture QR codes in real time.',
            isImplemented: true,
          ),
        ],
      ),
      DeveloperTool(
        id: 'diff',
        title: 'Text Diff',
        tagline: 'Compare two blocks and highlight changes.',
        primaryColor: const Color(0xFFEE6352),
        secondaryColor: const Color(0xFFFFA38F),
        icon: Icons.compare_arrows_outlined,
        category: 'Text Tools',
        operations: [
          ToolOperation(
            id: 'diff',
            label: 'Diff Viewer',
            description: 'Side-by-side diff with inline highlights.',
            icon: Icons.compare,
            placeholder:
                'Enter two texts to compare, like so: {"text1": "your text1", "text2": "your text2"}',
            executor: (input) async {
              try {
                final data = json.decode(input) as Map<String, dynamic>;
                final text1 = data['text1'] as String;
                final text2 = data['text2'] as String;
                return await diffService.diff(text1, text2);
              } catch (e) {
                throw const FormatException(
                  'Invalid input. Expected JSON like: {"text1": "your text1", "text2": "your text2"}',
                );
              }
            },
            isImplemented: true,
          ),
        ],
      ),
      DeveloperTool(
        id: 'image_pdf',
        title: 'Images → PDF',
        tagline: 'Compile photos into polished PDF documents.',
        primaryColor: const Color(0xFF0F9D91),
        secondaryColor: const Color(0xFF3BC9DB),
        icon: Icons.picture_as_pdf_outlined,
        category: 'File',
        operations: [
          ToolOperation(
            id: 'image_to_pdf',
            label: 'Image to PDF Generator',
            description: 'Arrange images, tweak layout, and export a PDF.',
            icon: Icons.upload_file,
            placeholder:
                'Use the dedicated workspace below to select images and configure PDF options.',
            executor: (input) async =>
                'Use the Image → PDF workspace to configure options and export.',
            isImplemented: true,
          ),
        ],
      ),
      DeveloperTool(
        id: 'image_compress',
        title: 'Image Compressor',
        tagline: 'Batch compress, resize, and convert formats in seconds.',
        primaryColor: const Color(0xFF1565C0),
        secondaryColor: const Color(0xFF64B5F6),
        icon: Icons.image_outlined,
        category: 'File',
        operations: [
          ToolOperation(
            id: 'image_compressor',
            label: 'Image Compressor & Converter',
            description: 'Adjust quality, resize, convert formats, and export in bulk.',
            icon: Icons.compress_outlined,
            placeholder:
                'Use the image compressor workspace to pick photos, tweak quality, and export.',
            executor: (input) async =>
                'Configure options in the Image Compressor workspace, then export your bundle.',
            isImplemented: true,
          ),
        ],
      ),
      DeveloperTool(
        id: 'data_string',
        title: 'Data & String Tools',
        tagline: 'Convert between CSV, JSON, YAML and polish strings fast.',
        primaryColor: const Color(0xFF8E24AA),
        secondaryColor: const Color(0xFFD05CE3),
        icon: Icons.dataset_outlined,
        category: 'Data',
        operations: [
          ToolOperation(
            id: 'csv_to_json',
            label: 'CSV → JSON',
            description: 'Turn comma-separated values into structured JSON.',
            icon: Icons.grid_on_outlined,
            placeholder: 'Paste CSV and hit run to see JSON output.',
            executor: (input) async => await dataToolsService.csvToJson(input),
          ),
          ToolOperation(
            id: 'json_to_csv',
            label: 'JSON → CSV',
            description: 'Flatten JSON arrays into CSV rows.',
            icon: Icons.table_rows_outlined,
            placeholder: '[\n  {"name":"Ada","role":"Engineer"}\n]',
            executor: (input) async => await dataToolsService.jsonToCsv(input),
          ),
          ToolOperation(
            id: 'yaml_json',
            label: 'YAML ↔ JSON',
            description: 'Toggle between YAML and JSON formats instantly.',
            icon: Icons.swap_horiz_outlined,
            placeholder: 'Mode auto-detected from the left panel.',
            executor: (input) async => 'Use the dedicated workspace panel to convert.',
            isImplemented: true,
          ),
          ToolOperation(
            id: 'text_case',
            label: 'Text Case Converter',
            description: 'Switch casing (camel, snake, pascal, title, etc.).',
            icon: Icons.text_fields_outlined,
            placeholder: 'Type text and choose a target case.',
            executor: (input) async => 'Use the text case panel below.',
            isImplemented: true,
          ),
          ToolOperation(
            id: 'text_counter',
            label: 'Text Counter',
            description: 'Count words, lines, characters, and byte size.',
            icon: Icons.countertops_outlined,
            placeholder: 'Paste text to see counts instantly.',
            executor: (input) async => 'Stats appear in the workspace sidebar.',
            isImplemented: true,
          ),
          ToolOperation(
            id: 'regex_tester',
            label: 'Regex Tester',
            description: 'Test expressions with live highlighting.',
            icon: Icons.find_in_page_outlined,
            placeholder: 'Type regex and test text in dedicated panel.',
            executor: (input) async => 'Use the regex tester panel below.',
            isImplemented: true,
          ),
        ],
      ),
    ];
  }
}
