import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auto_installer_service.dart';
import '../providers/auto_installer_provider.dart';

class DependencyInstallationDialog extends ConsumerStatefulWidget {
  const DependencyInstallationDialog({super.key});

  @override
  ConsumerState<DependencyInstallationDialog> createState() => _DependencyInstallationDialogState();
}

class _DependencyInstallationDialogState extends ConsumerState<DependencyInstallationDialog> {
  @override
  Widget build(BuildContext context) {
    final dependencies = ref.watch(dependenciesStatusProvider);
    final installationProgress = ref.watch(installationProgressProvider);
    final installerState = ref.watch(autoInstallerControllerProvider);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.build),
          SizedBox(width: 12),
          Text('Dependency Manager'),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Install required tools for your DevTools+ app:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: dependencies.when(
                data: (deps) => _buildDependenciesList(deps, installerState),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _buildErrorWidget(error.toString()),
              ),
            ),
            const SizedBox(height: 16),
            installationProgress.when(
              data: (progress) => _buildProgressWidget(progress),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: installerState.isInstalling
              ? null
              : () => ref.read(autoInstallerControllerProvider.notifier).installAllMissing(),
          icon: installerState.isInstalling
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: Text(installerState.isInstalling ? 'Installing...' : 'Install All Missing'),
        ),
      ],
    );
  }

  Widget _buildDependenciesList(List<DependencyInfo> dependencies, AutoInstallerState installerState) {
    return ListView.builder(
      itemCount: dependencies.length,
      itemBuilder: (context, index) {
        final dep = dependencies[index];
        return _DependencyTile(
          dependency: dep,
          isInstalling: installerState.isInstalling,
          installationResult: installerState.installationResults[dep.tool],
        );
      },
    );
  }

  Widget _buildProgressWidget(InstallationProgress progress) {
    if (progress.percentage == 0 && progress.status.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  progress.error != null
                      ? Icons.error
                      : progress.isComplete
                          ? Icons.check_circle
                          : Icons.download,
                  color: progress.error != null
                      ? Colors.red
                      : progress.isComplete
                          ? Colors.green
                          : Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${progress.toolName}: ${progress.status}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (progress.currentStep != null) ...[
              const SizedBox(height: 4),
              Text(progress.currentStep!, style: TextStyle(color: Colors.grey[600])),
            ],
            if (progress.error != null) ...[
              const SizedBox(height: 4),
              Text(
                progress.error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
            if (!progress.isComplete && progress.error == null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress.percentage / 100),
              const SizedBox(height: 4),
              Text('${progress.percentage.toStringAsFixed(1)}%'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text('Error loading dependencies: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(autoInstallerControllerProvider.notifier).refreshDependencies(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _DependencyTile extends ConsumerWidget {
  const _DependencyTile({
    required this.dependency,
    required this.isInstalling,
    this.installationResult,
  });

  final DependencyInfo dependency;
  final bool isInstalling;
  final bool? installationResult;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: _buildStatusIcon(theme),
        title: Text(dependency.tool.command),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dependency.tool.description),
            if (dependency.version != null)
              Text(
                'Version: ${dependency.version}',
                style: TextStyle(color: Colors.green[600], fontSize: 12),
              ),
            if (dependency.suggestedMethod != null)
              Text(
                'Install via: ${dependency.suggestedMethod!.displayName}',
                style: TextStyle(color: Colors.blue[600], fontSize: 12),
              ),
          ],
        ),
        trailing: _buildActionButton(context, ref),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme) {
    if (installationResult == true) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if (installationResult == false) {
      return const Icon(Icons.error, color: Colors.red);
    } else if (dependency.isInstalled) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else {
      return Icon(Icons.download, color: theme.colorScheme.primary);
    }
  }

  Widget? _buildActionButton(BuildContext context, WidgetRef ref) {
    if (dependency.isInstalled && installationResult != false) {
      return null;
    }

    return FilledButton.tonal(
      onPressed: isInstalling
          ? null
          : () => ref.read(autoInstallerControllerProvider.notifier).installTool(dependency.tool),
      child: isInstalling
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Install'),
    );
  }
}

class DependencyStatusBanner extends ConsumerWidget {
  const DependencyStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dependencies = ref.watch(dependenciesStatusProvider);
    
    return dependencies.when(
      data: (deps) {
        final missing = deps.where((dep) => !dep.isInstalled).toList();
        if (missing.isEmpty) return const SizedBox.shrink();
        
        return Card(
          color: Colors.orange.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${missing.length} tools need installation',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      Text(
                        'Missing: ${missing.map((d) => d.tool.command).join(', ')}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => _showInstallationDialog(context),
                  icon: const Icon(Icons.build),
                  label: const Text('Install'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showInstallationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const DependencyInstallationDialog(),
    );
  }
}

class QuickInstallButton extends ConsumerWidget {
  const QuickInstallButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dependencies = ref.watch(dependenciesStatusProvider);
    final installerState = ref.watch(autoInstallerControllerProvider);
    
    return dependencies.when(
      data: (deps) {
        final missing = deps.where((dep) => !dep.isInstalled).toList();
        if (missing.isEmpty) {
          return FilledButton.icon(
            onPressed: null,
            icon: const Icon(Icons.check),
            label: const Text('All tools installed'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          );
        }
        
        return FilledButton.icon(
          onPressed: installerState.isInstalling
              ? null
              : () => ref.read(autoInstallerControllerProvider.notifier).installAllMissing(),
          icon: installerState.isInstalling
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.download),
          label: Text(
            installerState.isInstalling 
                ? 'Installing...' 
                : 'Auto-install ${missing.length} tools',
          ),
        );
      },
      loading: () => FilledButton.icon(
        onPressed: null,
        icon: const CircularProgressIndicator(strokeWidth: 2),
        label: const Text('Checking...'),
      ),
      error: (_, __) => FilledButton.icon(
        onPressed: () => ref.read(autoInstallerControllerProvider.notifier).refreshDependencies(),
        icon: const Icon(Icons.refresh),
        label: const Text('Retry check'),
      ),
    );
  }
}