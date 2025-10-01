import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

enum ToolCategory { security, data, design, file, utility, fun }

extension ToolCategoryStyle on ToolCategory {
  String get label => switch (this) {
    ToolCategory.security => 'Security',
    ToolCategory.data => 'Data',
    ToolCategory.design => 'Design',
    ToolCategory.file => 'File',
    ToolCategory.utility => 'Utility',
    ToolCategory.fun => 'Fun',
  };

  List<List<dynamic>> get iconData => switch (this) {
    ToolCategory.security => HugeIcons.strokeRoundedShield01,
    ToolCategory.data => HugeIcons.strokeRoundedDatabase01,
    ToolCategory.design => HugeIcons.strokeRoundedPenTool01,
    ToolCategory.file => HugeIcons.strokeRoundedFolder01,
    ToolCategory.utility => HugeIcons.strokeRoundedWrench01,
    ToolCategory.fun => HugeIcons.strokeRoundedSparkles,
  };

  LinearGradient get accentGradient => switch (this) {
    ToolCategory.security => const LinearGradient(
      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    ToolCategory.data => const LinearGradient(
      colors: [Color(0xFF4D9FFF), Color(0xFF40C4FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    ToolCategory.design => const LinearGradient(
      colors: [Color(0xFFB388FF), Color(0xFFE1BEE7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    ToolCategory.file => const LinearGradient(
      colors: [Color(0xFF4CAF50), Color(0xFFA5D6A7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    ToolCategory.utility => const LinearGradient(
      colors: [Color(0xFF26A69A), Color(0xFF80CBC4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    ToolCategory.fun => const LinearGradient(
      colors: [Color(0xFFFFEB3B), Color(0xFFFFC107)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  };

  Color get glowColor => accentGradient.colors.last;
}

class ToolModel {
  final String id;
  final String name;
  final String description;
  final List<List<dynamic>> icon;
  final ToolCategory category;
  final Widget screen;

  const ToolModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.screen,
  });
}
