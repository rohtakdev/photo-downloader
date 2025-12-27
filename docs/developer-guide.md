# Developer Guide

## Project Structure
```
photo-download/
├── App/              # SwiftUI app entry and scene setup
├── UI/               # Views, view models, table components
│   ├── Views/        # SwiftUI views
│   └── ViewModels/   # Observable view models
├── Domain/           # Models and state machine
│   ├── Models/       # DownloadItem, Settings, etc.
│   └── StateMachine/ # DownloadStatus state machine
├── Download/         # Queue, URLSession delegates, retry logic
│   ├── Queue/        # Download queue controller
│   ├── Engine/       # URLSession management
│   └── Retry/        # Retry logic and backoff
├── Persistence/      # Core Data models and migrations
│   ├── Models/       # Core Data entity definitions (.xcdatamodeld)
│   └── Migrations/   # Schema migration logic
└── Utilities/        # Parsing, formatting, file utilities
    ├── Parsers/      # URL parsing, HTML parsing
    └── Formatters/   # Size, speed, ETA formatting
```

## Setup

### Prerequisites
- **macOS**: 13.0+ (Ventura or later)
- **Xcode**: 15.0 or later
- **Swift**: 5.9+ (comes with Xcode 15+)

### Initial Setup Steps

1. **Clone and Open Project**
   ```bash
   git clone <repository-url>
   cd photo-download
   open photo-download.xcodeproj
   ```

2. **Configure Xcode Project**
   - Set deployment target to macOS 13.0
   - Configure code signing (required for file system access)
   - Set up App Sandbox entitlements (see below)

3. **App Sandbox Configuration**
   - Enable App Sandbox in Capabilities
   - Required entitlements:
     - **User Selected File**: Read/Write (for download folder selection)
     - **Network**: Outgoing Connections (for downloads)
   - Add to `Info.plist` or entitlements file:
     ```xml
     <key>com.apple.security.app-sandbox</key>
     <true/>
     <key>com.apple.security.files.user-selected.read-write</key>
     <true/>
     ```

4. **Core Data Setup**
   - Create Core Data model file (`.xcdatamodeld`)
   - Define entities: `DownloadItem`, `Settings`
   - Configure `NSPersistentContainer` in app initialization

### Dependencies

**No External Dependencies Required**
- Uses only Apple frameworks:
  - SwiftUI (UI)
  - Foundation (networking, file system)
  - Core Data (persistence)
  - Combine (reactive programming, if needed)

**Optional Future Dependencies** (if needed):
- None currently planned

### Build Configuration

1. **Build Settings**
   - Swift Language Version: Swift 5.9
   - Deployment Target: macOS 13.0
   - Code Signing: Automatic or manual (for distribution)

2. **Run Configuration**
   - Scheme: `photo-download` (Debug)
   - Build Configuration: Debug for development

### First Run Checklist
- [ ] Project builds without errors
- [ ] App launches successfully
- [ ] Core Data stack initializes
- [ ] File system access permissions work
- [ ] Can create test download items

## Development Workflow

### Code Organization Principles
- **Separation of Concerns**: Keep download engine and persistence decoupled from UI for testability
- **Dependency Injection**: Pass dependencies (e.g., Core Data context) rather than accessing singletons
- **Single Responsibility**: Each component should have one clear purpose

### Best Practices
- **Streaming**: Prefer streaming writes to disk; avoid buffering large files in memory
- **State Persistence**: Store progress and state on transitions to survive crashes
- **Error Handling**: Always handle errors explicitly; don't silently fail
- **Thread Safety**: Ensure Core Data operations happen on correct queue (main or background context)

### Development Cycle
1. **Feature Development**
   - Create feature branch from `main`
   - Implement following architecture patterns
   - Write unit tests for business logic
   - Test manually with sample URLs

2. **Testing**
   - Run unit tests: `Cmd+U` in Xcode
   - Test with small files first
   - Test resume functionality
   - Test error scenarios

3. **Code Review Checklist**
   - [ ] Follows project structure
   - [ ] No memory leaks (check with Instruments)
   - [ ] Error handling is comprehensive
   - [ ] State changes are persisted
   - [ ] UI updates are on main thread

### Git Workflow
- **Branching**: Feature branches from `main`
- **Commits**: Clear, descriptive commit messages
- **Pull Requests**: Required before merging to `main`
- **Commit Message Format**:
  ```
  <type>: <description>
  
  <detailed explanation if needed>
  ```
  Types: `feat`, `fix`, `docs`, `refactor`, `test`

## Conventions

### Code Style
- **Swift Style**: Follow Swift API Design Guidelines
- **Naming**: 
  - Types: PascalCase (`DownloadItem`, `DownloadStatus`)
  - Variables/Functions: camelCase (`downloadItem`, `startDownload()`)
  - Constants: camelCase or PascalCase for global constants
- **File Organization**: One main type per file, extensions in separate files if large

### Architecture Conventions
- **State Management**: Status updates should go through a single state machine
- **Observable Objects**: Use `@ObservableObject` for view models
- **Core Data**: Use `@FetchRequest` in views, `NSManagedObjectContext` in view models
- **Dependency Injection**: Pass dependencies through initializers

### Security Conventions
- **URL Handling**: Do not store secrets; URLs are short-lived but still sensitive
- **Logging**: Never log full URLs or tokens; log only identifiers
- **File Paths**: Always validate destination paths before writing
- **Sandboxing**: Respect App Sandbox restrictions; request permissions properly

### Error Handling Conventions
- Use Swift `Result` type for operations that can fail
- Provide descriptive error messages for users
- Log technical details for debugging
- Distinguish between retryable and terminal errors

## Logging and Diagnostics

### Logging Strategy
- **State Transitions**: Log all state transitions with item identifiers
- **HTTP Responses**: Capture HTTP status codes and response headers for failures
- **Errors**: Log errors with context (item ID, URL, error type)
- **Performance**: Log download speeds and timing for large files

### Logging Implementation
```swift
// Use os.log for structured logging
import os.log

private let logger = Logger(subsystem: "com.yourapp.photo-download", category: "DownloadEngine")

// Example usage
logger.info("Download started: \(item.id.uuidString)")
logger.error("Download failed: \(item.id.uuidString), error: \(error.localizedDescription)")
```

### Debug Tools
- **Debug Screen**: Provide a simple debug screen for current queue state
  - Show all active downloads
  - Display queue status
  - Show Core Data entity counts
  - Display recent errors

### Diagnostics Information
- **System Info**: macOS version, available disk space
- **Network Info**: Connection status, active downloads count
- **Performance Metrics**: Average download speed, queue wait times
- **Error History**: Recent errors with timestamps

### Debugging Tips
- Use Xcode's Network Link Conditioner to simulate slow/failing networks
- Test with Instruments (Allocations, Leaks, Time Profiler)
- Enable Core Data SQL debugging: `-com.apple.CoreData.SQLDebug 1`
- Check Console.app for system-level errors

## Common Pitfalls

### Range Header Issues
- **Problem**: Misaligned Range logic when existing file size doesn't match server response
- **Solution**: 
  - Always verify existing file size before resuming
  - Handle 416 (Range Not Satisfiable) responses
  - Validate server supports Range requests (Accept-Ranges header)
  - If mismatch, delete partial file and restart

### Concurrency Management
- **Problem**: Exceeding concurrency limits under rapid start/stop actions
- **Solution**:
  - Use atomic operations for queue state
  - Lock queue modifications
  - Validate limits before starting new downloads
  - Clean up cancelled tasks properly

### UI Performance
- **Problem**: UI lag due to excessive progress updates
- **Solution**: 
  - Throttle to 2-4 updates/sec per item
  - Use `DispatchQueue.main.async` for UI updates
  - Batch Core Data saves
  - Consider using `@Published` with debouncing

### Core Data Threading
- **Problem**: Accessing Core Data objects from wrong queue
- **Solution**:
  - Always access on correct context (main or background)
  - Use `perform` or `performAndWait` for background contexts
  - Pass object IDs between queues, not objects themselves

### Memory Management
- **Problem**: Memory spikes with large files
- **Solution**:
  - Use URLSession file destination (streams to disk)
  - Don't buffer file data in memory
  - Release task references when complete
  - Monitor with Instruments

### State Persistence
- **Problem**: State lost on crash or unexpected termination
- **Solution**:
  - Persist on every state transition
  - Use Core Data's automatic saving
  - Save progress at regular intervals (not every byte)
  - Validate state on app launch

## Updating Docs
- Update `docs/project-plan.md` when phases or milestones change.
- Update `docs/app-architecture.md` when components or data flow change.
- Update `docs/test-plan.md` when new test cases or tooling is added.
- Keep this guide aligned with folder structure and dev setup steps.
