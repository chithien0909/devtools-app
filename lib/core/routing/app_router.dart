import 'package:devtools_plus/core/registry/tool_registry.dart';
import 'package:devtools_plus/screens/home_screen.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/tool/:id',
      builder: (context, state) {
        final toolId = state.pathParameters['id'];
        final tool = ToolRegistry.findById(toolId ?? '');
        
        if (tool == null) {
          return const HomeScreen();
        }
        
        return HomeScreen(initialToolId: toolId);
      },
    ),
  ],
  errorBuilder: (context, state) => const HomeScreen(),
);
