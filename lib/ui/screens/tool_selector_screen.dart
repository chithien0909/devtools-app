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

  @override
  void initState() {
    super.initState();
    _controller = LiquidController();
  }

  void _jumpToTool(int index, ToolSelectorViewModel viewModel) {
    if (index == viewModel.selectedIndex) {
      return;
    }
    _controller.animateToPage(
      page: index,
      duration: 500,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ToolSelectorViewModel>(
      builder: (context, viewModel, _) {
        final tools = viewModel.tools;
        final activeTool = viewModel.activeTool;
        final session = viewModel.sessionFor(activeTool.id);

        Widget buildMainContent(bool withSidebar) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: withSidebar
                    ? const EdgeInsets.fromLTRB(32, 24, 32, 0)
                    : const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your modern developer Swiss Army knife.',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Swipe to explore utilities, then tap to launch a focused workspace.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: withSidebar
                      ? const EdgeInsets.only(right: 24)
                      : const EdgeInsets.symmetric(horizontal: 0),
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
                padding: withSidebar
                    ? const EdgeInsets.symmetric(horizontal: 32)
                    : EdgeInsets.zero,
                child: _PageIndicator(
                  activeIndex: viewModel.selectedIndex,
                  length: tools.length,
                  primaryColor: activeTool.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: withSidebar
                    ? const EdgeInsets.symmetric(horizontal: 32)
                    : EdgeInsets.zero,
                child: _OperationSelectorStrip(
                  tool: activeTool,
                  session: session,
                  onSelected: (index) =>
                      viewModel.selectOperation(activeTool.id, index),
                ),
              ),
              const SizedBox(height: 16),
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
                final showSidebar = constraints.maxWidth >= 1120;
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

class _ToolSwipePage extends StatelessWidget {
  const _ToolSwipePage({
    required this.tool,
    required this.onLaunch,
  });

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
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                tool.tagline,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.black.withValues(alpha: 0.7),
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
                                      label:
                                          Text('+${tool.operations.length - 3} more'),
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
      width: 280,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: tools.length,
              itemBuilder: (context, index) {
                final tool = tools[index];
                final isSelected = index == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Material(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.12)
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
                              backgroundColor:
                                  tool.primaryColor.withValues(alpha: 0.2),
                              child: Icon(
                                tool.icon,
                                color: tool.primaryColor,
                              ),
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
                                    tool.tagline,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
