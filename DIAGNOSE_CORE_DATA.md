# Core Data Model Diagnostic

## The Problem
Tests are crashing with `fatalError` in `PersistenceController` because Core Data can't find the model file.

## Most Common Causes

### 1. Model File Not in Target ✅ **CHECK THIS FIRST**
The `PhotoDownloadModel.xcdatamodeld` file must be added to the **app target** (`photo-download`), NOT the test target.

**To Fix:**
1. In Xcode, select `PhotoDownloadModel.xcdatamodeld` in the Project Navigator
2. Open File Inspector (right panel, first tab)
3. Under "Target Membership", make sure:
   - ✅ `photo-download` is **checked**
   - ❌ `photo-downloadTests` is **unchecked**

### 2. Model Name Mismatch
The code uses `"PhotoDownloadModel"` - verify the `.xcdatamodeld` file is named exactly:
- ✅ `PhotoDownloadModel.xcdatamodeld`
- ❌ NOT `PhotoDownloadModel.xcdatamodel` (missing 'd')
- ❌ NOT `PhotoDownload.xcdatamodeld`

### 3. Model File Not Compiled
The model file needs to be compiled into the app bundle.

**To Fix:**
1. Build the main app target: `Cmd+B`
2. Check for build errors
3. Clean build folder: `Shift+Cmd+K`, then build again

## How to See the Actual Error

The error message will tell us exactly what's wrong. To see it:

1. **In Xcode Console:**
   - Run tests: `Cmd+U`
   - Look at the bottom console panel
   - The error will show something like:
     - `"The model used to open the store is incompatible"`
     - `"Cannot find model named 'PhotoDownloadModel'"`
     - `"The model used to open the store is incompatible"`

2. **From Command Line:**
   ```bash
   cd photo-download
   xcodebuild test -scheme photo-download -destination 'platform=macOS' 2>&1 | grep -i "error\|model\|core data"
   ```

## Quick Fix Checklist

- [ ] Model file is in app target (not test target)
- [ ] Model file name matches exactly: `PhotoDownloadModel.xcdatamodeld`
- [ ] Main app target builds successfully (`Cmd+B`)
- [ ] Check Xcode console for actual error message

## Next Steps

Once you see the actual error message, we can fix it. The most likely issue is **#1 - Model File Not in Target**.

