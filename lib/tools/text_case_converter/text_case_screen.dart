import 'package:devtools_plus/services/text_case_service.dart';
import 'package:flutter/material.dart';

class TextCaseConverterScreen extends StatefulWidget {
  const TextCaseConverterScreen({super.key});

  @override
  State<TextCaseConverterScreen> createState() =>
      _TextCaseConverterScreenState();
}

class _TextCaseConverterScreenState extends State<TextCaseConverterScreen> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  final _textCaseService = TextCaseService();

  void _convertToUpperCase() {
    setState(() {
      _outputController.text = _textCaseService.toUpperCase(
        _inputController.text,
      );
    });
  }

  void _convertToLowerCase() {
    setState(() {
      _outputController.text = _textCaseService.toLowerCase(
        _inputController.text,
      );
    });
  }

  void _convertToTitleCase() {
    setState(() {
      _outputController.text = _textCaseService.toTitleCase(
        _inputController.text,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Case Converter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _inputController,
              decoration: const InputDecoration(
                labelText: 'Input',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _convertToUpperCase,
                  child: const Text('Upper Case'),
                ),
                ElevatedButton(
                  onPressed: _convertToLowerCase,
                  child: const Text('Lower Case'),
                ),
                ElevatedButton(
                  onPressed: _convertToTitleCase,
                  child: const Text('Title Case'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _outputController,
              decoration: const InputDecoration(
                labelText: 'Output',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
