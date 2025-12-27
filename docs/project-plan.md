# Project Plan (Phased)

## Phase Dependencies

```
Phase 0 (Discovery) ✅
    ↓
Phase 1 (Foundations) ✅ COMPLETE
    ↓
Phase 2 (Download Engine) ──┐
    ↓                        │
Phase 3 (Input/Parsing)      │
    ↓                        │
Phase 4 (UI/UX) ←────────────┘ (can start in parallel with Phase 2)
    ↓
Phase 5 (Persistence/Resume)
    ↓
Phase 6 (Settings/Polishing)
    ↓
Phase 7 (Testing/Release)
```

**Note**: Phase 4 (UI) can begin once Phase 1 (Foundations) is complete, as it can work with mock data initially.

## Progress Summary

**Last Updated**: December 2025

- ✅ **Phase 0**: Discovery and Requirements - Complete
- ✅ **Phase 1**: Foundations - Complete
- ⏳ **Phase 2**: Download Engine - Next
- ⏳ **Phase 3**: Input and Parsing - Pending
- ⏳ **Phase 4**: UI and UX - Pending
- ⏳ **Phase 5**: Persistence and Resume - Pending
- ⏳ **Phase 6**: Settings and Polishing - Pending
- ⏳ **Phase 7**: Testing and Release Prep - Pending

## Phase 0: Discovery and Requirements
**Duration**: 1-2 days  
**Dependencies**: None

### Tasks
- Confirm download sources, URL formats, and expiry patterns.
- Define supported input formats (paste, CSV/txt import, optional HTML table parse).
- Clarify expected macOS versions and distribution needs.
- Identify edge cases: partial files, network drops, expired tokens, file size checks.

### Deliverables
- Requirements document (app-spec.md)
- Architecture decision document
- Risk assessment

## Phase 1: Foundations ✅ **COMPLETE**
**Duration**: 3-5 days  
**Dependencies**: Phase 0  
**Status**: Completed

### Tasks
- ✅ Create macOS SwiftUI project structure.
- ✅ Define Core Data model for download items and settings.
- ✅ Set up Core Data stack (NSPersistentContainer).
- ✅ Establish logging and error reporting conventions.
- ✅ Configure App Sandbox entitlements.
- ✅ Set up project structure (folders, basic files).

### Deliverables
- ✅ Complete folder hierarchy following Clean Architecture
- ✅ Core Data model file (PhotoDownloadModel.xcdatamodeld) with DownloadItemEntity and SettingsEntity
- ✅ PersistenceController for Core Data stack management
- ✅ SwiftUI app entry point (PhotoDownloadApp.swift)
- ✅ Basic ContentView for initial UI
- ✅ Logging infrastructure (Logger.swift with category-based loggers)
- ✅ App Sandbox entitlements file (photo-download.entitlements)
- ✅ Info.plist with app metadata
- ✅ Project README.md
- ✅ .gitignore for Xcode projects

### Implementation Details
- **Project Structure**: All layers created (App, UI, Application, Domain, Infrastructure, Utilities)
- **Core Data**: Model includes DownloadItemEntity (id, url, filename, size, status, progress, etc.) and SettingsEntity
- **Persistence**: PersistenceController singleton with preview support for SwiftUI previews
- **Logging**: Category-based loggers (persistence, download, network, ui, application, error)
- **Configuration**: App Sandbox configured for user-selected file access and network client

## Phase 2: Download Engine
**Duration**: 7-10 days  
**Dependencies**: Phase 1

### Tasks
- Implement download queue with configurable concurrency.
- Add per-item state machine (queued/downloading/paused/failed/expired/complete).
- Add resume support via HTTP Range.
- Implement speed/ETA calculations and total progress.
- Add retry logic with exponential backoff.
- Create URLSession delegate for progress tracking.
- Implement file streaming to disk.

### Deliverables
- Working download queue controller
- State machine implementation
- Resume functionality tested
- Retry logic with backoff
- Progress calculation utilities

## Phase 3: Input and Parsing
**Duration**: 3-4 days  
**Dependencies**: Phase 1 (can start in parallel with Phase 2)

### Tasks
- Implement URL paste parsing (line- or comma-separated).
- Implement file import (txt/csv).
- Optional: parse URLs from HTML table snippets.
- Validate URL host and parameters; mark invalid or expired.
- Create URL validation utilities.
- Handle duplicate URL detection.

### Deliverables
- URL parsing utilities
- File import functionality
- URL validation logic
- Input error handling

## Phase 4: UI and UX
**Duration**: 5-7 days  
**Dependencies**: Phase 1, Phase 2 (for integration), Phase 3 (for input UI)

### Tasks
- Table view with per-item stats and destination.
- Bulk actions: start/pause all, retry failed, remove.
- Overall dashboard: totals, remaining, ETA.
- Status indicators and error messaging.
- Create view models for UI state.
- Implement SwiftUI views with @FetchRequest.
- Add progress indicators and animations.

### Deliverables
- Complete table view UI
- Dashboard view
- Bulk action functionality
- Status indicators
- Error message display

## Phase 5: Persistence and Resume
**Duration**: 4-6 days  
**Dependencies**: Phase 2, Phase 4

### Tasks
- Persist queue state and download metadata on every state transition.
- On launch, detect partial files and resume if allowed.
- Migration support for future schema changes.
- Implement Core Data save on state changes.
- Add file system validation on startup.
- Handle Core Data migration scenarios.

### Deliverables
- Persistent state across restarts
- Automatic resume on launch
- Core Data migration support
- State recovery logic

## Phase 6: Settings and Polishing
**Duration**: 3-4 days  
**Dependencies**: Phase 4, Phase 5

### Tasks
- Settings panel: default folder, concurrency, retries, throttling.
- Validate download folder permissions.
- Improve error copy and user guidance.
- Add settings persistence.
- Implement settings validation.
- Polish UI/UX details.
- Add tooltips and help text.

### Deliverables
- Settings view
- Settings persistence
- Improved error messages
- Polished UI

## Phase 7: Testing and Release Prep
**Duration**: 5-7 days  
**Dependencies**: All previous phases

### Tasks
- Unit tests for parsing, retry logic, state transitions.
- Integration tests for range resume and persistence.
- Manual QA checklist for large files and network interruptions.
- Build, sign, and package for distribution.
- Performance testing and optimization.
- Security review.
- Documentation finalization.

### Deliverables
- Test suite with good coverage
- QA test results
- Signed and notarized app
- Release documentation
- User guide (if needed)

## Total Estimated Duration
**Approximate Total**: 30-45 days (6-9 weeks for a single developer)

**Note**: Estimates assume full-time development. Adjust based on available time and team size.

## Milestones and Deliverables

### M1: Download Engine Working
**Target**: End of Phase 2  
**Criteria**:
- Download engine + queue working with basic UI or CLI test
- Can download files with progress tracking
- Resume functionality works
- Retry logic implemented

**Acceptance**:
- [ ] Can start downloads from code/CLI
- [ ] Progress updates work
- [ ] Resume works after interruption
- [ ] Retry triggers on failure

### M2: Full UI with Table and Bulk Actions
**Target**: End of Phase 4  
**Criteria**:
- Complete UI with table view
- Bulk actions functional
- Dashboard shows aggregate stats
- Status indicators work

**Acceptance**:
- [ ] Table displays all download items
- [ ] Bulk start/pause/retry works
- [ ] Dashboard shows correct totals
- [ ] UI remains responsive during downloads

### M3: Persistence and Resume on Restart
**Target**: End of Phase 5  
**Criteria**:
- State persists across app restarts
- Downloads resume automatically on launch
- Partial files detected and handled

**Acceptance**:
- [ ] App restart preserves all state
- [ ] Partial downloads resume correctly
- [ ] No data loss on crash
- [ ] Queue state restored accurately

### M4: Settings, Testing, and Release Readiness
**Target**: End of Phase 7  
**Criteria**:
- All settings functional and persistent
- Test suite passes
- App signed and ready for distribution
- Documentation complete

**Acceptance**:
- [ ] All settings work and persist
- [ ] Test coverage > 70%
- [ ] App builds and runs on clean system
- [ ] Documentation is up to date

## Risk Assessment

### High Risk
- **Large file handling**: 30-50GB files may reveal memory/performance issues
  - *Mitigation*: Test early with large files, use streaming, monitor memory

- **URL expiration**: Expired URLs may cause confusion
  - *Mitigation*: Clear error messages, easy URL refresh workflow

### Medium Risk
- **Core Data migration**: Schema changes may require careful migration
  - *Mitigation*: Plan migrations early, test migration paths

- **Network reliability**: Intermittent network may cause issues
  - *Mitigation*: Robust retry logic, clear status indicators

### Low Risk
- **UI performance**: Many items may slow UI
  - *Mitigation*: Throttle updates, use efficient SwiftUI patterns

## Success Metrics
- Can handle 50+ concurrent download items
- Successfully downloads 30-50GB files with resume
- State persists correctly across restarts
- UI remains responsive during active downloads
- Clear error messages guide users
