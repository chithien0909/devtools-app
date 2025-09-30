import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/models/developer_tool.dart';
import 'ui/screens/home_shell.dart';
import 'viewmodels/theme_view_model.dart';
import 'viewmodels/tool_selector_view_model.dart';

class DevToolsApp extends StatelessWidget {
  const DevToolsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ToolSelectorViewModel(DeveloperToolCatalog.build()),
        ),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeViewModel, _) {
          return MaterialApp(
            title: 'DevTools+',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeViewModel.mode,
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
