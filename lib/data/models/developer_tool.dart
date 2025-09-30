import 'package:flutter/material.dart';

import '../../services/base64_service.dart';
import '../../services/hash_service.dart';
import '../../services/json_formatter_service.dart';
import '../../services/timestamp_service.dart';
import '../../services/url_codec_service.dart';
import '../../services/uuid_service.dart';

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
    required this.operations,
  });

  final String id;
  final String title;
  final String tagline;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final List<ToolOperation> operations;
}

class DeveloperToolCatalog {
  const DeveloperToolCatalog._();

  static List<DeveloperTool> build() {
    const base64Service = Base64Service();
    const jsonFormatterService = JsonFormatterService();
    const urlCodecService = UrlCodecService();
    const hashService = HashService();
    const uuidService = UuidService();
    const timestampService = TimestampService();

    return [
      DeveloperTool(
        id: 'base64',
        title: 'Base64 Studio',
        tagline: 'Encode or decode payloads effortlessly.',
        primaryColor: const Color(0xFF6A5AE0),
        secondaryColor: const Color(0xFF9C6FE4),
        icon: Icons.layers_outlined,
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
        id: 'url',
        title: 'URL Toolkit',
        tagline: 'Encode or decode URL fragments safely.',
        primaryColor: const Color(0xFFFF8A65),
        secondaryColor: const Color(0xFFFFAB91),
        icon: Icons.link_outlined,
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
        tagline: 'Generate or scan QR codes (coming soon).',
        primaryColor: const Color(0xFF5E5CE6),
        secondaryColor: const Color(0xFF8E8DFF),
        icon: Icons.qr_code_2_outlined,
        operations: [
          ToolOperation(
            id: 'qr_generate',
            label: 'Generate QR',
            description: 'Turn text into scannable QR codes.',
            icon: Icons.qr_code,
            placeholder: 'Text to convert into QR',
            executor: (_) async => 'QR generation coming soon.',
            isImplemented: false,
          ),
          ToolOperation(
            id: 'qr_scan',
            label: 'Scan QR',
            description: 'Use device camera to scan codes.',
            icon: Icons.qr_code_scanner,
            executor: (_) async => 'QR scanning coming soon.',
            isImplemented: false,
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
        operations: [
          ToolOperation(
            id: 'diff',
            label: 'Diff Viewer',
            description:
                'Side-by-side diff with inline highlights (coming soon).',
            icon: Icons.compare,
            executor: (_) async => 'Diff viewer coming soon.',
            isImplemented: false,
          ),
        ],
      ),
    ];
  }
}
