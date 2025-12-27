# Installing Xcode

Xcode is required to build and test this macOS app. Here are your options:

## Option 1: Install Xcode from App Store (Recommended)

1. **Open App Store** on your Mac
2. **Search for "Xcode"**
3. **Click "Get" or "Install"** (it's free, but large ~15GB)
4. **Wait for download** (may take 30-60 minutes depending on internet)
5. **Open Xcode** after installation
6. **Accept license**: `sudo xcodebuild -license accept`
7. **Install additional components** when Xcode prompts you

## Option 2: Download from Apple Developer

1. Go to https://developer.apple.com/xcode/
2. Sign in with Apple ID
3. Download Xcode (requires free Apple Developer account)

## After Installation

Once Xcode is installed, you can:

1. **Open Xcode**: `open -a Xcode`
2. **Create the project** following `SETUP_XCODE_PROJECT.md`
3. **Run tests**: `Cmd+U` in Xcode

## Verify Installation

```bash
# Check if Xcode is installed
xcode-select -p

# Should show: /Applications/Xcode.app/Contents/Developer
# (Not: /Library/Developer/CommandLineTools)
```

## Alternative: Use Xcode Cloud or CI/CD

If you can't install Xcode locally, you could:
- Use GitHub Actions with macOS runner
- Use Xcode Cloud (requires Apple Developer account)
- Use a remote Mac with Xcode

## Current Status

- ✅ Swift compiler available (Swift 6.0.2)
- ✅ Command line tools installed
- ❌ Full Xcode IDE not installed
- ❌ Cannot run tests without Xcode project

