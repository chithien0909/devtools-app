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
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 1600
                ? 8
                : width >= 1200
                ? 6
                : width >= 900
                ? 5
                : width >= 600
                ? 3
                : 2;
            return GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: tools.length,
              itemBuilder: (context, index) {
                final tool = tools[index];
                return ToolCard(tool: tool);
              },
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
