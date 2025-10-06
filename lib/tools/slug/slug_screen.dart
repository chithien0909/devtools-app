import 'package:devtools_plus/services/slug_service.dart';
import 'package:flutter/material.dart';

class SlugScreen extends StatefulWidget {
  const SlugScreen({super.key});

  @override
  State<SlugScreen> createState() => _SlugScreenState();
}

class _SlugScreenState extends State<SlugScreen> {
  final SlugService _service = const SlugService();
  final _input = TextEditingController();
  String _slug = '';
  String _normalized = '';

  void _run() {
    setState(() {
      _slug = _service.slugify(_input.text);
      _normalized = _service.normalizeWhitespace(_input.text);
    });
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slugifier / Normalizer'),
        actions: [IconButton(onPressed: _run, icon: const Icon(Icons.play_arrow))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _input,
              decoration: const InputDecoration(labelText: 'Input', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            SelectableText('Slug: ' + _slug, style: const TextStyle(fontFamily: 'monospace')),
            const SizedBox(height: 8),
            SelectableText('Normalized: ' + _normalized),
          ],
        ),
      ),
    );
  }
}
