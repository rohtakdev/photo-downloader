# Application Specification

## Overview
A macOS download manager application designed to handle bulk downloads from Apple's iCloud Data Export service. The application manages large file downloads (30-50GB per file) with support for resumable downloads, concurrent processing, and persistent state management.

## Context and Use Case
- **Source**: Apple Data & Privacy portal (privacy.apple.com)
- **Typical scenario**: 50+ files, 30-50GB each, 2-3TB total
- **URL characteristics**: 
  - Time-limited tokens (expire ~2-3 weeks after request)
  - URL pattern: `cvws.icloud-content.com` with authentication tokens and expiration parameters
  - URLs are sensitive and short-lived

## Functional Requirements

### FR1: URL Input Methods
The application must support multiple methods for importing download URLs:

1. **Paste Input**
   - Accept multiple URLs pasted into a text field
   - Support newline-separated URLs
   - Support comma-separated URLs
   - Validate URL format before adding to queue

2. **File Import**
   - Import URLs from plain text files (.txt)
   - Import URLs from CSV files
   - Support one URL per line or comma-separated format

3. **HTML Parsing (Optional)**
   - Parse URLs directly from copied HTML table snippets
   - Extract download links from table structures

**Acceptance Criteria:**
- User can paste 50+ URLs at once
- User can import URLs from a file
- Invalid URLs are rejected with clear error messages
- Duplicate URLs are detected and handled appropriately

### FR2: Download Management
The application must manage concurrent downloads with configurable limits:

1. **Concurrency Control**
   - Configurable maximum parallel downloads (default: 2-3)
   - Queue management to enforce limits
   - Automatic start of queued items when slots become available

2. **Resume Support**
   - Resume interrupted downloads using HTTP Range headers
   - Detect existing partial files on startup
   - Validate partial file integrity before resuming
   - Critical for 30-50GB files that may be interrupted

3. **Progress Tracking**
   - Real-time per-file statistics:
     - Progress percentage
     - Download speed (MB/s)
     - Estimated time remaining (ETA)
   - Overall dashboard metrics:
     - Total progress across all files
     - Files completed/remaining count
     - Aggregate ETA for remaining downloads

**Acceptance Criteria:**
- Downloads resume correctly after interruption
- Progress updates are accurate and responsive
- Concurrent download limit is enforced
- Large files (30-50GB) download successfully

### FR3: Destination Management
The application must support flexible file destination options:

1. **Default Location**
   - Global default download folder setting
   - User-selectable default location

2. **Per-File Override**
   - Option to specify custom destination for individual files
   - Validation of destination path permissions

**Acceptance Criteria:**
- Files are saved to the correct destination
- Permission errors are caught and reported
- Default location persists across app restarts

### FR4: Error Handling and Retry Logic
The application must handle various error conditions gracefully:

1. **Automatic Retry**
   - Exponential backoff retry mechanism
   - Default: 3 retry attempts
   - Configurable retry count

2. **Token Expiration Detection**
   - Detect expired/invalid tokens (HTTP 401/403 responses)
   - Mark file as "expired" status
   - Prompt user to refresh URL from Apple portal
   - Do not retry expired URLs automatically

3. **Network Failures**
   - Retry with backoff on network errors
   - Distinguish between retryable and terminal failures
   - Pause item after max retries reached

4. **File Integrity**
   - Validate file size post-download (minimum check)
   - Report integrity issues to user
   - Allow manual retry for failed downloads

**Acceptance Criteria:**
- Expired URLs are detected and marked appropriately
- Network failures trigger retries with backoff
- User is notified when manual intervention is required
- File integrity is verified after download completion

### FR5: User Interface
The application must provide a clear, informative interface:

1. **Table View**
   - Display columns: filename, size, status, progress, speed, ETA, destination
   - Sortable columns
   - Filterable by status
   - Real-time updates during downloads

2. **Status Indicators**
   - Visual status indicators for: queued, downloading, paused, failed, expired, complete
   - Color-coded status for quick visual scanning

3. **Bulk Actions**
   - Start all queued items
   - Pause all active downloads
   - Retry all failed items
   - Remove items from queue

4. **Dashboard**
   - Overall progress indicator
   - Aggregate statistics (total size, completed, remaining)
   - Estimated total time remaining

**Acceptance Criteria:**
- UI remains responsive during active downloads
- Status updates are visible in real-time
- Bulk actions work correctly on selected items
- Dashboard metrics are accurate

### FR6: Settings and Configuration
The application must provide configurable settings:

1. **Download Settings**
   - Default download location (persistent)
   - Maximum parallel downloads (1-10 range)
   - Retry attempts (1-10 range)
   - Speed throttling (optional, MB/s limit)

2. **Settings Persistence**
   - All settings persist across app restarts
   - Settings apply to new downloads immediately

**Acceptance Criteria:**
- Settings are saved and restored correctly
- Settings changes take effect without restart
- Validation prevents invalid setting values

### FR7: State Persistence
The application must maintain state across restarts:

1. **Download State**
   - Persist all download items and their status
   - Persist progress information
   - Persist queue order

2. **Resume on Launch**
   - Detect partial files on startup
   - Resume downloads automatically if appropriate
   - Restore queue state exactly as left

**Acceptance Criteria:**
- App restart preserves all download state
- Partial downloads are detected and resumed
- No data loss on unexpected termination

## Non-Functional Requirements

### NFR1: Performance
- Handle 50+ concurrent download items without UI lag
- Progress updates throttled to 2-4 updates per second per item
- Memory usage should remain reasonable even with large files
- Stream to disk to avoid memory spikes

### NFR2: Reliability
- Survive app crashes and restarts
- No data corruption in resumed downloads
- Accurate progress tracking
- Consistent state management

### NFR3: User Experience
- Clear error messages with actionable guidance
- Responsive UI during active downloads
- Intuitive interface for bulk operations
- Helpful status messages and tooltips

### NFR4: Security
- Do not store sensitive URLs in plain text logs
- Validate all file paths before writing
- Respect macOS sandbox restrictions
- Handle URL expiration securely

## Technical Constraints
- **Platform**: macOS 13.0+ (Ventura or later)
- **Framework**: SwiftUI for UI, Foundation/URLSession for networking
- **Persistence**: Core Data or GRDB (to be determined)
- **Architecture**: MVVM pattern with clear separation of concerns

## Data Models

### DownloadItem
- `id`: Unique identifier (UUID)
- `url`: Download URL (sensitive, time-limited)
- `filename`: Extracted or user-specified filename
- `size`: File size in bytes (if known)
- `destination`: File system path
- `status`: Current status (enum: queued, downloading, paused, failed, expired, complete)
- `progress`: Download progress (0.0 - 1.0)
- `bytesDownloaded`: Bytes downloaded so far
- `speed`: Current download speed (bytes/second)
- `eta`: Estimated time remaining (seconds)
- `retryCount`: Number of retry attempts
- `errorMessage`: Last error message (if any)
- `createdAt`: Timestamp when item was added
- `updatedAt`: Timestamp of last update

### Settings
- `defaultDownloadFolder`: Path to default download location
- `maxParallelDownloads`: Maximum concurrent downloads (default: 2)
- `maxRetryAttempts`: Maximum retry attempts (default: 3)
- `speedThrottle`: Optional speed limit in bytes/second (nil = unlimited)

## URL Format Specification
- **Host**: `cvws.icloud-content.com`
- **Pattern**: Contains authentication tokens and expiration parameters
- **Validation**: Must validate host and presence of required parameters
- **Expiration**: URLs expire approximately 2-3 weeks after generation

## Error Scenarios

### E1: Expired URL (401/403)
- **Detection**: HTTP status code 401 or 403
- **Action**: Mark as "expired", stop retrying, prompt user for new URL
- **User Action**: User must obtain new URL from Apple portal

### E2: Network Failure
- **Detection**: Network errors, timeouts, connection refused
- **Action**: Retry with exponential backoff up to max attempts
- **User Action**: None required if retries succeed

### E3: Disk Full
- **Detection**: File system write errors
- **Action**: Pause download, notify user
- **User Action**: Free disk space or change destination

### E4: Permission Denied
- **Detection**: File system permission errors
- **Action**: Pause download, notify user
- **User Action**: Grant permissions or change destination

### E5: Invalid File Size
- **Detection**: Downloaded file size doesn't match expected size
- **Action**: Mark as failed, allow retry
- **User Action**: Manual retry or verify URL

## Acceptance Criteria Summary
- ✅ Handles 50+ URLs simultaneously
- ✅ Downloads 30-50GB files successfully with resume support
- ✅ Detects and handles expired URLs appropriately
- ✅ Maintains state across app restarts
- ✅ Provides real-time progress updates
- ✅ Enforces concurrent download limits
- ✅ Validates file integrity post-download
- ✅ Provides clear error messages and user guidance
