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
    return Scaffold(
      appBar: AppBar(title: const Text('JWT Decoder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _jwtController,
              decoration: const InputDecoration(
                labelText: 'JWT Input',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _decode, child: const Text('Decode')),
            const SizedBox(height: 16),
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
            ),
          ],
        ),
      ),
    );
  }
}
