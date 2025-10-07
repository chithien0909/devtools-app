import 'dart:ui';

import 'package:devtools_plus/models/tool_model.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ToolCard extends StatefulWidget {
  const ToolCard({super.key, required this.tool, required this.onTap});

  final ToolModel tool;
  final VoidCallback onTap;

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  void _handleHighlight(bool value) {
    if (_isPressed != value) {
      setState(() => _isPressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = widget.tool.category;
    final accent = category.accentGradient;

    final glowColor = accent.colors.last.withValues(
      alpha: _isHovered ? 0.5 : 0.25,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            if (_isHovered || _isPressed)
              BoxShadow(
                color: glowColor,
                blurRadius: _isPressed ? 28 : 20,
                spreadRadius: 1,
                offset: const Offset(0, 14),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: accent.colors.last.withValues(
                    alpha: _isHovered ? 0.45 : 0.18,
                  ),
                  width: 1.2,
                ),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.surface.withValues(alpha: 0.62),
                    theme.colorScheme.surface.withValues(alpha: 0.32),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onHighlightChanged: _handleHighlight,
                  onTap: widget.onTap,
                  splashColor: accent.colors.last.withValues(alpha: 0.45),
                  highlightColor: accent.colors.first.withValues(alpha: 0.35),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CardIcon(accent: accent, tool: widget.tool),
                        const SizedBox(height: 18),
                        Text(
                          widget.tool.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.tool.description,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.72,
                            ),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _CategoryBadge(category: category),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardIcon extends StatelessWidget {
  const _CardIcon({required this.accent, required this.tool});

  final LinearGradient accent;
  final ToolModel tool;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'tool-${tool.id}-icon',
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: accent,
          boxShadow: [
            BoxShadow(
              color: accent.colors.last.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: HugeIcon(icon: tool.icon, color: Colors.white, size: 30),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final ToolCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = category.accentGradient;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            gradient.colors.first.withValues(alpha: 0.85),
            gradient.colors.last.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: category.iconData, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            category.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
