# Photo Download Manager

A macOS download manager application designed to handle bulk downloads from Apple's iCloud Data Export service. The application manages large file downloads (30-50GB per file) with support for resumable downloads, concurrent processing, and persistent state management.

## Architecture

This project follows **Clean Architecture** principles with clear layer separation:

- **UI Layer**: SwiftUI views and ViewModels
- **Application Layer**: Services that orchestrate business operations
- **Domain Layer**: Pure business logic with no external dependencies
- **Infrastructure Layer**: Core Data persistence, URLSession networking, file system operations

See `docs/app-architecture.md` for detailed architecture documentation.

## Project Structure

```
photo-download/
├── App/                    # SwiftUI app entry and scene setup
├── UI/                      # UI Layer (Views, ViewModels)
├── Application/            # Application/Service Layer
├── Domain/                 # Domain Layer (Pure business logic)
├── Infrastructure/         # Infrastructure Layer (Core Data, Network, FileSystem)
└── Utilities/             # Shared utilities (Parsers, Formatters, Logging)
```

## Requirements

- macOS 13.0+ (Ventura or later)
- Xcode 15.0 or later
- Swift 5.9+

## Setup

1. Open the project in Xcode
2. Configure code signing
3. Ensure App Sandbox entitlements are configured (see `photo-download.entitlements`)
4. Build and run

## Documentation

All documentation is in the `docs/` directory:

- `README.md` - Documentation overview
- `app-spec.md` - Application specification and requirements
- `app-architecture.md` - Architecture details
- `developer-guide.md` - Development setup and guidelines
- `project-plan.md` - Phased development plan
- `test-plan.md` - Testing strategy and test cases

## Development Status

**Current Phase**: Phase 1 - Foundations ✅

- [x] Project structure created
- [x] Core Data model defined
- [x] Persistence stack initialized
- [x] Logging infrastructure set up
- [x] App Sandbox configured

## License

Copyright © 2024. All rights reserved.

