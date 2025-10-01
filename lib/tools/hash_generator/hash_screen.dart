import 'package:devtools_plus/services/hash_service.dart';
import 'package:flutter/material.dart';

class HashGeneratorScreen extends StatefulWidget {
  const HashGeneratorScreen({super.key});

  @override
  State<HashGeneratorScreen> createState() => _HashGeneratorScreenState();
}

class _HashGeneratorScreenState extends State<HashGeneratorScreen> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  final _hashService = HashService();
  String _selectedAlgorithm = 'md5';

  void _generate() {
    setState(() {
      _outputController.text = _hashService.generate(
        _inputController.text,
        _selectedAlgorithm,
      );
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
                      'Hash Generator',
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
                    DropdownButton<String>(
                      value: _selectedAlgorithm,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedAlgorithm = newValue!;
                        });
                      },
                      items: <String>['md5', 'sha1', 'sha256']
                          .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value.toUpperCase()),
                            );
                          })
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _generate,
                      child: const Text('Generate'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _outputController,
                      decoration: const InputDecoration(
                        labelText: 'Output',
                        border: OutlineInputBorder(),
                      ),
                      readOnly: true,
                      maxLines: 2,
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
