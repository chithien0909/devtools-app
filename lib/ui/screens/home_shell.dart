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
              ),
            ],
          ),
          drawer: isMobile
              ? Drawer(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: buildDrawer(context, viewModel),
                )
              : null,
          body: Row(
            children: [
              if (!isMobile)
                SizedBox(width: 300, child: buildDrawer(context, viewModel)),
              const Expanded(child: ToolSelectorScreen()),
            ],
          ),
        );
      },
    );
  }

  Widget buildDrawer(BuildContext context, ToolSelectorViewModel viewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final glassFill = (isDark ? Colors.white : Colors.black).withOpacity(
      isDark ? 0.08 : 0.06,
    );
    final glassBorder = (isDark ? Colors.white : Colors.black).withOpacity(
      isDark ? 0.18 : 0.12,
    );
    final headerColors = isDark
        ? <Color>[
            colorScheme.primary.withOpacity(0.60),
            colorScheme.secondary.withOpacity(0.45),
            colorScheme.tertiary.withOpacity(0.35),
          ]
        : <Color>[
            colorScheme.primaryContainer.withOpacity(0.70),
            colorScheme.secondaryContainer.withOpacity(0.55),
            colorScheme.tertiaryContainer.withOpacity(0.45),
          ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                color: glassFill,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: glassBorder),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ListTileTheme(
                selectedColor: isDark ? Colors.white : Colors.black,
                selectedTileColor:
                    (isDark
                            ? colorScheme.primary
                            : colorScheme.primaryContainer)
                        .withOpacity(0.16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: headerColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset('assets/images/logo.png'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'DevTools+',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        onChanged: (value) =>
                            viewModel.updateSearchQuery(value),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: (isDark ? Colors.white : Colors.black)
                              .withOpacity(0.08),
                          hintText: 'Search tools...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: glassBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: glassBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: colorScheme.primary.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.security),
                      title: const Text('Security / Dev Tools'),
                      onTap: () {
                        _openToolById(
                          context,
                          viewModel,
                          'security_tools',
                          category: 'Security',
                        );
                      },
                    ),
                    _allToolsSection(context, viewModel),
                    _recentSection(context, viewModel),
                    _favoritesSection(context, viewModel),
                    _categorySection(
                      context,
                      viewModel,
                      'Security',
                      Icons.security,
                    ),
                    _categorySection(
                      context,
                      viewModel,
                      'Data',
                      Icons.data_object,
                    ),
                    _categorySection(
                      context,
                      viewModel,
                      'Design',
                      Icons.design_services,
                    ),
                    _categorySection(
                      context,
                      viewModel,
                      'Utilities',
                      Icons.build,
                      displayLabel: 'Utility',
                    ),
                    _categorySection(context, viewModel, 'File', Icons.folder),
                    _categorySection(
                      context,
                      viewModel,
                      'Fun',
                      Icons.sentiment_satisfied,
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

  Widget _recentSection(BuildContext context, ToolSelectorViewModel viewModel) {
    return _glassExpansion(
      context,
      icon: Icons.history,
      title: 'Recent Tools',
      isActive: false,
      expanded: false,
      children: viewModel.recentTools
          .map(
            (tool) => ListTile(
              title: Text(tool.title),
              selected: viewModel.activeTool.id == tool.id,
              onTap: () {
                viewModel.selectCategory(null);
                viewModel.selectToolById(tool.id);
                _closeDrawerIfOpen(context);
              },
            ),
          )
          .toList(),
    );
  }

  Widget _favoritesSection(
    BuildContext context,
    ToolSelectorViewModel viewModel,
  ) {
    return _glassExpansion(
      context,
      icon: Icons.favorite,
      title: 'Favorites',
      isActive: false,
      expanded: false,
      children: viewModel.tools
          .where((tool) => tool.isFavorite)
          .map(
            (tool) => ListTile(
              title: Text(tool.title),
              selected: viewModel.activeTool.id == tool.id,
              onTap: () {
                viewModel.selectCategory(null);
                viewModel.selectToolById(tool.id);
                _closeDrawerIfOpen(context);
              },
            ),
          )
          .toList(),
    );
  }

  Widget _categorySection(
    BuildContext context,
    ToolSelectorViewModel viewModel,
    String category,
    IconData icon, {
    String? displayLabel,
  }) {
    final isActive = viewModel.selectedCategory == category;
    final items = <Widget>[];
    for (final tool in viewModel.tools.where((t) => t.category == category)) {
      final isToolActive = viewModel.activeTool.id == tool.id;
      items.add(
        ListTile(
          title: Text(tool.title),
          trailing: const Icon(Icons.chevron_right, size: 18),
          selected: isToolActive,
          onTap: () =>
              _openToolById(context, viewModel, tool.id, category: category),
        ),
      );
      for (int i = 0; i < tool.operations.length; i++) {
        final op = tool.operations[i];
        final isOpActive =
            isToolActive &&
            viewModel.sessionFor(tool.id).activeOperationIndex == i;
        items.add(
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -2),
              leading: Icon(op.icon, size: 16),
              title: Text(op.label),
              subtitle: Text(op.description, overflow: TextOverflow.ellipsis),
              selected: isOpActive,
              onTap: () => _openToolById(
                context,
                viewModel,
                tool.id,
                category: category,
                operationIndex: i,
              ),
            ),
          ),
        );
      }
    }

    return _glassExpansion(
      context,
      icon: icon,
      title: displayLabel ?? category,
      isActive: isActive,
      expanded: isActive,
      onHeaderTap: () {
        viewModel.selectCategory(isActive ? null : category);
      },
      children: items,
    );
  }

  Widget _allToolsSection(
    BuildContext context,
    ToolSelectorViewModel viewModel,
  ) {
    final items = viewModel.tools
        .map(
          (tool) => ListTile(
            title: Text(tool.title),
            selected: viewModel.activeTool.id == tool.id,
            onTap: () => _openToolById(context, viewModel, tool.id),
          ),
        )
        .toList();

    return _glassExpansion(
      context,
      icon: Icons.grid_view_rounded,
      title: 'All Tools',
      isActive: viewModel.selectedCategory == null,
      expanded: viewModel.selectedCategory == null,
      onHeaderTap: () {
        viewModel.selectCategory(null);
      },
      children: items,
    );
  }

  // Sub Tools section removed; tools open directly

  Widget _glassExpansion(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isActive,
    List<Widget> children = const <Widget>[],
    VoidCallback? onHeaderTap,
    bool expanded = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: isActive ? 1 : 0),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutQuint,
        builder: (context, t, child) {
          final glowBase = isDark
              ? colorScheme.primary
              : colorScheme.primaryContainer;
          final glowColor = glowBase.withOpacity(0.35 * t);
          final activeGradient = LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(isDark ? 0.20 : 0.15),
              colorScheme.secondary.withOpacity(isDark ? 0.16 : 0.12),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color:
                  (isActive
                          ? Colors.transparent
                          : (isDark ? Colors.white : Colors.black))
                      .withOpacity(0.06 + 0.06 * t),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withOpacity(
                  0.12 + 0.08 * t,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 24 * t,
                  spreadRadius: 1 * t,
                ),
              ],
              gradient: isActive ? activeGradient : null,
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: Icon(
                  icon,
                  color: isDark
                      ? Colors.white.withOpacity(0.9)
                      : Colors.black.withOpacity(0.8),
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                initiallyExpanded: expanded,
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                childrenPadding: const EdgeInsets.only(
                  left: 8,
                  right: 8,
                  bottom: 8,
                ),
                onExpansionChanged: (_) {
                  if (onHeaderTap != null) {
                    onHeaderTap();
                  }
                },
                children: children,
              ),
            ),
          );
        },
      ),
    );
  }
}
