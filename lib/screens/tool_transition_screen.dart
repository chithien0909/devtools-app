import 'package:devtools_plus/models/tool_model.dart';
import 'package:devtools_plus/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class ToolTransitionScreen extends StatelessWidget {
  const ToolTransitionScreen({super.key, required this.tool});

  final ToolModel tool;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(onToolSelected: (_) {}),
      tool.screen,
    ];

    return Scaffold(body: LiquidSwipe(pages: pages, initialPage: 1));
  }
}
