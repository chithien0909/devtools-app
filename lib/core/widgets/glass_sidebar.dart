import 'package:devtools_plus/providers/tool_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassmorphism/glassmorphism.dart';

class GlassSidebar extends ConsumerWidget {
  const GlassSidebar({super.key});

  static const double _minWidth = 80;
  static const double _maxWidth = 280;

  // Responsive breakpoints
  static const double _tabletBreakpoint = 1200;

  static const IconData _dashboardIcon = Icons.dashboard;
  static const IconData _settingsIcon = Icons.settings;
  static const IconData _aboutIcon = Icons.info;
  static const IconData _sparkleIcon = Icons.star;
  static const IconData _sunIcon = Icons.light_mode;
  static const IconData _moonIcon = Icons.dark_mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final section = ref.watch(appSectionProvider);
    final mode = ref.watch(themeModeProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine if sidebar should be collapsed based on screen size
    // Mobile: < 768px, Tablet: 768-1200px, Desktop: > 1200px
    final isCollapsed = screenWidth < _tabletBreakpoint;
    final sidebarWidth = isCollapsed ? _minWidth : _maxWidth;

    return Container(
      width: sidebarWidth,
      padding: EdgeInsets.symmetric(
        vertical: 24,
        horizontal: isCollapsed ? 8 : 16,
      ),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 28,
        blur: 18,
        border: 0,
        alignment: Alignment.topCenter,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface.withValues(alpha: 0.08),
            theme.colorScheme.surface.withValues(alpha: 0.18),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.12),
            theme.colorScheme.primary.withValues(alpha: 0.05),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
          child: Column(
            children: [
              const _SidebarHeader(),
              const SizedBox(height: 24),
              Expanded(
                child: Column(
                  children: [
                    _SidebarNavButton(
                      icon: _dashboardIcon,
                      label: 'Dashboard',
                      isActive: section == AppSection.dashboard,
                      collapsed: isCollapsed,
                      onTap: () => ref.read(appSectionProvider.notifier).state =
                          AppSection.dashboard,
                    ),
                    const SizedBox(height: 12),
                    _SidebarNavButton(
                      icon: _settingsIcon,
                      label: 'Settings',
                      isActive: section == AppSection.settings,
                      collapsed: isCollapsed,
                      onTap: () => ref.read(appSectionProvider.notifier).state =
                          AppSection.settings,
                    ),
                    const SizedBox(height: 12),
                    _SidebarNavButton(
                      icon: _aboutIcon,
                      label: 'About',
                      isActive: section == AppSection.about,
                      collapsed: isCollapsed,
                      onTap: () => ref.read(appSectionProvider.notifier).state =
                          AppSection.about,
                    ),
                  ],
                ),
              ),
              _SidebarThemeToggle(
                mode: mode,
                collapsed: isCollapsed,
                onToggle: () => ref.read(themeModeProvider.notifier).toggle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Hero(
      tag: 'app-badge',
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.75),
              theme.colorScheme.secondary.withValues(alpha: 0.65),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          GlassSidebar._sparkleIcon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

class _SidebarNavButton extends StatelessWidget {
  const _SidebarNavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.collapsed,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool collapsed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;

    return Tooltip(
      message: label,
      waitDuration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.18)
              : theme.colorScheme.surface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: collapsed ? 12 : 14,
                horizontal: collapsed ? 0 : 12,
              ),
              child: Row(
                mainAxisAlignment: collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: isActive
                        ? activeColor
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarThemeToggle extends StatelessWidget {
  const _SidebarThemeToggle({
    required this.mode,
    required this.collapsed,
    required this.onToggle,
  });

  final ThemeMode mode;
  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = mode == ThemeMode.dark;

    return Tooltip(
      message: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      waitDuration: const Duration(milliseconds: 300),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: theme.colorScheme.surface.withValues(alpha: 0.08),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onToggle,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 12,
                horizontal: collapsed ? 0 : 12,
              ),
              child: Row(
                mainAxisAlignment: collapsed
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(
                    isDark ? GlassSidebar._sunIcon : GlassSidebar._moonIcon,
                    size: 22,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isDark ? 'Light mode' : 'Dark mode',
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
