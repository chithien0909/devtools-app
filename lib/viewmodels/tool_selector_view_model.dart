import 'package:flutter/material.dart';

import '../data/models/developer_tool.dart';

class ToolSession {
  ToolSession() : inputController = TextEditingController();

  final TextEditingController inputController;
  String output = '';
  String? error;
  bool isProcessing = false;
  int activeOperationIndex = 0;

  void dispose() {
    inputController.dispose();
  }
}

class ToolSelectorViewModel extends ChangeNotifier {
  ToolSelectorViewModel(this.tools) {
    if (tools.isEmpty) {
      throw ArgumentError('At least one tool must be provided.');
    }
    _sessions[tools.first.id] = ToolSession();
  }

  final List<DeveloperTool> tools;
  final Map<String, ToolSession> _sessions = {};

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  DeveloperTool get activeTool => tools[_selectedIndex];

  ToolSession sessionFor(String toolId) {
    return _sessions.putIfAbsent(toolId, ToolSession.new);
  }

  void updateSelectedIndex(int index) {
    if (index == _selectedIndex) {
      return;
    }
    _selectedIndex = index;
    sessionFor(activeTool.id);
    notifyListeners();
  }

  void selectOperation(String toolId, int operationIndex) {
    final session = sessionFor(toolId);
    if (session.activeOperationIndex == operationIndex) {
      return;
    }
    session
      ..activeOperationIndex = operationIndex
      ..error = null;
    notifyListeners();
  }

  Future<void> runCurrentOperation(String toolId) async {
    final tool = tools.firstWhere((item) => item.id == toolId);
    final session = sessionFor(toolId);
    final operation = tool.operations[session.activeOperationIndex];

    if (!operation.isImplemented) {
      session
        ..error = 'Feature coming soon.'
        ..output = ''
        ..isProcessing = false;
      notifyListeners();
      return;
    }

    session
      ..isProcessing = true
      ..error = null;
    notifyListeners();

    try {
      final input = session.inputController.text;
      final result = await operation.executor(input);
      session.output = result;
    } on FormatException catch (error) {
      session
        ..error = error.message
        ..output = '';
    } catch (error) {
      session
        ..error = error.toString()
        ..output = '';
    } finally {
      session.isProcessing = false;
      notifyListeners();
    }
  }

  void moveOutputToInput(String toolId) {
    final session = sessionFor(toolId);
    session.inputController.text = session.output;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final session in _sessions.values) {
      session.dispose();
    }
    super.dispose();
  }
}
