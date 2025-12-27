# Test Troubleshooting Guide

## Common Test Failures and Fixes

### 1. "Cannot find 'PersistenceController' in scope"
**Problem**: PersistenceController not accessible to tests
**Fix**: 
- Make sure `PersistenceController.swift` is added to the main app target
- Check File Inspector → Target Membership → `photo-download` is checked

### 2. "Cannot find type 'DownloadItemEntity' in scope"
**Problem**: Core Data entities not generated
**Fix**:
- Build the project first: `Cmd+B`
- Check that `PhotoDownloadModel.xcdatamodeld` is in the app target
- Verify Codegen is set to "Class Definition" for both entities
- Clean build folder: `Shift+Cmd+K`, then build again

### 3. "No such module 'photo_download'"
**Problem**: Module name mismatch
**Fix**:
- Check your Bundle Identifier in project settings
- Module name should match (might be `photo_download` or `photo-download`)
- Update `@testable import` in test files to match

### 4. "Core Data store failed to load"
**Problem**: Model name mismatch
**Fix**:
- Check `PersistenceController.swift` uses `"PhotoDownloadModel"`
- Verify `.xcdatamodeld` file is named `PhotoDownloadModel.xcdatamodeld`

### 5. Tests don't appear in Test Navigator
**Problem**: Test files not in test target
**Fix**:
- Check File Inspector for each test file
- Target Membership → `photo-downloadTests` should be checked
- `photo-download` target should be unchecked for test files

### 6. "Use of unresolved identifier"
**Problem**: Missing imports or files not in target
**Fix**:
- Make sure all source files are in the app target
- Check imports are correct
- Build the main app target first (`Cmd+B`)

## Quick Fixes Checklist

1. **Build the main app target first**: `Cmd+B`
2. **Clean build folder**: `Shift+Cmd+K`, then `Cmd+B`
3. **Verify target memberships**:
   - Source files → `photo-download` target ✅
   - Test files → `photo-downloadTests` target ✅
4. **Check Core Data model**:
   - Model file in app target ✅
   - Codegen set to "Class Definition" ✅
5. **Verify imports**:
   - Test files have `@testable import photo_download` ✅

## Getting Error Details

In Xcode:
1. Open Test Navigator (`Cmd+6`)
2. Click on failed test
3. Check error message in Issue Navigator (`Cmd+5`)
4. Look at console output for detailed errors

