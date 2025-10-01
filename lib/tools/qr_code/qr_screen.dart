import 'package:devtools_plus/services/qr_code_service.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrCodeScreen extends StatefulWidget {
  const QrCodeScreen({super.key});

  @override
  State<QrCodeScreen> createState() => _QrCodeScreenState();
}

class _QrCodeScreenState extends State<QrCodeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _inputController = TextEditingController();
  final _qrCodeService = QrCodeService();
  Widget? _qrCode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _generate() {
    setState(() {
      _qrCode = _qrCodeService.generate(_inputController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator/Scanner'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Generator'),
            Tab(text: 'Scanner'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Generator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _inputController,
                  decoration: const InputDecoration(
                    labelText: 'Data',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _generate,
                  child: const Text('Generate'),
                ),
                const SizedBox(height: 16),
                if (_qrCode != null)
                  SizedBox(width: 200, height: 200, child: _qrCode),
              ],
            ),
          ),
          // Scanner
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('QR Code found: ${barcode.rawValue}')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
