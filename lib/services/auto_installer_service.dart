import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'bundled_tools_service.dart';

enum DependencyTool {
  ytDlp('yt-dlp', 'YouTube video downloader'),
  ffmpeg('ffmpeg', 'Multimedia framework for video/audio processing'),
  python('python3', 'Python interpreter (required for yt-dlp)'),
  pip('pip3', 'Python package installer');

  const DependencyTool(this.command, this.description);
  final String command;
  final String description;
}

enum InstallationMethod {
  homebrew('Homebrew'),
  pip('Python pip'),
  direct('Direct download'),
  system('System package manager');

  const InstallationMethod(this.displayName);
  final String displayName;
}

class InstallationProgress {
  final String toolName;
  final double percentage;
  final String status;
  final String? currentStep;
  final bool isComplete;
  final String? error;

  const InstallationProgress({
    required this.toolName,
    required this.percentage,
    required this.status,
    this.currentStep,
    this.isComplete = false,
    this.error,
  });

  InstallationProgress copyWith({
    String? toolName,
    double? percentage,
    String? status,
    String? currentStep,
    bool? isComplete,
    String? error,
  }) {
    return InstallationProgress(
      toolName: toolName ?? this.toolName,
      percentage: percentage ?? this.percentage,
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      isComplete: isComplete ?? this.isComplete,
      error: error ?? this.error,
    );
  }
}

class DependencyInfo {
  final DependencyTool tool;
  final bool isInstalled;
  final String? version;
  final InstallationMethod? suggestedMethod;
  final List<String>? installCommands;

  const DependencyInfo({
    required this.tool,
    required this.isInstalled,
    this.version,
    this.suggestedMethod,
    this.installCommands,
  });
}

class AutoInstallerService {
  static final AutoInstallerService _instance = AutoInstallerService._internal();
  factory AutoInstallerService() => _instance;
  AutoInstallerService._internal();
  
  final BundledToolsService _bundledTools = BundledToolsService();

  final Map<String, Process> _runningProcesses = {};
  final StreamController<InstallationProgress> _progressController = StreamController.broadcast();
  
  Stream<InstallationProgress> get progressStream => _progressController.stream;

  /// Check if a tool is installed
  Future<bool> isToolInstalled(DependencyTool tool) async {
    // First check bundled tools
    if (tool == DependencyTool.ffmpeg) {
      if (await _bundledTools.isBundledFfmpegAvailable()) {
        return true;
      }
    } else if (tool == DependencyTool.ytDlp) {
      if (await _bundledTools.isBundledYtDlpAvailable()) {
        return true;
      }
    }
    
    // Fall back to system installation check
    try {
      final versionArgs = _getVersionArgs(tool);
      final result = await Process.run(tool.command, versionArgs);
      
      // Some tools like ffmpeg have special handling
      if (tool == DependencyTool.ffmpeg) {
        // ffmpeg is installed if stdout or stderr contains version info
        final output = result.stdout.toString() + result.stderr.toString();
        return output.toLowerCase().contains('ffmpeg version');
      }
      
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Get version information for a tool
  Future<String?> getToolVersion(DependencyTool tool) async {
    try {
      final versionArgs = _getVersionArgs(tool);
      final result = await Process.run(tool.command, versionArgs);
      
      String output;
      if (tool == DependencyTool.ffmpeg) {
        // ffmpeg outputs version info to stdout or stderr
        output = (result.stdout.toString() + result.stderr.toString()).trim();
        if (output.isNotEmpty && output.toLowerCase().contains('ffmpeg version')) {
          // Extract version from "ffmpeg version X.Y.Z"
          final versionRegex = RegExp(r'ffmpeg version ([\d\.]+)');
          final match = versionRegex.firstMatch(output);
          return match?.group(1);
        }
        return null;
      } else if (result.exitCode == 0) {
        output = result.stdout.toString().trim();
        // Extract version from common patterns
        final versionRegex = RegExp(r'(\d+\.[\d\.]+)');
        final match = versionRegex.firstMatch(output);
        return match?.group(1) ?? output.split('\n').first;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check all dependencies and their status
  Future<List<DependencyInfo>> checkAllDependencies() async {
    final dependencies = <DependencyInfo>[];
    
    for (final tool in DependencyTool.values) {
      final isInstalled = await isToolInstalled(tool);
      final version = isInstalled ? await getToolVersion(tool) : null;
      final suggestedMethod = _getSuggestedInstallationMethod(tool);
      final installCommands = _getInstallCommands(tool, suggestedMethod);
      
      dependencies.add(DependencyInfo(
        tool: tool,
        isInstalled: isInstalled,
        version: version,
        suggestedMethod: suggestedMethod,
        installCommands: installCommands,
      ));
    }
    
    return dependencies;
  }

  /// Auto-install a specific tool
  Future<bool> autoInstallTool(DependencyTool tool) async {
    final method = _getSuggestedInstallationMethod(tool);
    final commands = _getInstallCommands(tool, method);
    
    if (commands == null || commands.isEmpty) {
      _progressController.add(InstallationProgress(
        toolName: tool.command,
        percentage: 0,
        status: 'Installation not supported',
        error: 'No installation method available for ${tool.command}',
      ));
      return false;
    }

    return await _executeInstallation(tool, commands);
  }

  /// Auto-install all missing dependencies
  Future<Map<DependencyTool, bool>> autoInstallAll() async {
    final dependencies = await checkAllDependencies();
    final missingTools = dependencies.where((dep) => !dep.isInstalled).map((dep) => dep.tool);
    final results = <DependencyTool, bool>{};
    
    for (final tool in missingTools) {
      _progressController.add(InstallationProgress(
        toolName: tool.command,
        percentage: 0,
        status: 'Starting installation...',
      ));
      
      final success = await autoInstallTool(tool);
      results[tool] = success;
      
      if (!success) {
        _progressController.add(InstallationProgress(
          toolName: tool.command,
          percentage: 0,
          status: 'Installation failed',
          error: 'Failed to install ${tool.command}',
        ));
      }
    }
    
    return results;
  }

  /// Execute installation commands
  Future<bool> _executeInstallation(DependencyTool tool, List<String> commands) async {
    try {
      for (int i = 0; i < commands.length; i++) {
        final command = commands[i];
        final parts = command.split(' ');
        final executable = parts.first;
        final args = parts.skip(1).toList();
        
        _progressController.add(InstallationProgress(
          toolName: tool.command,
          percentage: (i / commands.length) * 100,
          status: 'Running: $command',
          currentStep: 'Step ${i + 1} of ${commands.length}',
        ));
        
        final process = await Process.start(executable, args);
        _runningProcesses[tool.command] = process;
        
        // Listen to output for progress
        process.stdout.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
          debugPrint('Installation output: $line');
        });
        
        process.stderr.transform(utf8.decoder).transform(const LineSplitter()).listen((line) {
          debugPrint('Installation error: $line');
        });
        
        final exitCode = await process.exitCode;
        _runningProcesses.remove(tool.command);
        
        if (exitCode != 0) {
          _progressController.add(InstallationProgress(
            toolName: tool.command,
            percentage: (i / commands.length) * 100,
            status: 'Installation failed',
            error: 'Command failed: $command (exit code: $exitCode)',
          ));
          return false;
        }
      }
      
      // Verify installation
      final isInstalled = await isToolInstalled(tool);
      
      _progressController.add(InstallationProgress(
        toolName: tool.command,
        percentage: 100,
        status: isInstalled ? 'Installation complete' : 'Installation verification failed',
        isComplete: true,
        error: isInstalled ? null : 'Tool not found after installation',
      ));
      
      return isInstalled;
    } catch (e) {
      _progressController.add(InstallationProgress(
        toolName: tool.command,
        percentage: 0,
        status: 'Installation error',
        error: e.toString(),
      ));
      return false;
    }
  }

  /// Cancel installation for a specific tool
  void cancelInstallation(DependencyTool tool) {
    final process = _runningProcesses[tool.command];
    if (process != null) {
      process.kill();
      _runningProcesses.remove(tool.command);
      _progressController.add(InstallationProgress(
        toolName: tool.command,
        percentage: 0,
        status: 'Installation cancelled',
      ));
    }
  }

  /// Get suggested installation method based on platform
  InstallationMethod _getSuggestedInstallationMethod(DependencyTool tool) {
    if (Platform.isMacOS) {
      switch (tool) {
        case DependencyTool.ytDlp:
        case DependencyTool.ffmpeg:
          return InstallationMethod.homebrew;
        case DependencyTool.python:
          return InstallationMethod.homebrew;
        case DependencyTool.pip:
          return InstallationMethod.pip;
      }
    } else if (Platform.isLinux) {
      return InstallationMethod.system;
    } else if (Platform.isWindows) {
      switch (tool) {
        case DependencyTool.ytDlp:
          return InstallationMethod.pip;
        case DependencyTool.ffmpeg:
          return InstallationMethod.direct;
        case DependencyTool.python:
        case DependencyTool.pip:
          return InstallationMethod.direct;
      }
    }
    return InstallationMethod.direct;
  }

  /// Get installation commands for a tool and method
  List<String>? _getInstallCommands(DependencyTool tool, InstallationMethod method) {
    if (Platform.isMacOS) {
      switch (method) {
        case InstallationMethod.homebrew:
          return _getHomebrewCommands(tool);
        case InstallationMethod.pip:
          return _getPipCommands(tool);
        default:
          return null;
      }
    } else if (Platform.isLinux) {
      return _getLinuxCommands(tool);
    } else if (Platform.isWindows) {
      return _getWindowsCommands(tool, method);
    }
    return null;
  }

  /// Get Homebrew installation commands (macOS)
  List<String> _getHomebrewCommands(DependencyTool tool) {
    switch (tool) {
      case DependencyTool.ytDlp:
        return ['brew install yt-dlp'];
      case DependencyTool.ffmpeg:
        return ['brew install ffmpeg'];
      case DependencyTool.python:
        return ['brew install python'];
      case DependencyTool.pip:
        // pip comes with python on modern installations
        return ['python3 -m ensurepip --upgrade'];
    }
  }

  /// Get pip installation commands
  List<String> _getPipCommands(DependencyTool tool) {
    switch (tool) {
      case DependencyTool.ytDlp:
        return ['pip3 install --upgrade yt-dlp'];
      case DependencyTool.python:
      case DependencyTool.ffmpeg:
      case DependencyTool.pip:
        return [];
    }
  }

  /// Get Linux installation commands
  List<String> _getLinuxCommands(DependencyTool tool) {
    // Detect package manager and provide appropriate commands
    switch (tool) {
      case DependencyTool.ytDlp:
        return ['sudo apt-get update && sudo apt-get install -y yt-dlp || pip3 install --upgrade yt-dlp'];
      case DependencyTool.ffmpeg:
        return ['sudo apt-get update && sudo apt-get install -y ffmpeg'];
      case DependencyTool.python:
        return ['sudo apt-get update && sudo apt-get install -y python3'];
      case DependencyTool.pip:
        return ['sudo apt-get update && sudo apt-get install -y python3-pip'];
    }
  }

  /// Get Windows installation commands
  List<String> _getWindowsCommands(DependencyTool tool, InstallationMethod method) {
    switch (tool) {
      case DependencyTool.ytDlp:
        return ['pip install --upgrade yt-dlp'];
      case DependencyTool.python:
        // This would require downloading Python installer
        return [];
      case DependencyTool.ffmpeg:
        // This would require downloading FFmpeg
        return [];
      case DependencyTool.pip:
        return ['python -m ensurepip --upgrade'];
    }
  }

  /// Check if Homebrew is installed (macOS)
  Future<bool> isHomebrewInstalled() async {
    if (!Platform.isMacOS) return false;
    try {
      final result = await Process.run('brew', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Install Homebrew if needed (macOS)
  Future<bool> installHomebrew() async {
    if (!Platform.isMacOS) return false;
    
    try {
      _progressController.add(const InstallationProgress(
        toolName: 'homebrew',
        percentage: 0,
        status: 'Installing Homebrew...',
      ));
      
      const installScript = r'/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"';
      final result = await Process.run('sh', ['-c', installScript]);
      
      final success = result.exitCode == 0;
      
      _progressController.add(InstallationProgress(
        toolName: 'homebrew',
        percentage: 100,
        status: success ? 'Homebrew installed' : 'Homebrew installation failed',
        isComplete: true,
        error: success ? null : result.stderr.toString(),
      ));
      
      return success;
    } catch (e) {
      _progressController.add(InstallationProgress(
        toolName: 'homebrew',
        percentage: 0,
        status: 'Homebrew installation failed',
        error: e.toString(),
      ));
      return false;
    }
  }

  /// Get the correct version arguments for each tool
  List<String> _getVersionArgs(DependencyTool tool) {
    switch (tool) {
      case DependencyTool.ffmpeg:
        return ['-version']; // ffmpeg uses single dash
      case DependencyTool.ytDlp:
      case DependencyTool.python:
      case DependencyTool.pip:
        return ['--version']; // most tools use double dash
    }
  }

  void dispose() {
    for (final process in _runningProcesses.values) {
      process.kill();
    }
    _runningProcesses.clear();
    _progressController.close();
  }
}
