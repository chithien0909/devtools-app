# Code Style and Conventions

## Dart/Flutter Standards
- **Linting**: Uses `flutter_lints` package (flutter.yaml) with Flutter's recommended rules
- **Analysis**: Configured via `analysis_options.yaml`
- **Code Generation**: Uses `build_runner` with `freezed` and `json_serializable`

## Naming Conventions
- **Files**: snake_case (e.g., `base64_screen.dart`, `tool_model.dart`)
- **Classes**: PascalCase (e.g., `Base64Screen`, `ToolModel`)
- **Variables/Methods**: camelCase (e.g., `_inputController`, `buildCommandPreview`)
- **Constants**: camelCase for private, PascalCase for public
- **Enums**: PascalCase (e.g., `ToolCategory`, `AppSection`)

## Code Organization
- **Widgets**: StatefulWidget for interactive screens, StatelessWidget for static content
- **Services**: Separate service classes for business logic (e.g., `Base64Service`, `FfmpegService`)
- **Providers**: Riverpod providers for state management with descriptive names
- **Models**: Data classes with proper serialization support

## Import Organization
1. Dart SDK imports
2. Flutter imports
3. Third-party package imports
4. Local project imports (core, models, providers, services, tools)

## Widget Patterns
- **LayoutBuilder**: Used for responsive design in tool screens
- **SafeArea**: Wrapped around main content for proper padding
- **Material**: Used as root widget for tool screens
- **Theme.of(context)**: Consistent theming throughout

## Error Handling
- Try-catch blocks for user input validation
- Graceful error messages displayed to users
- Service layer handles technical errors, UI layer handles user feedback

## Documentation
- No comments in source code by default (per user rules)
- Self-documenting code with descriptive names
- README files in docs/ directory for tool-specific documentation