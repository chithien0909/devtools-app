import 'package:devtools_plus/core/app_theme.dart';
import 'package:devtools_plus/providers/tool_provider.dart';
import 'package:devtools_plus/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'DevTools+',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
