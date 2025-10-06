import 'package:devtools_plus/services/hmac_service.dart';
import 'package:flutter/material.dart';

class HmacScreen extends StatefulWidget {
  const HmacScreen({super.key});

  @override
  State<HmacScreen> createState() => _HmacScreenState();
}

class _HmacScreenState extends State<HmacScreen> {
  final HmacService _service = const HmacService();

  final TextEditingController _message = TextEditingController();
  final TextEditingController _secret = TextEditingController();
  final TextEditingController _output = TextEditingController();

  String _algorithm = 'sha256';
  String _encoding = 'hex';

  @override
  void dispose() {
    _message.dispose();
    _secret.dispose();
    _output.dispose();
    super.dispose();
  }

  void _generate() {
    try {
      final sig = _service.generate(
        message: _message.text,
        secret: _secret.text,
        algorithm: _algorithm,
        output: _encoding,
      );
      setState(() => _output.text = sig);
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HMAC Generator'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _algorithm,
              items: const [
                DropdownMenuItem(value: 'sha1', child: Text('SHA-1')),
                DropdownMenuItem(value: 'sha256', child: Text('SHA-256')),
                DropdownMenuItem(value: 'sha512', child: Text('SHA-512')),
              ],
              onChanged: (v) => setState(() => _algorithm = v ?? 'sha256'),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _encoding,
              items: const [
                DropdownMenuItem(value: 'hex', child: Text('Hex')),
                DropdownMenuItem(value: 'base64', child: Text('Base64')),
              ],
              onChanged: (v) => setState(() => _encoding = v ?? 'hex'),
            ),
          ),
          IconButton(onPressed: _generate, icon: const Icon(Icons.play_arrow)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _message,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _secret,
              decoration: const InputDecoration(
                labelText: 'Secret',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _output,
                readOnly: true,
                expands: true,
                maxLines: null,
                minLines: null,
                decoration: const InputDecoration(
                  labelText: 'Signature',
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
