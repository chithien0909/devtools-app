import 'dart:ui';

import 'package:devtools_plus/core/widgets/tool_card.dart';
import 'package:devtools_plus/models/tool_model.dart';
import 'package:devtools_plus/providers/tool_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key, required this.onToolSelected});

  final void Function(ToolModel tool) onToolSelected;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late final TextEditingController _searchController;

  static const List<List<dynamic>> _searchIcon =
      HugeIcons.strokeRoundedAiSearch;
  static const List<List<dynamic>> _clearIcon =
      HugeIcons.strokeRoundedCancelCircle;
  static const List<List<dynamic>> _resetIcon = HugeIcons.strokeRoundedRefresh;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(toolFiltersProvider);
    _searchController = TextEditingController(text: filters.query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filters = ref.watch(toolFiltersProvider);
    final tools = ref.watch(filteredToolsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(theme, tools.length, filters),
          const SizedBox(height: 24),
          _buildSearchField(theme, filters),
          const SizedBox(height: 18),
          _CategoryFilterRow(activeCategory: filters.category),
          const SizedBox(height: 24),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = _resolveColumnCount(constraints.maxWidth);
                return MasonryGridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverSimpleGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                  ),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  itemCount: tools.length,
                  itemBuilder: (context, index) {
                    final tool = tools[index];
                    // Variable height by varying description length/child content naturally
                    return ToolCard(
                      tool: tool,
                      onTap: () => widget.onToolSelected(tool),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(
    ThemeData theme,
    int toolCount,
    ToolFilterState filters,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Hero(
          tag: 'dashboard-title',
          child: Text(
            'Dashboard',
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -1.2,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
          ),
          child: Text('$toolCount tools', style: theme.textTheme.labelLarge),
        ),
        const Spacer(),
        IconButton.filledTonal(
          tooltip: 'Reset filters',
          onPressed: filters.isDefault
              ? null
              : () => ref.read(toolFiltersProvider.notifier).clear(),
          icon: const HugeIcon(icon: _resetIcon, size: 20),
        ),
      ],
    );
  }

  Widget _buildSearchField(ThemeData theme, ToolFilterState filters) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surface.withValues(alpha: 0.45),
                theme.colorScheme.surface.withValues(alpha: 0.28),
              ],
            ),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.18),
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: ref.read(toolFiltersProvider.notifier).setQuery,
            style: theme.textTheme.titleMedium,
            decoration: InputDecoration(
              hintText: 'Search tools by name or description',
              hintStyle: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
              ),
              border: InputBorder.none,
              prefixIcon: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: HugeIcon(icon: _searchIcon, size: 22),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              suffixIcon: filters.query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        ref.read(toolFiltersProvider.notifier).setQuery('');
                      },
                      icon: const HugeIcon(icon: _clearIcon, size: 20),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  int _resolveColumnCount(double width) {
    if (width < 480) {
      return 2;
    }
    if (width < 560) {
      return 3;
    }
    if (width < 880) {
      return 4;
    }
    if (width < 1200) {
      return 5;
    }
    if (width < 1536) {
      return 6;
    }
    if (width < 1920) {
      return 7;
    }
    return 8;
  }
}

class _CategoryFilterRow extends ConsumerWidget {
  const _CategoryFilterRow({required this.activeCategory});

  final ToolCategory? activeCategory;

  static const List<List<dynamic>> _allIcon = HugeIcons.strokeRoundedGrid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categories =
        <({String label, List<List<dynamic>> icon, ToolCategory? category})>[
          (label: 'All', icon: _allIcon, category: null),
          for (final category in ToolCategory.values)
            (
              label: category.label,
              icon: category.iconData,
              category: category,
            ),
        ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          for (final item in categories) ...[
            _CategoryChip(
              label: item.label,
              icon: item.icon,
              isActive: item.category == activeCategory,
              gradient:
                  item.category?.accentGradient ??
                  LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.7),
                      theme.colorScheme.secondary.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
              onTap: () => ref
                  .read(toolFiltersProvider.notifier)
                  .setCategory(item.category),
            ),
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final List<List<dynamic>> icon;
  final bool isActive;
  final LinearGradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: label,
      waitDuration: const Duration(milliseconds: 200),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isActive
              ? gradient
              : LinearGradient(
                  colors: [
                    theme.colorScheme.surface.withValues(alpha: 0.5),
                    theme.colorScheme.surface.withValues(alpha: 0.2),
                  ],
                ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: gradient.colors.last.withValues(alpha: 0.45),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : null,
          border: Border.all(
            color: isActive
                ? Colors.transparent
                : theme.colorScheme.primary.withValues(alpha: 0.12),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(
                    icon: icon,
                    size: 20,
                    color: isActive
                        ? Colors.white
                        : theme.colorScheme.onSurface.withValues(alpha: 0.72),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isActive
                          ? Colors.white
                          : theme.colorScheme.onSurface.withValues(alpha: 0.85),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
