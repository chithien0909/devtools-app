import 'package:devtools_plus/viewmodels/tool_selector_view_model.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/theme_view_model.dart';
import 'tool_selector_screen.dart';
import 'tool_workspace_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  void _closeDrawerIfOpen(BuildContext context) {
    final scaffoldState = Scaffold.maybeOf(context);
    if (scaffoldState?.isDrawerOpen == true) {
      Navigator.pop(context);
    }
  }

  void _openToolById(
    BuildContext context,
    ToolSelectorViewModel viewModel,
    String toolId, {
    int? operationIndex,
    String? category,
  }) {
    if (category != null) {
      viewModel.selectCategory(category);
    }
    viewModel.selectToolById(toolId);
    if (operationIndex != null) {
      viewModel.selectOperation(toolId, operationIndex);
    }
    final tool = viewModel.tools.firstWhere((t) => t.id == toolId);
    _closeDrawerIfOpen(context);
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ToolWorkspaceScreen(tool: tool)));
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ToolSelectorViewModel>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Scaffold(
          appBar: AppBar(
            title: const Text('DevTools+'),
            actions: [
              IconButton(
                icon: const Icon(Icons.brightness_6_outlined),
                onPressed: () => context.read<ThemeViewModel>().toggleTheme(),
                style: IconButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.surface.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
          body: const ToolSelectorScreen(),
        );
      },
    );
  }
}
