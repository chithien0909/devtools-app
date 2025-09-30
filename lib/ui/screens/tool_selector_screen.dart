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
      setState(() {
        _showChips = saved;
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
                    IconButton(
                      tooltip: _showChips ? 'Hide filters' : 'Show filters',
                      icon: Icon(_showChips ? Icons.tune : Icons.tune_outlined),
                      onPressed: _toggleShowChips,
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
                  bottom: PreferredSize(
                    preferredSize:
                        _showChips ? const Size.fromHeight(64) : const Size.fromHeight(0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: _showChips ? 64 : 0,
                      curve: Curves.easeOut,
                      child: (!_showChips)
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    ChoiceChip(
                                      label: const Text('All'),
                                      selected: viewModel.selectedCategory == null,
                                      onSelected: (_) => viewModel.selectCategory(null),
                                    ),
                                    ...viewModel.categories.map(
                                      (c) => ChoiceChip(
                                        label: Text(c),
                                        selected: viewModel.selectedCategory == c,
                                        onSelected: (_) => viewModel.selectCategory(c),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
