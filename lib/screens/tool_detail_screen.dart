import 'package:devtools_plus/models/tool_model.dart';
import 'package:flutter/material.dart';

class ToolDetailScreen extends StatelessWidget {
  const ToolDetailScreen({super.key, required this.tool});

  final ToolModel tool;

  @override
  Widget build(BuildContext context) {
    return tool.screen;
  }
}
