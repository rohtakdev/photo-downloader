# Test Plan

## Goals
- Ensure reliable large-file downloads with resume support.
- Validate parsing and input flows for URLs.
- Confirm persistence and resume after app restarts.
- Verify correct handling of expired or invalid URLs.

## Test Types

### Unit Tests

#### URL Parsing Tests
**Test Case: TC-URL-001 - Parse Newline-Separated URLs**
- **Input**: String with 3 URLs separated by newlines
- **Expected**: Array of 3 valid URL strings
- **Assert**: All URLs are valid, no empty strings

**Test Case: TC-URL-002 - Parse Comma-Separated URLs**
- **Input**: String with 3 URLs separated by commas
- **Expected**: Array of 3 valid URL strings
- **Assert**: All URLs are valid, whitespace trimmed

**Test Case: TC-URL-003 - Parse CSV File**
- **Input**: CSV file with URL column
- **Expected**: Array of URLs extracted from CSV
- **Assert**: Handles CSV headers, extracts correct column

**Test Case: TC-URL-004 - Handle Invalid URLs**
- **Input**: Mix of valid and invalid URLs
- **Expected**: Valid URLs accepted, invalid URLs rejected
- **Assert**: Error messages for invalid URLs

**Test Case: TC-URL-005 - Detect Duplicate URLs**
- **Input**: Same URL appears multiple times
- **Expected**: Duplicates detected and handled
- **Assert**: User notified or duplicates skipped

#### URL Validation Tests
**Test Case: TC-VAL-001 - Validate iCloud Host**
- **Input**: URL with `cvws.icloud-content.com` host
- **Expected**: Validation passes
- **Assert**: Host check returns true

**Test Case: TC-VAL-002 - Reject Non-iCloud Hosts**
- **Input**: URL with different host
- **Expected**: Validation fails
- **Assert**: Error message indicates invalid host

**Test Case: TC-VAL-003 - Check Token Parameters**
- **Input**: URL with/without auth tokens
- **Expected**: URLs with tokens pass, without fail
- **Assert**: Parameter presence validated

#### State Transition Tests
**Test Case: TC-STATE-001 - Queued to Downloading**
- **Setup**: Item in queued state
- **Action**: Start download
- **Expected**: State changes to downloading
- **Assert**: State updated, timestamp recorded

**Test Case: TC-STATE-002 - Downloading to Complete**
- **Setup**: Item downloading, reaches 100%
- **Action**: Download completes successfully
- **Expected**: State changes to complete
- **Assert**: File size validated, state persisted

**Test Case: TC-STATE-003 - Downloading to Failed**
- **Setup**: Item downloading
- **Action**: Network error occurs
- **Expected**: State changes to failed after retries
- **Assert**: Retry count incremented, error message stored

**Test Case: TC-STATE-004 - Downloading to Expired**
- **Setup**: Item downloading
- **Action**: Receives 401/403 response
- **Expected**: State changes to expired immediately
- **Assert**: No retries attempted, error message indicates expiration

**Test Case: TC-STATE-005 - Paused State**
- **Setup**: Item downloading
- **Action**: User pauses
- **Expected**: State changes to paused
- **Assert**: Download stops, partial file preserved

#### Retry Logic Tests
**Test Case: TC-RETRY-001 - Exponential Backoff Calculation**
- **Input**: Retry attempt number (1, 2, 3)
- **Expected**: Backoff times increase exponentially
- **Assert**: Times match formula (base * 2^attempt)

**Test Case: TC-RETRY-002 - Max Retries Reached**
- **Setup**: Item failed, retry count at max
- **Action**: Attempt retry
- **Expected**: No retry attempted, state remains failed
- **Assert**: User notified, manual retry required

**Test Case: TC-RETRY-003 - Retry on Network Error**
- **Setup**: Network error occurs
- **Action**: Automatic retry triggered
- **Expected**: Retry after backoff delay
- **Assert**: Retry count incremented, download resumed

#### Calculation Tests
**Test Case: TC-CALC-001 - Download Speed Calculation**
- **Input**: Bytes downloaded, time elapsed
- **Expected**: Speed in MB/s calculated correctly
- **Assert**: Formula: (bytes / time) / (1024 * 1024)

**Test Case: TC-CALC-002 - ETA Calculation**
- **Input**: Remaining bytes, current speed
- **Expected**: ETA in seconds calculated
- **Assert**: Formula: remaining / speed, handle division by zero

**Test Case: TC-CALC-003 - Progress Percentage**
- **Input**: Bytes downloaded, total size
- **Expected**: Progress 0.0 to 1.0
- **Assert**: Percentage calculated: downloaded / total

### Integration Tests

#### Range Resume Tests
**Test Case: TC-RESUME-001 - Resume Partial Download**
- **Setup**: 
  - Start download of 100MB file
  - Stop download at 50MB
  - Verify partial file exists
- **Action**: Restart download
- **Expected**: 
  - Range header sent: `Range: bytes=50MB-`
  - Download resumes from 50MB
  - Final file is 100MB, no corruption
- **Assert**: File size correct, content valid

**Test Case: TC-RESUME-002 - Resume After App Restart**
- **Setup**:
  - Start download, let it run partially
  - Force quit app
  - Restart app
- **Action**: App launches
- **Expected**: 
  - Partial file detected
  - Download resumes automatically
  - Progress continues from where it left off
- **Assert**: State restored, download resumes

**Test Case: TC-RESUME-003 - Handle 416 Range Not Satisfiable**
- **Setup**: Partial file exists but server doesn't support range
- **Action**: Attempt resume
- **Expected**: 
  - Delete partial file
  - Restart download from beginning
- **Assert**: No corruption, download completes

**Test Case: TC-RESUME-004 - Validate Partial File Integrity**
- **Setup**: Partial file exists but size doesn't match expected
- **Action**: Attempt resume
- **Expected**: 
  - Detect mismatch
  - Delete partial file or prompt user
  - Restart from beginning
- **Assert**: No data corruption

#### Persistence Tests
**Test Case: TC-PERSIST-001 - State Persists Across Restart**
- **Setup**:
  - Add 5 items to queue
  - Start 2 downloads
  - Pause 1 download
- **Action**: Restart app
- **Expected**: 
  - All 5 items present
  - 2 active downloads resume
  - 1 paused item remains paused
- **Assert**: State matches exactly

**Test Case: TC-PERSIST-002 - Progress Persists**
- **Setup**: 
  - Download reaches 30% progress
  - Note exact bytes downloaded
- **Action**: Restart app
- **Expected**: 
  - Progress shows 30%
  - Bytes downloaded matches
- **Assert**: Progress accurate

**Test Case: TC-PERSIST-003 - Settings Persist**
- **Setup**: 
  - Change max parallel downloads to 5
  - Change default folder
- **Action**: Restart app
- **Expected**: 
  - Settings restored
  - New downloads use new settings
- **Assert**: Settings match

#### Concurrency Tests
**Test Case: TC-CONC-001 - Enforce Max Parallel Downloads**
- **Setup**: 
  - Set max parallel to 2
  - Queue 5 items
- **Action**: Start all
- **Expected**: 
  - Only 2 downloads active
  - Remaining 3 in queued state
  - As downloads complete, queued items start
- **Assert**: Never exceeds limit

**Test Case: TC-CONC-002 - Concurrency Limit Change**
- **Setup**: 
  - 3 downloads active, limit is 3
- **Action**: Change limit to 2
- **Expected**: 
  - No new downloads start
  - Existing downloads continue
  - Next download waits until one completes
- **Assert**: Limit enforced correctly

**Test Case: TC-CONC-003 - Rapid Start/Stop**
- **Setup**: Queue with 10 items
- **Action**: Rapidly start/pause/start items
- **Expected**: 
  - No race conditions
  - State remains consistent
  - Concurrency limit never exceeded
- **Assert**: No crashes, state valid

#### Destination Tests
**Test Case: TC-DEST-001 - Default Destination**
- **Setup**: Set default download folder
- **Action**: Add item without custom destination
- **Expected**: Item uses default folder
- **Assert**: File saved to default location

**Test Case: TC-DEST-002 - Custom Destination**
- **Setup**: Add item with custom destination
- **Action**: Start download
- **Expected**: File saved to custom location
- **Assert**: File in correct location

**Test Case: TC-DEST-003 - Permission Denied**
- **Setup**: Set destination to restricted folder
- **Action**: Start download
- **Expected**: 
  - Error detected
  - Item marked as failed
  - Clear error message
- **Assert**: User notified, no crash

### Manual QA

#### Large Scale Tests
**Test Case: TC-MANUAL-001 - Bulk Import (50+ URLs)**
- **Steps**:
  1. Import file with 50+ URLs
  2. Verify all URLs parsed correctly
  3. Start all downloads
  4. Monitor UI responsiveness
- **Expected**: 
  - All URLs imported
  - UI remains responsive
  - Downloads proceed according to concurrency limit
- **Success Criteria**: No crashes, UI smooth, all items process

**Test Case: TC-MANUAL-002 - Large File Download (30-50GB)**
- **Steps**:
  1. Start download of 30GB+ file
  2. Monitor memory usage
  3. Let it run for several hours
  4. Verify completion
- **Expected**: 
  - Memory usage remains reasonable
  - Progress updates accurate
  - File completes successfully
- **Success Criteria**: No memory spikes, file integrity verified

**Test Case: TC-MANUAL-003 - Network Interruption**
- **Steps**:
  1. Start large file download
  2. Disable network mid-download
  3. Wait for retries
  4. Re-enable network
  5. Verify resume
- **Expected**: 
  - Retries triggered with backoff
  - Download resumes when network returns
  - No data corruption
- **Success Criteria**: Resume works, file complete

#### Error Handling Tests
**Test Case: TC-MANUAL-004 - Expired URL (401/403)**
- **Steps**:
  1. Add expired URL (or mock 401 response)
  2. Start download
  3. Observe error handling
- **Expected**: 
  - 401/403 detected immediately
  - Item marked as expired
  - Clear message prompts for new URL
  - No retries attempted
- **Success Criteria**: User clearly informed, no wasted retries

**Test Case: TC-MANUAL-005 - Invalid URL Format**
- **Steps**:
  1. Paste invalid URL
  2. Attempt to add to queue
- **Expected**: 
  - Validation error shown
  - Item not added
  - Helpful error message
- **Success Criteria**: Clear feedback, no crashes

#### Settings Tests
**Test Case: TC-MANUAL-006 - Settings Change During Active Downloads**
- **Steps**:
  1. Start multiple downloads
  2. Change max parallel downloads setting
  3. Observe behavior
- **Expected**: 
  - Existing downloads continue
  - New limit applies to queued items
  - No disruption to active downloads
- **Success Criteria**: Settings apply correctly, no crashes

**Test Case: TC-MANUAL-007 - Change Download Folder**
- **Steps**:
  1. Set default folder
  2. Start downloads
  3. Change default folder
  4. Add new item
- **Expected**: 
  - Existing downloads continue to original folder
  - New item uses new folder
- **Success Criteria**: Folder changes apply correctly

#### Edge Case Tests
**Test Case: TC-MANUAL-008 - Disk Full**
- **Steps**:
  1. Fill disk to near capacity
  2. Start large download
  3. Observe behavior when disk fills
- **Expected**: 
  - Error detected when disk full
  - Download paused
  - Clear error message
  - User can free space and retry
- **Success Criteria**: Graceful handling, no crashes

**Test Case: TC-MANUAL-009 - Permission Denied**
- **Steps**:
  1. Set destination to folder without write permission
  2. Start download
- **Expected**: 
  - Permission error detected
  - Download fails immediately
  - Clear error message
- **Success Criteria**: Error caught early, user informed

**Test Case: TC-MANUAL-010 - App Crash Recovery**
- **Steps**:
  1. Start multiple downloads
  2. Force quit app (simulate crash)
  3. Restart app
- **Expected**: 
  - All state restored
  - Partial downloads detected
  - Downloads resume automatically
- **Success Criteria**: Complete state recovery, no data loss

**Test Case: TC-MANUAL-011 - Rapid UI Interactions**
- **Steps**:
  1. Rapidly start/pause/remove items
  2. Change settings quickly
  3. Import URLs while downloads active
- **Expected**: 
  - UI remains responsive
  - No race conditions
  - State remains consistent
- **Success Criteria**: No crashes, UI smooth

## Test Data

### Production URLs
- **Valid iCloud Export URLs**: Short-lived URLs from privacy.apple.com
- **Limitations**: Expire after 2-3 weeks, use sparingly
- **Usage**: Final integration testing only

### Mock Test Server
- **Local HTTP Server**: Python `http.server` or custom Swift server
- **Capabilities**:
  - Serve files of configurable size
  - Simulate slow connections
  - Return specific HTTP status codes (401, 403, 500, etc.)
  - Support Range requests for resume testing
  - Control response timing

### Test Files
- **Small Files** (1-10MB): For rapid testing
- **Medium Files** (100MB-1GB): For resume and performance testing
- **Large Files** (10GB+): For stress testing (use sparse files or mock)

### Test Scenarios
- **Valid Downloads**: Normal successful downloads
- **Expired Tokens**: Mock 401/403 responses
- **Network Errors**: Simulate timeouts, connection refused
- **Slow Connections**: Throttle bandwidth for ETA testing
- **Partial Responses**: Test Range request handling

## Success Criteria

### Functional Requirements
- ✅ No data corruption in resumed downloads
- ✅ Correct status updates and UI responsiveness
- ✅ Consistent persistence across restarts
- ✅ Clear user guidance when actions are required
- ✅ All error scenarios handled gracefully
- ✅ Concurrency limits enforced correctly

### Performance Requirements
- ✅ UI remains responsive with 50+ items
- ✅ Memory usage stays reasonable with large files
- ✅ Progress updates at 2-4 updates/second (not excessive)
- ✅ App launch time < 2 seconds

### Quality Metrics
- **Test Coverage**: > 70% code coverage for business logic
- **Unit Tests**: All parsing, calculation, and state machine logic tested
- **Integration Tests**: Critical paths (resume, persistence) covered
- **Manual QA**: All user-facing scenarios validated

### Release Readiness
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Manual QA checklist complete
- [ ] No critical bugs
- [ ] Performance acceptable
- [ ] Documentation complete

## Automation Strategy

### Unit Test Framework
- **Framework**: XCTest (built into Xcode)
- **Location**: `Tests/` directory
- **Targets**: 
  - Parsing utilities
  - State machine logic
  - Calculation functions
  - Validation logic

### Integration Test Setup
- **Local HTTP Server**: 
  - Python: `python -m http.server` with custom handler
  - Or: Swift-based test server using Vapor/Perfect
  - Capabilities: Range support, status code control, bandwidth throttling
- **Test Data**: Pre-generated test files of various sizes
- **Test Scenarios**: Automated resume, persistence, concurrency tests

### CI/CD Integration
- **CI Platform**: GitHub Actions, GitLab CI, or similar
- **Smoke Tests**: 
  - Run on every commit
  - Test data model and parsing modules
  - Quick validation (< 5 minutes)
- **Full Test Suite**: 
  - Run on pull requests
  - All unit tests + integration tests
  - Longer running (< 30 minutes)

### Test Execution
```bash
# Run all tests
xcodebuild test -scheme photo-download -destination 'platform=macOS'

# Run specific test suite
xcodebuild test -scheme photo-download -only-testing:PhotoDownloadTests/URLParsingTests

# Generate coverage report
xcodebuild test -scheme photo-download -enableCodeCoverage YES
```

### Test Environment Requirements
- macOS 13.0+ for running tests
- Xcode 15+ for test execution
- Local test server running for integration tests
- Sufficient disk space for test file downloads
- Network access (for some integration tests)

## Test Execution Schedule

### During Development
- Run unit tests frequently (before each commit)
- Run integration tests before merging features
- Manual QA for new features

### Phase 1 Tests Status ✅
- **PersistenceControllerTests**: 11 tests covering initialization, store configuration, context setup
- **CoreDataEntityTests**: 10 tests covering entity creation, attributes, validation, persistence
- **LoggerTests**: 10 tests covering all logger categories and functionality
- **Phase1FoundationTests**: 5 integration tests covering complete foundation setup
- **Total**: 36 test cases ready (will run once Xcode project is created)

### Before Release
- Full test suite execution
- Extended manual QA (large files, edge cases)
- Performance testing
- Security review
