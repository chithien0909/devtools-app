import 'package:devtools_plus/core/widgets/glass_sidebar.dart';
import 'package:devtools_plus/core/widgets/keyboard_shortcuts.dart';
import 'package:devtools_plus/models/tool_model.dart';
import 'package:devtools_plus/providers/tool_provider.dart';
import 'package:devtools_plus/screens/dashboard_screen.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

const List<List<dynamic>> _slideIcon = HugeIcons.strokeRoundedArrowRight02;
const List<List<dynamic>> _backIcon = HugeIcons.strokeRoundedArrowLeft02;
const List<List<dynamic>> _flashIcon = HugeIcons.strokeRoundedFlash;
const List<List<dynamic>> _shareIcon = HugeIcons.strokeRoundedShare01;
const List<List<dynamic>> _downloadIcon = HugeIcons.strokeRoundedDownload02;
const List<List<dynamic>> _copyIcon = HugeIcons.strokeRoundedCopy01;
const List<List<dynamic>> _emptyStateIcon = HugeIcons.strokeRoundedGrid;

class HomeScreen extends ConsumerStatefulWidget {
  final String? initialToolId;
  
  const HomeScreen({super.key, this.initialToolId});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final LiquidController _liquidController;
  late final PageController _pageController;
  int _currentLiquidPage = 0;

  @override
  void initState() {
    super.initState();
    _liquidController = LiquidController();
    _pageController = PageController(initialPage: 0);
  }

  void _handleToolSelected(ToolModel tool) {
    ref.read(activeToolProvider.notifier).state = tool;
    final isDesktop =
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
    if (isDesktop) {
      _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOut,
      );
    } else {
      _liquidController.animateToPage(page: 1, duration: 700);
    }
  }

  void _backToDashboard() {
    final isDesktop =
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
    if (isDesktop) {
      _pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
    } else {
      _liquidController.animateToPage(page: 0, duration: 600);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final section = ref.watch(appSectionProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive spacing based on screen size
    final spacing = screenWidth < 1200 ? 12.0 : 18.0;

    return KeyboardShortcuts(
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Stack(
          children: [
            const _AuroraBackground(),
            SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GlassSidebar(),
                  SizedBox(width: spacing),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: switch (section) {
                        AppSection.dashboard => _buildDashboardStack(theme),
                        AppSection.settings => const _SettingsView(),
                        AppSection.about => const _AboutView(),
                      },
                    ),
                  ),
                  SizedBox(width: spacing),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardStack(ThemeData theme) {
    return ClipRRect(
      key: const ValueKey('dashboard'),
      borderRadius: BorderRadius.circular(36),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface.withValues(alpha: 0.65),
              theme.colorScheme.surface.withValues(alpha: 0.35),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _buildPager(theme),
      ),
    );
  }

  Widget _buildPager(ThemeData theme) {
    final isDesktop =
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
    final pages = <Widget>[
      DashboardScreen(onToolSelected: _handleToolSelected),
      ToolDetailView(onBack: _backToDashboard),
    ];

    if (isDesktop) {
      return PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (page) {
          setState(() => _currentLiquidPage = page);
          if (page == 0) {
            ref.read(activeToolProvider.notifier).state = null;
          }
        },
        children: pages,
      );
    }

    return LiquidSwipe(
      pages: pages,
      liquidController: _liquidController,
      initialPage: _currentLiquidPage,
      enableLoop: false,
      waveType: WaveType.liquidReveal,
      fullTransitionValue: 600,
      slideIconWidget: const HugeIcon(
        icon: _slideIcon,
        color: Colors.white,
        size: 22,
      ),
      positionSlideIcon: 0.4,
      onPageChangeCallback: (page) {
        setState(() => _currentLiquidPage = page);
        if (page == 0) {
          ref.read(activeToolProvider.notifier).state = null;
        }
      },
    );
  }
}

class ToolDetailView extends ConsumerWidget {
  const ToolDetailView({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tool = ref.watch(activeToolProvider);
    final theme = Theme.of(context);

    if (tool == null) {
      return _EmptyDetailState(onBack: onBack);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton.filledTonal(
                tooltip: 'Back to dashboard',
                onPressed: onBack,
                icon: const HugeIcon(icon: _backIcon, size: 20),
              ),
              const SizedBox(width: 16),
              Hero(
                tag: 'dashboard-title',
                child: Text(
                  tool.name,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                  ),
                ),
              ),
              const Spacer(),
              _DetailFabBar(tool: tool),
            ],
          ),
          const SizedBox(height: 24),
          _DetailHeadline(tool: tool),
          const SizedBox(height: 28),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _GlassSection(title: 'Workspace', child: tool.screen),
                const SizedBox(height: 24),
                _GlassSection(
                  title: 'Output Preview',
                  child: _OutputPlaceholder(tool: tool),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => _handleRunTool(context, tool),
              icon: const HugeIcon(icon: _flashIcon, size: 22),
              label: const Text('Run Tool'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRunTool(BuildContext context, ToolModel tool) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Interact with the ${tool.name} workspace to execute.'),
      ),
    );
  }
}

class _DetailHeadline extends StatelessWidget {
  const _DetailHeadline({required this.tool});

  final ToolModel tool;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = tool.category.accentGradient;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Hero(
          tag: 'tool-${tool.id}-icon',
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: gradient,
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.last.withValues(alpha: 0.48),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: HugeIcon(icon: tool.icon, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tool.description,
                style: theme.textTheme.titleMedium?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 12),
              _DetailCategoryBadge(category: tool.category),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailCategoryBadge extends StatelessWidget {
  const _DetailCategoryBadge({required this.category});

  final ToolCategory category;

  @override
  Widget build(BuildContext context) {
    final gradient = category.accentGradient;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: gradient.colors),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.last.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: category.iconData, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            category.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailFabBar extends StatelessWidget {
  const _DetailFabBar({required this.tool});

  final ToolModel tool;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = [
      (icon: _shareIcon, tooltip: 'Share ${tool.name}'),
      (icon: _downloadIcon, tooltip: 'Save output'),
      (icon: _copyIcon, tooltip: 'Copy results'),
    ];

    return Wrap(
      spacing: 12,
      children: [
        for (final action in actions)
          Tooltip(
            message: action.tooltip,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: IconButton.filledTonal(
                onPressed: () {},
                icon: HugeIcon(icon: action.icon, size: 20),
              ),
            ),
          ),
      ],
    );
  }
}

class _GlassSection extends StatelessWidget {
  const _GlassSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface.withValues(alpha: 0.65),
              theme.colorScheme.surface.withValues(alpha: 0.35),
            ],
          ),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _OutputPlaceholder extends StatelessWidget {
  const _OutputPlaceholder({required this.tool});

  final ToolModel tool;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        'Output from the ${tool.name} tool will appear here.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _EmptyDetailState extends StatelessWidget {
  const _EmptyDetailState({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const HugeIcon(icon: _emptyStateIcon, size: 56),
          const SizedBox(height: 16),
          Text(
            'Select a tool from the dashboard',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onBack, child: const Text('Open dashboard')),
        ],
      ),
    );
  }
}

class _SettingsView extends ConsumerWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return _InfoView(
      key: const ValueKey('settings'),
      title: 'Settings',
      icon: HugeIcons.strokeRoundedSettings02,
      description:
          'Customize DevTools+ behavior, appearance, and advanced preferences.',
      children: [
        SwitchListTile.adaptive(
          title: const Text('Glass animations'),
          subtitle: const Text('Reduce motion for accessibility'),
          value: true,
          onChanged: (_) {},
        ),
        const Divider(),
        SwitchListTile.adaptive(
          title: const Text('Auto update tools'),
          subtitle: const Text('Stay in sync with the latest toolset'),
          value: true,
          onChanged: (_) {},
        ),
        const Divider(),
        ListTile(
          leading: const HugeIcon(icon: HugeIcons.strokeRoundedPenTool01),
          title: const Text('Accent color'),
          subtitle: const Text('Coming soon'),
          trailing: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowRight02,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          onTap: () {},
        ),
      ],
    );
  }
}

class _AboutView extends StatelessWidget {
  const _AboutView();

  @override
  Widget build(BuildContext context) {
    return _InfoView(
      key: const ValueKey('about'),
      title: 'About DevTools+',
      icon: HugeIcons.strokeRoundedInformationCircle,
      description:
          'DevTools+ is a curated collection of developer productivity utilities, wrapped in a modern glass UI.',
      children: [
        const ListTile(
          leading: HugeIcon(icon: HugeIcons.strokeRoundedSparkles),
          title: Text('Version'),
          subtitle: Text('1.0.0'),
        ),
        const Divider(),
        const ListTile(
          leading: HugeIcon(icon: HugeIcons.strokeRoundedShield01),
          title: Text('License'),
          subtitle: Text('MIT'),
        ),
        const Divider(),
        const ListTile(
          leading: HugeIcon(icon: HugeIcons.strokeRoundedUser02),
          title: Text('Credits'),
          subtitle: Text('Built by the DevTools+ community with ❤️'),
        ),
      ],
    );
  }
}

class _InfoView extends StatelessWidget {
  const _InfoView({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    required this.children,
  });

  final String title;
  final List<List<dynamic>> icon;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surface.withValues(alpha: 0.7),
                theme.colorScheme.surface.withValues(alpha: 0.4),
              ],
            ),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.14),
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(32),
            children: [
              Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.8),
                          theme.colorScheme.secondary.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                    child: HugeIcon(icon: icon, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(description, style: theme.textTheme.titleMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _AuroraBackground extends StatelessWidget {
  const _AuroraBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF312E81)],
        ),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          width: 420,
          height: 420,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [Color(0x33FFFFFF), Color(0x1100E5FF), Color(0x0000E5FF)],
            ),
          ),
        ),
      ),
    );
  }
}
