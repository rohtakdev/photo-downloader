# Application Architecture

## Overview
The app is a macOS SwiftUI download manager that accepts bulk iCloud Data Export URLs and manages large, resumable downloads with persistent state. The architecture follows **Clean Architecture principles** with clear layer separation and dependency inversion.

## Architecture Style
- **Pattern**: Clean Architecture with MVVM
- **Layers**: UI → Application → Domain → Infrastructure
- **Dependency Rule**: Dependencies point inward toward Domain layer
- **State Management**: Core Data as single source of truth

## Components

### UI Layer (SwiftUI)
- **Views**: SwiftUI views for table, dashboard, settings
- **ViewModels**: Observable view models that coordinate with Application services
  - Transform domain models for UI presentation
  - Handle user actions and delegate to services
  - Observe state changes via Combine publishers or Core Data
  - Responsibilities:
    - Format data for display (sizes, speeds, ETAs)
    - Handle user interactions (start, pause, retry)
    - Coordinate with Application services
    - Manage UI-specific state

### Application/Service Layer
Orchestrates business operations and coordinates between UI, Domain, and Infrastructure.

- **DownloadService**: 
  - Orchestrates download lifecycle
  - Manages queue and concurrency
  - Coordinates between Domain logic and Infrastructure
  - Handles download scheduling and state transitions
  
- **URLImportService**:
  - Handles URL input (paste, file import, HTML parsing)
  - Validates URLs using Domain validators
  - Creates domain models
  - Persists via Repository
  
- **SettingsService**:
  - Manages application settings
  - Validates setting values
  - Persists settings via Repository
  
- **ErrorHandler**:
  - Classifies errors (retryable vs terminal)
  - Transforms technical errors to user-friendly messages
  - Routes errors to appropriate handlers
  - Coordinates error logging
  
- **IntelligentDownloadAgent**:
  - Monitors download progress and performance metrics
  - Analyzes error patterns and diagnoses root causes
  - Generates action plans for issue resolution
  - Applies runtime fixes (adaptive retry, parameter adjustment)
  - Generates code fixes and creates PRs for code-level issues
  - Maintains knowledge base of learned patterns and fixes
  - Operates autonomously in background
  - Reduces debugging time through proactive issue detection

### Domain Layer
Pure business logic with no external dependencies. Defines interfaces that Infrastructure implements.

- **Domain Models** (Pure Swift structs/classes):
  - `DownloadItem`: URL, filename, size, destination, status, progress, retries
  - `DownloadStatus`: State machine enum (queued, downloading, paused, failed, expired, complete)
  - Business rules and validation logic
  
- **State Machine**:
  - `DownloadStatus` transitions with validation
  - Pure state machine (no side effects)
  - State transitions emit events for Application layer to handle
  
- **Repository Protocols** (Interfaces):
  - `DownloadItemRepository`: Protocol defining persistence operations
  - `SettingsRepository`: Protocol for settings persistence
  - Implemented by Infrastructure layer
  
- **Business Rules**:
  - Retry logic and backoff calculations
  - Queue management rules
  - Concurrency limits
  - Validation rules

### Infrastructure Layer
Implements Domain interfaces and handles external concerns.

- **Persistence**:
  - **Core Data Entities**: `DownloadItemEntity`, `SettingsEntity` (Core Data managed objects)
  - **Repository Implementations**: 
    - `CoreDataDownloadItemRepository`: Implements `DownloadItemRepository` protocol
    - `CoreDataSettingsRepository`: Implements `SettingsRepository` protocol
  - **Mapping**: Converts between Domain models and Core Data entities
  - Core Data stack: `NSPersistentContainer` with SQLite store
  - Migration strategy to support schema evolution
  
- **Network**:
  - **URLSession Wrapper**: Abstracts URLSession for download operations
  - **Download Task Manager**: Manages URLSession download tasks
  - **Resume Support**: HTTP Range header handling
  - **Progress Tracking**: Delegate callbacks for progress updates
  
- **File System**:
  - File writing operations
  - Path validation
  - Permission checking
  - Partial file detection and management

### Utilities
Shared utilities used across layers.

- **Parsers**: URL parsing, HTML table parsing
- **Formatters**: Size, speed, ETA formatting
- **Validators**: URL validation, path validation

## Data Flow

### Download Lifecycle
1. User imports URLs or pastes them into the intake UI
2. ViewModel delegates to `URLImportService`
3. Service validates URLs using Domain validators
4. Service creates `DownloadItem` domain models
5. Service persists via `DownloadItemRepository` (implemented by Core Data repository)
6. Repository maps domain model to Core Data entity and saves
7. `DownloadService` queries repository for queued items
8. Service orchestrates download start via Network layer
9. Network layer updates progress via delegate callbacks
10. Service updates domain model and persists via repository
11. Core Data changes trigger UI updates (via `@FetchRequest` or Combine publishers)
12. On restart, service queries repository for queued/downloading items and resumes

### Component Interactions
- **UI → Application**: ViewModels call Application services
- **Application → Domain**: Services use domain models and business rules
- **Application → Infrastructure**: Services use repository interfaces (protocols)
- **Infrastructure → Domain**: Infrastructure implements Domain protocols
- **Domain → (nothing)**: Domain has no dependencies (pure business logic)

### State Management
- **Single Source of Truth**: Core Data is the only persistent state store
- **Download Engine**: Stateless - queries Core Data for current state, updates Core Data with changes
- **No In-Memory State**: Engine does not maintain separate task references
- **State Reconciliation**: On app launch, service queries Core Data and reconciles any inconsistencies
- **UI Updates**: Core Data changes propagate to UI via `@FetchRequest` or Combine publishers

## Error Handling

### Error Infrastructure
- **Error Types** (Domain Layer):
  - `DownloadError` enum with cases: expired, network, fileSystem, integrity, permission
  - Pure domain types with no external dependencies
  
- **ErrorHandler** (Application Layer):
  - Classifies errors: retryable vs terminal
  - Transforms domain errors to user-friendly messages
  - Determines retry strategy
  - Coordinates error logging

### Error Types and Handling Strategy
- **401/403 (Expired Token)**: 
  - Detected by Network layer
  - Classified as terminal error by ErrorHandler
  - Domain model status set to `expired`
  - No retry attempts
  - User prompted for updated URL
  - Error message stored in domain model
  
- **Network Failures** (timeouts, connection refused, DNS errors):
  - Classified as retryable by ErrorHandler
  - Retry with exponential backoff (Domain business rule)
  - `retryCount` incremented in domain model
  - After max retries, classified as terminal, status set to `failed`
  - Error message stored
  
- **File Integrity Issues** (size mismatch, checksum failure):
  - Classified as terminal by ErrorHandler
  - Status set to `failed`
  - Allow user-initiated retry
  - Partial file cleared if integrity check fails
  
- **File System Errors** (permission denied, disk full):
  - Classified as terminal immediately
  - Status set to `failed`
  - Descriptive error message stored
  - Requires user intervention

### Error Propagation
1. Error occurs in Infrastructure layer (Network, File System)
2. Error transformed to Domain error type
3. ErrorHandler classifies and determines handling
4. Domain model updated with error state
5. State persisted via Repository
6. UI observes state change and displays appropriate message

## Concurrency and Performance

### Concurrency Management
- **Queue Controller** (Domain business logic):
  - Enforces maximum concurrent downloads (default: 2-3, configurable)
  - Business rule implemented in Domain layer
  - Applied by Application service
  
- **Thread Safety**: 
  - Core Data: Main context for UI, background context for operations
  - URLSession delegate callbacks: May occur on background queues
  - State updates: Synchronized to main queue for UI updates
  - Repository operations: Thread-safe via Core Data contexts
  
- **Concurrency Model**:
  - Use Swift actors or serial queues for queue controller state
  - Core Data contexts: One per thread/queue
  - Pass object IDs between queues, not managed objects

### Performance Optimizations
- **Streaming**: URLSession streams directly to disk via file URL destination
- **Memory Management**: Avoid buffering large files in memory
- **Progress Updates**: Throttle UI updates to 2-4 updates per second per item
- **Bandwidth Throttling**: Optional speed limit (configurable in settings)
- **Batch Operations**: Batch Core Data saves to reduce I/O overhead
- **Lazy Loading**: Load domain models from Core Data only when needed

### State Synchronization
- **Single Source of Truth**: Core Data only
- **Stateless Engine**: Download service queries Core Data for current state
- **No Reconciliation Needed**: No separate in-memory state to reconcile
- **On App Launch**: Service queries Core Data for queued/downloading items and resumes
- **UI Updates**: Core Data changes trigger UI updates via `@FetchRequest` or Combine publishers

## Repository Pattern

### Purpose
- Abstracts persistence implementation from Domain and Application layers
- Enables testing with mock repositories
- Allows swapping persistence implementation if needed

### Implementation
- **Domain Layer**: Defines `DownloadItemRepository` and `SettingsRepository` protocols
- **Infrastructure Layer**: Implements protocols with `CoreDataDownloadItemRepository` and `CoreDataSettingsRepository`
- **Application Layer**: Uses repository protocols (dependency inversion)

### Repository Operations
- `save(_ item: DownloadItem) async throws`
- `fetchAll() async throws -> [DownloadItem]`
- `fetch(by id: UUID) async throws -> DownloadItem?`
- `update(_ item: DownloadItem) async throws`
- `delete(_ item: DownloadItem) async throws`
- `fetchQueued() async throws -> [DownloadItem]`
- `fetchDownloading() async throws -> [DownloadItem]`

## Input Pipeline Architecture

### URL Import Flow
1. **UI**: User pastes URLs or imports file
2. **ViewModel**: Receives input, delegates to `URLImportService`
3. **URLImportService**: 
   - Uses `URLParser` (Utility) to parse input
   - Uses `URLValidator` (Domain) to validate
   - Creates `DownloadItem` domain models
   - Persists via `DownloadItemRepository`
4. **Repository**: Maps to Core Data entity and saves
5. **Service**: Notifies `DownloadService` of new items
6. **UI**: Updates via Core Data observation

### Components
- **URLParser** (Utility): Parses newline/comma/CSV/HTML input
- **URLValidator** (Domain): Validates host, parameters, format
- **URLImportService** (Application): Orchestrates parsing, validation, creation, persistence

## Testing Architecture

### Unit Tests
- **Domain Layer**: Pure Swift, no dependencies - easy to test
- **Business Rules**: Test state machine, retry logic, validation
- **Mock Repositories**: Test Application services with mock implementations

### Integration Tests
- **Application Services**: Test with real repository implementations
- **Repository Implementations**: Test Core Data operations
- **Network Layer**: Test with mock URLSession

### UI Tests
- **ViewModels**: Test with mock services
- **Views**: Test UI behavior with mock data
