# Setting Up Xcode Project to Run Tests

## Prerequisites
- Xcode 15.0 or later installed
- macOS 13.0+ (Ventura or later)

## Step-by-Step Instructions

### 1. Open Xcode
```bash
open -a Xcode
```

### 2. Create New Project
1. In Xcode: **File → New → Project**
2. Select **macOS** tab
3. Choose **App** template
4. Click **Next**

### 3. Configure Project
- **Product Name**: `photo-download`
- **Team**: Select your development team (or leave as "None" for now)
- **Organization Identifier**: `com.yourcompany` (or your preferred identifier)
- **Bundle Identifier**: Will auto-generate as `com.yourcompany.photo-download`
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Storage**: **Core Data** ✅ (IMPORTANT: Check this box!)
- **Include Tests**: ✅ (IMPORTANT: Check this box!)

Click **Next**

### 4. Choose Location
- Navigate to `/Users/poorak/git/photo-download`
- **IMPORTANT**: Uncheck "Create Git repository" (we already have one)
- Click **Create**

### 5. Replace Default Files
Xcode will create some default files. You need to:

1. **Delete default files** Xcode created:
   - Delete `ContentView.swift` (we have our own)
   - Delete `photo_downloadApp.swift` (we have `PhotoDownloadApp.swift`)
   - Delete the default `.xcdatamodeld` if it doesn't match ours

2. **Add existing source files**:
   - Right-click on project in navigator
   - Select **Add Files to "photo-download"...**
   - Navigate to project root
   - Select these folders/files:
     - `App/` folder
     - `UI/` folder
     - `Application/` folder
     - `Domain/` folder
     - `Infrastructure/` folder
     - `Utilities/` folder
     - `Info.plist`
     - `photo-download.entitlements`
   - Check **"Copy items if needed"** (unchecked - we want references)
   - Check **"Create groups"** (not folder references)
   - Click **Add**

3. **Add Core Data Model**:
   - Right-click on `Infrastructure/Persistence/Models/` in Xcode
   - Select **Add Files to "photo-download"...**
   - Navigate to `Infrastructure/Persistence/Models/PhotoDownloadModel.xcdatamodeld`
   - Make sure **"Copy items if needed"** is unchecked
   - Click **Add**

### 6. Configure Test Target
1. **Add test files to test target**:
   - Right-click on project in navigator → **Add Files to "photo-download"...**
   - Navigate to `Tests/PhotoDownloadTests/`
   - Select all `.swift` files (4 files)
   - **Important**: Uncheck **"Copy items if needed"** (we want references, not copies)
   - In the dialog, make sure **"photo-downloadTests"** target is checked ✅
   - Make sure **"photo-download"** target is unchecked ❌ (tests should only be in test target)
   - Click **Add**

2. **Fix test imports**:
   - Open each test file
   - Find the comment: `// Note: @testable import will be added when Xcode project is created with proper module name`
   - Replace with: `@testable import photo_download`
   - (Use the actual module name - it might be `photo_download` or `photo-download` depending on Xcode)

### 7. Configure Build Settings
1. Select project in navigator
2. Select **photo-download** target
3. Go to **General** tab:
   - **Deployment Target**: macOS 13.0
   - **App Sandbox**: Enable in **Signing & Capabilities** tab
   - Add capabilities:
     - User Selected File (Read/Write)
     - Network (Outgoing Connections)

4. Go to **Build Settings**:
   - Search for "Swift Language Version": Set to **Swift 5.9**
   - Search for "Code Signing": Set as needed

### 8. Configure Core Data Model

**For the Model File:**
1. Select `PhotoDownloadModel.xcdatamodeld` in navigator
2. In File Inspector (right panel), make sure:
   - **Target Membership**: `photo-download` is checked ✅

**For Each Entity (DownloadItemEntity and SettingsEntity):**
1. In the Core Data model editor (center pane), click on **DownloadItemEntity**
2. In the Data Model Inspector (right panel, 4th icon - looks like a document with lines)
3. Look for **Codegen** dropdown (in the "Class" section)
4. Set to: **Class Definition** (or **Category/Extension**)
5. Repeat for **SettingsEntity**

### 9. Update PersistenceController
The `PersistenceController.swift` file references the model name. Verify it matches:
- Model name should be: `"PhotoDownloadModel"` (matches `.xcdatamodeld` name)

### 10. Run Tests
1. Select **photo-downloadTests** scheme (top toolbar)
2. Press **Cmd+U** to run all tests
   - Or: **Product → Test**
   - Or: Click the play button next to test class names

## Quick Test Command
Once project is set up, you can also run from terminal:
```bash
cd /Users/poorak/git/photo-download
xcodebuild test -scheme photo-download -destination 'platform=macOS'
```

## Troubleshooting

### "Cannot find 'PersistenceController' in scope"
- Make sure `PersistenceController.swift` is added to the main app target
- Check that the file is in the correct folder structure

### "Cannot find type 'DownloadItemEntity'"
- Make sure Core Data model is added to the target
- Build the project first (Cmd+B) to generate Core Data classes
- Check Codegen setting in model file inspector

### "No such module 'photo_download'"
- Check the actual module name in project settings
- Go to **Build Settings → Product Module Name**
- Use that exact name in `@testable import`

### Tests don't appear
- Make sure test files are added to the test target (not just the main target)
- Check **Target Membership** in File Inspector for each test file

## Verification Checklist
- [ ] Project builds without errors (Cmd+B)
- [ ] App runs (Cmd+R)
- [ ] All test files visible in Test Navigator (Cmd+6)
- [ ] Tests run successfully (Cmd+U)
- [ ] All 32 tests pass

## Expected Test Results
You should see:
- ✅ PersistenceControllerTests: 7 tests
- ✅ CoreDataEntityTests: 9 tests  
- ✅ LoggerTests: 11 tests
- ✅ Phase1FoundationTests: 5 tests
- **Total: 32 tests passing**

