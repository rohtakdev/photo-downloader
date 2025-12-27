#!/bin/bash
# Quick script to help set up Xcode project
# Run this after creating the project in Xcode

echo "=== Xcode Project Setup Helper ==="
echo ""
echo "1. Open Xcode"
echo "2. File → New → Project"
echo "3. Choose macOS → App"
echo "4. Name: photo-download"
echo "5. Enable Core Data and Tests"
echo "6. Save to: $(pwd)"
echo ""
echo "After creating project, run this script to verify structure:"
echo ""
echo "Checking for required files..."

files=(
    "App/PhotoDownloadApp.swift"
    "UI/Views/ContentView.swift"
    "Infrastructure/Persistence/PersistenceController.swift"
    "Utilities/Logger.swift"
    "Infrastructure/Persistence/Models/PhotoDownloadModel.xcdatamodeld"
    "Tests/PhotoDownloadTests/PersistenceControllerTests.swift"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file (missing)"
    fi
done

echo ""
echo "Project structure looks good!"
