import 'package:devtools_plus/services/diff_service.dart';
import 'package:flutter/material.dart';

class DiffScreen extends StatefulWidget {
  const DiffScreen({super.key});

  @override
  State<DiffScreen> createState() => _DiffScreenState();
}

class _DiffScreenState extends State<DiffScreen> {
  final DiffService _service = const DiffService();
  final TextEditingController _left = TextEditingController();
  final TextEditingController _right = TextEditingController();
  late List<DiffChunk> _chunks = const [];

  void _runDiff() {
    setState(() {
      _chunks = _service.diffLines(_left.text, _right.text);
    });
  }

  @override
  void dispose() {
    _left.dispose();
    _right.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Diff'),
        actions: [
          IconButton(onPressed: _runDiff, icon: const Icon(Icons.compare))
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _left,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Original'),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _right,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Modified'),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: ListView.builder(
              itemCount: _chunks.length,
              itemBuilder: (context, index) {
                final c = _chunks[index];
                Color bg;
                switch (c.type) {
                  case DiffType.equal: bg = Colors.transparent; break;
                  case DiffType.insert: bg = Colors.green.withOpacity(0.15); break;
                  case DiffType.delete: bg = Colors.red.withOpacity(0.15); break;
                }
                return Container(
                  color: bg,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(c.text, style: const TextStyle(fontFamily: 'monospace')),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
