import 'package:devtools_plus/services/jwt_service.dart';
import 'package:flutter/material.dart';

class JwtDecoderScreen extends StatefulWidget {
  const JwtDecoderScreen({super.key});

  @override
  State<JwtDecoderScreen> createState() => _JwtDecoderScreenState();
}

class _JwtDecoderScreenState extends State<JwtDecoderScreen> {
  final _jwtController = TextEditingController();
  final _outputController = TextEditingController();
  final _jwtService = JwtService();

  void _decode() {
    setState(() {
      _outputController.text = _jwtService.decode(_jwtController.text);
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
                      'JWT Decoder',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _jwtController,
                      decoration: const InputDecoration(
                        labelText: 'JWT Input',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _decode,
                      child: const Text('Decode'),
                    ),
                    const SizedBox(height: 16),
                    if (hasFiniteH)
                      Expanded(
                        child: TextField(
                          controller: _outputController,
                          decoration: const InputDecoration(
                            labelText: 'Decoded',
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
                          labelText: 'Decoded',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        maxLines: 10,
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
