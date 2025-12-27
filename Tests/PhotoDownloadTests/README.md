# Phase 1 Foundation Tests

This directory contains unit and integration tests for Phase 1 foundation components.

## Test Files

### PersistenceControllerTests.swift
Tests for Core Data persistence stack:
- Initialization (shared, preview, in-memory)
- Persistent store configuration
- View context setup
- Core Data stack validation

### CoreDataEntityTests.swift
Tests for Core Data entity definitions:
- DownloadItemEntity creation and attributes
- SettingsEntity creation and attributes
- Required fields validation
- Default values verification
- Context save operations

### LoggerTests.swift
Tests for logging infrastructure:
- Logger category initialization
- All logger categories exist (persistence, download, network, ui, application, error)
- Logging functionality (info, error, debug, warning)

### Phase1FoundationTests.swift
Integration tests for Phase 1 components:
- Complete foundation setup validation
- Core Data model loading
- Entity creation and persistence
- Logger integration with persistence operations

## Running Tests

### In Xcode
1. Select the test scheme
2. Press `Cmd+U` to run all tests
3. Or click the diamond icon next to individual test methods

### Command Line
```bash
# Run all tests
xcodebuild test -scheme photo-download -destination 'platform=macOS'

# Run specific test class
xcodebuild test -scheme photo-download -only-testing:PhotoDownloadTests/PersistenceControllerTests
```

## Test Coverage Goals

Phase 1 foundation components should have:
- ✅ 100% coverage for PersistenceController initialization
- ✅ 100% coverage for Core Data entity definitions
- ✅ 100% coverage for Logger category setup
- ✅ Integration tests for complete foundation setup

## Notes

- All tests use in-memory Core Data stores for isolation
- Tests are designed to run independently
- No external dependencies required
- Tests follow AAA pattern (Arrange, Act, Assert)

