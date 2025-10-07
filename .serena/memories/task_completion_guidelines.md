# Task Completion Guidelines

## Before Completing Any Task

### Code Quality Checks
1. **Run Analysis**: `flutter analyze` - Fix all warnings and errors
2. **Format Code**: `dart format .` - Ensure consistent formatting
3. **Run Tests**: `flutter test` - Verify all tests pass
4. **Check Dependencies**: `flutter pub outdated` - Update if needed

### Code Review Checklist
- [ ] Follows project naming conventions (snake_case files, PascalCase classes)
- [ ] Uses proper import organization (dart → flutter → packages → local)
- [ ] Implements error handling for user inputs
- [ ] Uses Material Design 3 theming consistently
- [ ] Follows modular architecture (separate service files for business logic)
- [ ] No unnecessary comments in source code
- [ ] Responsive design using LayoutBuilder where appropriate

### Testing Requirements
- [ ] Unit tests for service classes (business logic)
- [ ] Widget tests for complex UI components
- [ ] Integration tests for critical user flows
- [ ] Test coverage maintained or improved

### Platform Compatibility
- [ ] Verify tool works on target platforms (Windows/macOS/Linux/Web)
- [ ] Check platform-specific tool availability in ToolRegistry
- [ ] Test desktop-only features (file picker, FFmpeg, etc.)

## After Completing Task

### Final Verification
1. **Build Test**: `flutter build windows` (or target platform)
2. **Run App**: `flutter run` - Test the new feature manually
3. **Clean Build**: `flutter clean && flutter pub get` - Ensure clean state

### Documentation Updates
- [ ] Update README.md if adding new tools or features
- [ ] Add tool documentation in docs/ directory if needed
- [ ] Update tool registry with proper keywords and descriptions

### Git Workflow
- [ ] Commit with descriptive message
- [ ] Push changes to repository
- [ ] Create pull request if working on feature branch

## Common Issues to Avoid
- Don't hardcode platform-specific paths
- Don't forget to handle null safety properly
- Don't skip error handling for file operations
- Don't forget to update ToolRegistry for new tools
- Don't break existing functionality when adding features

## Performance Considerations
- Use IsolateExecutor for CPU-intensive operations
- Implement proper loading states for async operations
- Avoid blocking the UI thread
- Use efficient data structures for large datasets