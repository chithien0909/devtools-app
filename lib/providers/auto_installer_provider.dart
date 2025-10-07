import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auto_installer_service.dart';

// Service provider
final autoInstallerServiceProvider = Provider<AutoInstallerService>((ref) {
  return AutoInstallerService();
});

// Dependencies status provider
final dependenciesStatusProvider = FutureProvider<List<DependencyInfo>>((ref) async {
  final service = ref.watch(autoInstallerServiceProvider);
  return await service.checkAllDependencies();
});

// Installation progress provider
final installationProgressProvider = StreamProvider<InstallationProgress>((ref) {
  final service = ref.watch(autoInstallerServiceProvider);
  return service.progressStream;
});

// Individual tool installation status providers
final ytDlpInstallationStatusProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(autoInstallerServiceProvider);
  return await service.isToolInstalled(DependencyTool.ytDlp);
});

final ffmpegInstallationStatusProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(autoInstallerServiceProvider);
  return await service.isToolInstalled(DependencyTool.ffmpeg);
});

final pythonInstallationStatusProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(autoInstallerServiceProvider);
  return await service.isToolInstalled(DependencyTool.python);
});

final pipInstallationStatusProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(autoInstallerServiceProvider);
  return await service.isToolInstalled(DependencyTool.pip);
});

// Homebrew status provider (macOS specific)
final homebrewStatusProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(autoInstallerServiceProvider);
  return await service.isHomebrewInstalled();
});

// Auto installer controller
final autoInstallerControllerProvider = StateNotifierProvider<AutoInstallerController, AutoInstallerState>((ref) {
  final service = ref.watch(autoInstallerServiceProvider);
  return AutoInstallerController(service);
});

class AutoInstallerState {
  final bool isInstalling;
  final Map<DependencyTool, bool> installationResults;
  final String? error;
  final List<DependencyInfo> dependencies;

  const AutoInstallerState({
    this.isInstalling = false,
    this.installationResults = const {},
    this.error,
    this.dependencies = const [],
  });

  AutoInstallerState copyWith({
    bool? isInstalling,
    Map<DependencyTool, bool>? installationResults,
    String? error,
    List<DependencyInfo>? dependencies,
  }) {
    return AutoInstallerState(
      isInstalling: isInstalling ?? this.isInstalling,
      installationResults: installationResults ?? this.installationResults,
      error: error ?? this.error,
      dependencies: dependencies ?? this.dependencies,
    );
  }
}

class AutoInstallerController extends StateNotifier<AutoInstallerState> {
  AutoInstallerController(this._service) : super(const AutoInstallerState()) {
    _loadDependencies();
  }

  final AutoInstallerService _service;

  Future<void> _loadDependencies() async {
    try {
      final dependencies = await _service.checkAllDependencies();
      state = state.copyWith(dependencies: dependencies);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refreshDependencies() async {
    await _loadDependencies();
  }

  Future<void> installTool(DependencyTool tool) async {
    if (state.isInstalling) return;

    state = state.copyWith(isInstalling: true, error: null);
    
    try {
      final success = await _service.autoInstallTool(tool);
      final results = Map<DependencyTool, bool>.from(state.installationResults);
      results[tool] = success;
      
      state = state.copyWith(
        isInstalling: false,
        installationResults: results,
      );
      
      // Refresh dependencies after installation
      await _loadDependencies();
    } catch (e) {
      state = state.copyWith(
        isInstalling: false,
        error: e.toString(),
      );
    }
  }

  Future<void> installAllMissing() async {
    if (state.isInstalling) return;

    state = state.copyWith(isInstalling: true, error: null);
    
    try {
      final results = await _service.autoInstallAll();
      state = state.copyWith(
        isInstalling: false,
        installationResults: results,
      );
      
      // Refresh dependencies after installation
      await _loadDependencies();
    } catch (e) {
      state = state.copyWith(
        isInstalling: false,
        error: e.toString(),
      );
    }
  }

  Future<void> installHomebrew() async {
    if (state.isInstalling) return;

    state = state.copyWith(isInstalling: true, error: null);
    
    try {
      final success = await _service.installHomebrew();
      state = state.copyWith(
        isInstalling: false,
        error: success ? null : 'Failed to install Homebrew',
      );
      
      // Refresh dependencies after installation
      await _loadDependencies();
    } catch (e) {
      state = state.copyWith(
        isInstalling: false,
        error: e.toString(),
      );
    }
  }

  void cancelInstallation(DependencyTool tool) {
    _service.cancelInstallation(tool);
    state = state.copyWith(isInstalling: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}