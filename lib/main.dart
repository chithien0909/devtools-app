import 'package:devtools_plus/core/app_theme.dart';
import 'package:devtools_plus/core/routing/app_router.dart';
import 'package:devtools_plus/providers/tool_provider.dart';
import 'package:devtools_plus/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefsService = PreferencesService();
  await prefsService.init();
  
  runApp(
    ProviderScope(
      overrides: [
        preferencesServiceProvider.overrideWithValue(prefsService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'DevTools+',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
