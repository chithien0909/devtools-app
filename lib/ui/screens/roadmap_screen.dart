import 'package:flutter/material.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  static const _futureFeatures = [
    (
      'Encryption Lab',
      'AES and RSA utilities for encrypting, decrypting, and sharing secure payloads.',
    ),
    (
      'Regex Studio',
      'Interactive tester with highlighting and quick pattern presets.',
    ),
    (
      'Case Converter',
      'Switch between snake_case, camelCase, PascalCase, and more in one tap.',
    ),
    (
      'Color Inspector',
      'Bidirectional conversion between HEX, RGB, and HSL along with palette export.',
    ),
    (
      'Image ↔ Base64',
      'Convert assets to Base64 strings and reconstruct image previews instantly.',
    ),
    (
      'Markdown Studio',
      'Live preview with themeable styling and export helpers.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DevTools+ Roadmap')),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _futureFeatures.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final (title, description) = _futureFeatures[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.upcoming_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
