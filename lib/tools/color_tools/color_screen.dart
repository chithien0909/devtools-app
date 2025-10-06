import 'dart:typed_data';

import 'package:devtools_plus/services/color_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ColorToolsScreen extends StatefulWidget {
  const ColorToolsScreen({super.key});

  @override
  State<ColorToolsScreen> createState() => _ColorToolsScreenState();
}

class _ColorToolsScreenState extends State<ColorToolsScreen> {
  final ColorService _service = const ColorService();
  final _hex = TextEditingController(text: '#3366ff');
  final _r = TextEditingController(text: '51');
  final _g = TextEditingController(text: '102');
  final _b = TextEditingController(text: '255');
  final _h = TextEditingController();
  final _s = TextEditingController();
  final _l = TextEditingController();

  List<int> _palette = const [];

  void _fromHex() {
    try {
      final rgb = _service.hexToRgb(_hex.text);
      _r.text = rgb[0].toString();
      _g.text = rgb[1].toString();
      _b.text = rgb[2].toString();
      final hsl = _service.rgbToHsl(rgb[0], rgb[1], rgb[2]);
      _h.text = hsl[0].toStringAsFixed(1);
      _s.text = hsl[1].toStringAsFixed(1);
      _l.text = hsl[2].toStringAsFixed(1);
    } catch (e) {
      _show(e.toString());
    }
  }

  void _fromRgb() {
    final r = int.tryParse(_r.text) ?? 0;
    final g = int.tryParse(_g.text) ?? 0;
    final b = int.tryParse(_b.text) ?? 0;
    _hex.text = _service.rgbToHex(r, g, b);
    final hsl = _service.rgbToHsl(r, g, b);
    _h.text = hsl[0].toStringAsFixed(1);
    _s.text = hsl[1].toStringAsFixed(1);
    _l.text = hsl[2].toStringAsFixed(1);
  }

  void _fromHsl() {
    final h = double.tryParse(_h.text) ?? 0;
    final s = double.tryParse(_s.text) ?? 0;
    final l = double.tryParse(_l.text) ?? 0;
    final rgb = _service.hslToRgb(h, s, l);
    _r.text = rgb[0].toString();
    _g.text = rgb[1].toString();
    _b.text = rgb[2].toString();
    _hex.text = _service.rgbToHex(rgb[0], rgb[1], rgb[2]);
  }

  Future<void> _pickImage() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.image);
    if (res == null) return;
    final Uint8List? bytes = res.files.single.bytes;
    if (bytes == null) return;
    final colors = await _service.dominantColorsFromBytes(bytes);
    setState(() { _palette = colors; });
  }

  void _show(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Tools'),
        actions: [IconButton(onPressed: _pickImage, icon: const Icon(Icons.image))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Wrap(spacing: 12, runSpacing: 12, children: [
            SizedBox(width: 160, child: TextField(controller: _hex, decoration: const InputDecoration(labelText: 'HEX #rrggbb', border: OutlineInputBorder()))),
            ElevatedButton(onPressed: _fromHex, child: const Text('From HEX')),
            SizedBox(width: 100, child: TextField(controller: _r, decoration: const InputDecoration(labelText: 'R', border: OutlineInputBorder()))),
            SizedBox(width: 100, child: TextField(controller: _g, decoration: const InputDecoration(labelText: 'G', border: OutlineInputBorder()))),
            SizedBox(width: 100, child: TextField(controller: _b, decoration: const InputDecoration(labelText: 'B', border: OutlineInputBorder()))),
            ElevatedButton(onPressed: _fromRgb, child: const Text('From RGB')),
            SizedBox(width: 100, child: TextField(controller: _h, decoration: const InputDecoration(labelText: 'H', border: OutlineInputBorder()))),
            SizedBox(width: 100, child: TextField(controller: _s, decoration: const InputDecoration(labelText: 'S', border: OutlineInputBorder()))),
            SizedBox(width: 100, child: TextField(controller: _l, decoration: const InputDecoration(labelText: 'L', border: OutlineInputBorder()))),
            ElevatedButton(onPressed: _fromHsl, child: const Text('From HSL')),
          ]),
          const SizedBox(height: 16),
          if (_palette.isNotEmpty)
            Wrap(spacing: 8, children: _palette.map((c) {
              final r = (c >> 16) & 0xFF;
              final g = (c >> 8) & 0xFF;
              final b = c & 0xFF;
              final hex = _service.rgbToHex(r, g, b);
              return Chip(
                backgroundColor: Color(0xFF000000 | c),
                label: Text(hex, style: const TextStyle(color: Colors.white)),
              );
            }).toList()),
        ],
      ),
    );
  }
}
