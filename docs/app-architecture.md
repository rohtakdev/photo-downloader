# Application Architecture

## Overview
The app is a macOS SwiftUI download manager that accepts bulk iCloud Data Export URLs and manages large, resumable downloads with persistent state.

## Components

### UI Layer (SwiftUI)
- Main table view with per-item stats and status.
- Dashboard for overall progress and aggregate metrics.
- Settings screen for defaults and limits.

### Domain Layer
- DownloadItem model: URL, filename, size, destination, status, progress, retries.
- DownloadStatus state machine: queued, downloading, paused, failed, expired, complete.
- Settings model: download folder, max parallelism, retries, throttle.

### Download Engine
- Queue controller to enforce concurrency.
- URLSession with delegate for streaming to disk and progress updates.
- Resume support via HTTP Range and existing file size.
- Retry controller with exponential backoff and terminal failure logic.

### Persistence
- **Core Data** for storing items, settings, and task state.
  - Rationale: Native macOS framework, excellent SwiftUI integration via `@FetchRequest`, built-in migration support, and mature tooling.
  - Alternative considered: GRDB (lighter weight, but requires more manual SwiftUI integration).
- Frequent state writes on transitions and progress checkpoints.
- Migration strategy to support schema evolution.
- Core Data stack: `NSPersistentContainer` with SQLite store.

### Integration Points
- URL intake pipeline for paste, file import, and optional HTML parsing.
- File system writes to default or per-item destination.

## Data Flow

### Download Lifecycle
1. User imports URLs or pastes them into the intake UI.
2. Items are validated, normalized, and stored in Core Data.
3. Download engine queries Core Data for queued items, starts tasks, and updates progress.
4. UI observes Core Data changes via `@FetchRequest` and renders updates.
5. On restart, engine queries Core Data for queued/downloading items and resumes if possible.

### Component Interactions
- **UI → Domain**: User actions trigger state changes through view models.
- **Domain → Persistence**: State changes are persisted to Core Data immediately.
- **Download Engine → Persistence**: Progress updates and status changes are written to Core Data.
- **Persistence → UI**: Core Data changes trigger SwiftUI view updates automatically.
- **Download Engine → Domain**: Status transitions update domain models, which persist to Core Data.

## Error Handling

### Error Types and Handling Strategy
- **401/403 (Expired Token)**: 
  - Mark item status as `expired`
  - Stop retry attempts
  - Prompt user for updated URL
  - Store error message in `DownloadItem.errorMessage`
  
- **Network Failures** (timeouts, connection refused, DNS errors):
  - Retry with exponential backoff
  - Increment `retryCount` on each attempt
  - After max retries, mark as `failed` and pause
  - Store last error in `DownloadItem.errorMessage`
  
- **File Integrity Issues** (size mismatch, checksum failure):
  - Mark as `failed`
  - Allow user-initiated retry
  - Clear partial file if integrity check fails
  
- **File System Errors** (permission denied, disk full):
  - Mark as `failed` immediately
  - Store descriptive error message
  - Require user intervention (change destination or fix permissions)

### Error Propagation
- Errors are captured in download delegate callbacks
- Errors update domain model state
- State changes trigger Core Data persistence
- UI observes state changes and displays appropriate messages

## Concurrency and Performance

### Concurrency Management
- **Queue Controller**: Enforces maximum concurrent downloads (default: 2-3, configurable)
- **Thread Safety**: 
  - Core Data operations on main queue or dedicated context
  - URLSession delegate callbacks may occur on background queues
  - State updates must be synchronized to main queue for UI updates
- **Queue State**: Maintained in memory with periodic persistence to Core Data

### Performance Optimizations
- **Streaming**: URLSession streams directly to disk via file URL destination
- **Memory Management**: Avoid buffering large files in memory
- **Progress Updates**: Throttle UI updates to 2-4 updates per second per item
- **Bandwidth Throttling**: Optional speed limit (configurable in settings)
- **Batch Operations**: Batch Core Data saves to reduce I/O overhead

### State Synchronization
- Download engine maintains active task references
- Core Data serves as source of truth for persistent state
- On app launch, engine reconciles active tasks with Core Data state
- Background queue operations update Core Data, which triggers UI updates via `@FetchRequest`
