import 'package:devtools_plus/services/json_service.dart';
import 'package:flutter/material.dart';

class JsonFormatterScreen extends StatefulWidget {
  const JsonFormatterScreen({super.key});

  @override
  State<JsonFormatterScreen> createState() => _JsonFormatterScreenState();
}

class _JsonFormatterScreenState extends State<JsonFormatterScreen> {
  final _jsonController = TextEditingController();
  final _jsonService = JsonService();

  void _format() {
    setState(() {
      _jsonController.text = _jsonService.format(_jsonController.text);
    });
  }

  void _minify() {
    setState(() {
      _jsonController.text = _jsonService.minify(_jsonController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JSON Formatter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _jsonController,
                decoration: const InputDecoration(
                  labelText: 'JSON Input',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: _format, child: const Text('Format')),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: _minify, child: const Text('Minify')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
