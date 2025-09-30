import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/developer_tool.dart';
import '../../viewmodels/tool_selector_view_model.dart';
import 'tool_workspace_screen.dart';

class ToolSelectorScreen extends StatelessWidget {
  const ToolSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ToolSelectorViewModel>(
      builder: (context, viewModel, _) {
        final tools = viewModel.filteredTools;
        final activeTool = viewModel.activeTool;
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final toolCols = width >= 1600
                ? 8
                : width >= 1200
                ? 6
                : width >= 900
                ? 5
                : width >= 600
                ? 3
                : 2;
            final opCols = width >= 1600
                ? 8
                : width >= 1200
                ? 6
                : width >= 900
                ? 5
                : width >= 600
                ? 4
                : 2;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activeTool.operations.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 6.0,
                      ),
                      child: Text(
                        'Sub tools · ${activeTool.title}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: opCols,
                        childAspectRatio: 2.6,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: activeTool.operations.length,
                      itemBuilder: (context, index) {
                        final op = activeTool.operations[index];
                        return _OperationCard(tool: activeTool, opIndex: index);
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (tools.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 6.0,
                      ),
                      child: Text(
                        'All sub tools',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    for (final tool in tools) ...[
                      if (tool.operations.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 6.0,
                          ),
                          child: Text(
                            tool.title,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: opCols,
                                childAspectRatio: 2.6,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: tool.operations.length,
                          itemBuilder: (context, index) =>
                              _OperationCard(tool: tool, opIndex: index),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ],
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: toolCols,
                      childAspectRatio: 1,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: tools.length,
                    itemBuilder: (context, index) {
                      final tool = tools[index];
                      return ToolCard(tool: tool);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class ToolCard extends StatelessWidget {
  const ToolCard({required this.tool, super.key});

  final DeveloperTool tool;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0), // Removed margin
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Provider.of<ToolSelectorViewModel>(
            context,
            listen: false,
          ).addToRecentTools(tool);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ToolWorkspaceScreen(tool: tool)),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [tool.primaryColor, tool.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0), // Decreased padding
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        tool.icon,
                        size: 18,
                        color: Colors.white.withOpacity(0.85),
                      ), // Decreased icon size
                      IconButton(
                        icon: Icon(
                          tool.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () => Provider.of<ToolSelectorViewModel>(
                          context,
                          listen: false,
                        ).toggleFavorite(tool),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tool.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ), // Adjusted text style
                  const SizedBox(height: 2),
                  Text(
                    tool.tagline,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ), // Adjusted text style
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OperationCard extends StatelessWidget {
  const _OperationCard({required this.tool, required this.opIndex});

  final DeveloperTool tool;
  final int opIndex;

  @override
  Widget build(BuildContext context) {
    final op = tool.operations[opIndex];
    final color = tool.primaryColor;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          final vm = Provider.of<ToolSelectorViewModel>(context, listen: false);
          vm.selectToolById(tool.id);
          vm.selectOperation(tool.id, opIndex);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ToolWorkspaceScreen(tool: tool)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(op.icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      op.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      op.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
