import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:provider/provider.dart';

import '../../data/models/developer_tool.dart';
import '../../viewmodels/tool_selector_view_model.dart';
import 'tool_workspace_screen.dart';

class ToolSelectorScreen extends StatefulWidget {
  const ToolSelectorScreen({super.key});

  @override
  State<ToolSelectorScreen> createState() => _ToolSelectorScreenState();
}

class _ToolSelectorScreenState extends State<ToolSelectorScreen> {
  late final LiquidController _controller;
  late final TextEditingController _searchController;
  bool _searchInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = LiquidController();
    _searchController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_searchInitialized) {
      final viewModel = context.read<ToolSelectorViewModel>();
      _searchController.text = viewModel.searchQuery;
      _searchController.addListener(() {
        context.read<ToolSelectorViewModel>().updateSearchQuery(
          _searchController.text,
        );
      });
      _searchInitialized = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _jumpToTool(int index, ToolSelectorViewModel viewModel) {
    if (index < 0 || index >= viewModel.tools.length) {
      return;
    }
    if (index == viewModel.selectedIndex) {
      return;
    }
    _controller.animateToPage(page: index, duration: 550);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ToolSelectorViewModel>(
      builder: (context, viewModel, _) {
        final tools = viewModel.tools;
        final activeTool = viewModel.activeTool;
        final filteredTools = viewModel.filteredTools;
        final session = viewModel.sessionFor(activeTool.id);

        Widget buildMainContent(bool withSidebar) {
          final horizontalPadding = withSidebar ? 32.0 : 24.0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  24,
                  horizontalPadding,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your modern developer Swiss Army knife.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Search, filter, or swipe through utilities, then open a focused workspace.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText:
                            'Search tools by name, description, or operation…',
                        suffixIcon: _searchController.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  context
                                      .read<ToolSelectorViewModel>()
                                      .updateSearchQuery('');
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _CategoryFilterChips(
                categories: viewModel.categories,
                selectedCategory: viewModel.selectedCategory,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                onSelected: (category) => viewModel.selectCategory(
                  category == 'All' ? null : category,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: withSidebar ? 360 : 320,
                child: Padding(
                  padding: EdgeInsets.only(right: withSidebar ? 24 : 0),
                  child: LiquidSwipe(
                    liquidController: _controller,
                    enableLoop: true,
                    waveType: WaveType.liquidReveal,
                    positionSlideIcon: 0.4,
                    slideIconWidget: const Icon(
                      Icons.swipe_right_alt_outlined,
                      color: Colors.white,
                    ),
                    onPageChangeCallback: viewModel.updateSelectedIndex,
                    pages: [
                      for (final tool in tools)
                        _ToolSwipePage(
                          tool: tool,
                          onLaunch: () => _openTool(context, tool),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _PageIndicator(
                  activeIndex: viewModel.selectedIndex,
                  length: tools.length,
                  primaryColor: activeTool.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _ToolGrid(
                  tools: filteredTools,
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  onPreview: (tool) {
                    final toolIndex = tools.indexWhere(
                      (candidate) => candidate.id == tool.id,
                    );
                    if (toolIndex != -1) {
                      _jumpToTool(toolIndex, viewModel);
                    }
                  },
                  onOpen: (tool) async {
                    final toolIndex = tools.indexWhere(
                      (candidate) => candidate.id == tool.id,
                    );
                    if (toolIndex != -1) {
                      _jumpToTool(toolIndex, viewModel);
                    }
                    await _openTool(context, tool);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  bottom: 16,
                ),
                child: _OperationSelectorStrip(
                  tool: activeTool,
                  session: session,
                  onSelected: (index) =>
                      viewModel.selectOperation(activeTool.id, index),
                ),
              ),
            ],
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('DevTools+'),
            actions: [
              IconButton(
                tooltip: 'Open workspace',
                onPressed: () => _openTool(context, activeTool),
                icon: const Icon(Icons.open_in_new_rounded),
              ),
            ],
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showSidebar = constraints.maxWidth >= 1240;
                if (!showSidebar) {
                  return buildMainContent(false);
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ToolSidebar(
                      tools: tools,
                      selectedIndex: viewModel.selectedIndex,
                      onTap: (index) => _jumpToTool(index, viewModel),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: buildMainContent(true)),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _openTool(BuildContext context, DeveloperTool tool) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: ToolWorkspaceScreen(tool: tool),
          );
        },
      ),
    );
  }
}

class _CategoryFilterChips extends StatelessWidget {
  const _CategoryFilterChips({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
    required this.padding,
  });

  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String> onSelected;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final entries = ['All', ...categories];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (final category in entries) ...[
            ChoiceChip(
              label: Text(category),
              selected: category == 'All'
                  ? selectedCategory == null
                  : selectedCategory == category,
              onSelected: (_) => onSelected(category),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _ToolSwipePage extends StatelessWidget {
  const _ToolSwipePage({required this.tool, required this.onLaunch});

  final DeveloperTool tool;
  final VoidCallback onLaunch;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: 'tool-${tool.id}-background',
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [tool.primaryColor, tool.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.05),
                Colors.black.withValues(alpha: 0.35),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  tool.icon,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: Colors.white.withValues(alpha: 0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tool.title,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                tool.tagline,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.black.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final op in tool.operations.take(3))
                                    Chip(
                                      avatar: Icon(op.icon, size: 18),
                                      label: Text(op.label),
                                    ),
                                  if (tool.operations.length > 3)
                                    Chip(
                                      label: Text(
                                        '+${tool.operations.length - 3} more',
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: onLaunch,
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text('Open ${tool.title}'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToolSidebar extends StatelessWidget {
  const _ToolSidebar({
    required this.tools,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<DeveloperTool> tools;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 300,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: tools.length,
              itemBuilder: (context, index) {
                final tool = tools[index];
                final isSelected = index == selectedIndex;
                final selectedColor = theme.colorScheme.primary.withValues(
                  alpha: 0.12,
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Material(
                    color: isSelected
                        ? selectedColor
                        : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => onTap(index),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: tool.primaryColor.withValues(
                                alpha: 0.2,
                              ),
                              child: Icon(tool.icon, color: tool.primaryColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tool.title,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tool.category,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ToolGrid extends StatelessWidget {
  const _ToolGrid({
    required this.tools,
    required this.onPreview,
    required this.onOpen,
    required this.padding,
  });

  final List<DeveloperTool> tools;
  final ValueChanged<DeveloperTool> onPreview;
  final ValueChanged<DeveloperTool> onOpen;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (tools.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'No tools match your search yet.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your keywords or filter to a different category.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        var crossAxisCount = (constraints.maxWidth / 320).floor();
        if (crossAxisCount < 1) {
          crossAxisCount = 1;
        } else if (crossAxisCount > 3) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          padding: EdgeInsets.fromLTRB(padding.left, 8, padding.right, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            final tool = tools[index];
            return _ToolGridCard(
              tool: tool,
              onPreview: () => onPreview(tool),
              onOpen: () => onOpen(tool),
            );
          },
        );
      },
    );
  }
}

class _ToolGridCard extends StatelessWidget {
  const _ToolGridCard({
    required this.tool,
    required this.onPreview,
    required this.onOpen,
  });

  final DeveloperTool tool;
  final VoidCallback onPreview;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onPreview,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: tool.primaryColor.withValues(alpha: 0.16),
                    child: Icon(tool.icon, color: tool.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tool.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(tool.category),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(tool.tagline, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final operation in tool.operations.take(3))
                    Chip(
                      avatar: Icon(operation.icon, size: 16),
                      label: Text(operation.label),
                    ),
                  if (tool.operations.length > 3)
                    Chip(label: Text('+${tool.operations.length - 3}')),
                ],
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomRight,
                child: FilledButton.tonalIcon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Open tool'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OperationSelectorStrip extends StatelessWidget {
  const _OperationSelectorStrip({
    required this.tool,
    required this.session,
    required this.onSelected,
  });

  final DeveloperTool tool;
  final ToolSession session;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final operation = tool.operations[index];
          final isSelected = session.activeOperationIndex == index;
          return ChoiceChip(
            label: Text(operation.label),
            avatar: Icon(operation.icon, size: 18),
            selected: isSelected,
            onSelected: (_) => onSelected(index),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: tool.operations.length,
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.activeIndex,
    required this.length,
    required this.primaryColor,
  });

  final int activeIndex;
  final int length;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          height: 8,
          width: isActive ? 36 : 12,
          decoration: BoxDecoration(
            color: isActive
                ? primaryColor
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}
