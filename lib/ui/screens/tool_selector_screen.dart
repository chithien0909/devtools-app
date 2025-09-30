import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/developer_tool.dart';
import '../../viewmodels/tool_selector_view_model.dart';
import 'tool_workspace_screen.dart';

class ToolSelectorScreen extends StatefulWidget {
  const ToolSelectorScreen({super.key});

  @override
  State<ToolSelectorScreen> createState() => _ToolSelectorScreenState();
}

class _ToolSelectorScreenState extends State<ToolSelectorScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _scrolled = false;
  bool _showChips = true;
  static const String _prefsShowChipsKey = 'tool_selector_show_chips';

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _scrollController.addListener(() {
      final offset = _scrollController.hasClients
          ? _scrollController.position.pixels
          : 0.0;
      final isNowScrolled = offset > 0;
      // Hysteresis for chips visibility: hide past 120, show under 40
      bool nextShowChips = _showChips;
      if (offset > 120) nextShowChips = false;
      if (offset < 40) nextShowChips = true;
      if (isNowScrolled != _scrolled || nextShowChips != _showChips) {
        setState(() {
          _scrolled = isNowScrolled;
          _showChips = nextShowChips;
        });
      }
    });
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_prefsShowChipsKey);
    if (saved != null && saved != _showChips) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _showChips = saved;
        });
      });
    }
  }

  Future<void> _toggleShowChips() async {
    setState(() {
      _showChips = !_showChips;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsShowChipsKey, _showChips);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ToolSelectorViewModel>(
      builder: (context, viewModel, _) {
        if (_searchController.text != viewModel.searchQuery) {
          _searchController.text = viewModel.searchQuery;
          _searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: _searchController.text.length),
          );
        }
        final tools = viewModel.filteredTools;
        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            // Bootstrap-like breakpoints: 576, 768, 992, 1200, 1600
            int toolCols;
            if (width >= 1600) {
              toolCols = 8;
            } else if (width >= 1200) {
              toolCols = 6;
            } else if (width >= 992) {
              toolCols = 5;
            } else if (width >= 768) {
              toolCols = 4;
            } else if (width >= 576) {
              toolCols = 3;
            } else {
              toolCols = 2;
            }

            int opCols;
            if (width >= 1600) {
              opCols = 8;
            } else if (width >= 1200) {
              opCols = 6;
            } else if (width >= 992) {
              opCols = 5;
            } else if (width >= 768) {
              opCols = 4;
            } else if (width >= 576) {
              opCols = 3;
            } else {
              opCols = 2;
            }
            // Build grouped sub-tools by category
            final Map<String, List<_OpItem>> grouped = {};
            for (final tool in tools) {
              final category = tool.category.trim().isEmpty
                  ? 'Uncategorized'
                  : tool.category;
              final list = grouped.putIfAbsent(category, () => <_OpItem>[]);
              for (var i = 0; i < tool.operations.length; i++) {
                list.add(_OpItem(tool: tool, opIndex: i));
              }
            }
            final sortedCategories = grouped.keys.toList()..sort();
            for (final cat in sortedCategories) {
              grouped[cat]!.sort((a, b) {
                final tc = a.tool.title.compareTo(b.tool.title);
                if (tc != 0) return tc;
                return a.tool.operations[a.opIndex].label.compareTo(
                  b.tool.operations[b.opIndex].label,
                );
              });
            }

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverAppBar(
                  pinned: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  elevation: _scrolled ? 2 : 0,
                  forceElevated: _scrolled,
                  titleSpacing: 6,
                  actions: [
                    Semantics(
                      button: true,
                      toggled: _showChips,
                      label: _showChips ? 'Hide filters' : 'Show filters',
                      child: IconButton(
                        tooltip: _showChips ? 'Hide filters' : 'Show filters',
                        icon: Icon(_showChips ? Icons.tune : Icons.tune_outlined),
                        onPressed: _toggleShowChips,
                      ),
                    ),
                  ],
                  title: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          const Icon(Icons.search, size: 20),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: viewModel.updateSearchQuery,
                              decoration: const InputDecoration(
                                hintText: 'Search tools and operations',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (viewModel.searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                viewModel.updateSearchQuery('');
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Chips moved below as a separate sliver to avoid AppBar overflow
                ),
                if (_showChips)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 4, 4, 6),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            Semantics(
                              button: true,
                              selected: viewModel.selectedCategory == null,
                              label: 'Category: All',
                              child: ChoiceChip(
                                label: const Text('All'),
                                selected: viewModel.selectedCategory == null,
                                onSelected: (_) => viewModel.selectCategory(null),
                              ),
                            ),
                            ...viewModel.categories.map(
                              (c) => Semantics(
                                button: true,
                                selected: viewModel.selectedCategory == c,
                                label: 'Category: ' + c,
                                child: ChoiceChip(
                                  label: Text(c),
                                  selected: viewModel.selectedCategory == c,
                                  onSelected: (_) => viewModel.selectCategory(c),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (tools.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 6.0,
                      ),
                      child: Text(
                        'All tools',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    for (final category in sortedCategories) ...[
                      if (grouped[category]!.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6.0,
                            horizontal: 6.0,
                          ),
                          child: Text(
                            category,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: opCols,
                                childAspectRatio: width >= 900 ? 2.6 : 2.1,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: grouped[category]!.length,
                          itemBuilder: (context, index) {
                            final item = grouped[category]![index];
                            return _OperationCard(
                              tool: item.tool,
                              opIndex: item.opIndex,
                            );
                          },
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
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class ToolCard extends StatefulWidget {
  const ToolCard({required this.tool, super.key});

  final DeveloperTool tool;

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> {
  bool _hovering = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tool = widget.tool;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: FocusableActionDetector(
          onShowFocusHighlight: (v) => setState(() => _focused = v),
          child: Card(
          margin: const EdgeInsets.all(0),
          elevation: _hovering ? 6 : 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: Semantics(
            button: true,
            label: '${tool.title}. ${tool.tagline}',
            child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              Provider.of<ToolSelectorViewModel>(context, listen: false)
                  .addToRecentTools(tool);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ToolWorkspaceScreen(tool: tool)),
              );
            },
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [tool.primaryColor, tool.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                if (_focused)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.9),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.10),
                          Colors.black.withOpacity(0.18),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            tool.icon,
                            size: 22,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                            ),
                            child: Semantics(
                              button: true,
                              toggled: tool.isFavorite,
                              label: tool.isFavorite
                                  ? 'Remove from favorites'
                                  : 'Add to favorites',
                              child: IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.all(6),
                              icon: Icon(
                                tool.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.white,
                                size: 18,
                              ),
                                tooltip: tool.isFavorite
                                    ? 'Remove from favorites'
                                    : 'Add to favorites',
                              onPressed: () =>
                                  Provider.of<ToolSelectorViewModel>(context,
                                          listen: false)
                                      .toggleFavorite(tool),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        tool.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tool.tagline,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: tool.primaryColor.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.label_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  tool.category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: tool.primaryColor.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.widgets_outlined,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${tool.operations.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
  }
}

class _OpItem {
  const _OpItem({required this.tool, required this.opIndex});
  final DeveloperTool tool;
  final int opIndex;
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
      child: Semantics(
        button: true,
        label: '${tool.title} - ${op.label}. ${op.description}',
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
