import 'package:devtools_plus/tools/base64/base64_service.dart';
import 'package:flutter/material.dart';

class Base64Screen extends StatefulWidget {
  const Base64Screen({super.key});

  @override
  State<Base64Screen> createState() => _Base64ScreenState();
}

class _Base64ScreenState extends State<Base64Screen> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  final _base64service = Base64Service();

  void _encode() {
    setState(() {
      _outputController.text = _base64service.encode(_inputController.text);
    });
  }

  void _decode() {
    setState(() {
      try {
        _outputController.text = _base64service.decode(_inputController.text);
      } catch (e) {
        _outputController.text = 'Invalid Base64 string';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasFiniteW = constraints.hasBoundedWidth;
        final hasFiniteH = constraints.hasBoundedHeight;
        return Material(
          color: Theme.of(context).colorScheme.surface,
          child: SizedBox(
            width: hasFiniteW ? constraints.maxWidth : null,
            height: hasFiniteH ? constraints.maxHeight : null,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Base64 Encoder/Decoder',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _inputController,
                      decoration: const InputDecoration(
                        labelText: 'Input',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _encode,
                          child: const Text('Encode'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _decode,
                          child: const Text('Decode'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (hasFiniteH)
                      Expanded(
                        child: TextField(
                          controller: _outputController,
                          decoration: const InputDecoration(
                            labelText: 'Output',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          maxLines: null,
                          expands: true,
                        ),
                      )
                    else
                      TextField(
                        controller: _outputController,
                        decoration: const InputDecoration(
                          labelText: 'Output',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        maxLines: 8,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
