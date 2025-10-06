import 'package:flutter/material.dart';
import 'package:devtools_plus/models/tool_model.dart';

class ToolDefinition {
  final String id;
  final String name;
  final String description;
  final List<List<dynamic>> icon;
  final ToolCategory category;
  final Widget Function() screenBuilder;
  final List<String> keywords;
  final String route;

  const ToolDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.screenBuilder,
    required this.keywords,
  }) : route = '/tool/$id';

  ToolModel toToolModel() {
    return ToolModel(
      id: id,
      name: name,
      description: description,
      icon: icon,
      category: category,
      screen: screenBuilder(),
    );
  }

  bool matchesQuery(String query) {
    final q = query.toLowerCase();
    return name.toLowerCase().contains(q) ||
        description.toLowerCase().contains(q) ||
        keywords.any((k) => k.toLowerCase().contains(q));
  }
}
