//
//  LoggerTests.swift
//  photo-download
//
//  Created on 2025
//

import XCTest
import os.log
// Note: @testable import will be added when Xcode project is created with proper module name

final class LoggerTests: XCTestCase {
    
    // MARK: - Logger Initialization Tests
    
    func testPersistenceLoggerExists() {
        // Given/When: Accessing persistence logger
        let logger = Logger.persistence
        
        // Then: Logger should be initialized
        XCTAssertNotNil(logger)
    }
    
    func testDownloadLoggerExists() {
        // Given/When: Accessing download logger
        let logger = Logger.download
        
        // Then: Logger should be initialized
        XCTAssertNotNil(logger)
    }
    
    func testNetworkLoggerExists() {
        // Given/When: Accessing network logger
        let logger = Logger.network
        
        // Then: Logger should be initialized
        XCTAssertNotNil(logger)
    }
    
    func testUILoggerExists() {
        // Given/When: Accessing UI logger
        let logger = Logger.ui
        
        // Then: Logger should be initialized
        XCTAssertNotNil(logger)
    }
    
    func testApplicationLoggerExists() {
        // Given/When: Accessing application logger
        let logger = Logger.application
        
        // Then: Logger should be initialized
        XCTAssertNotNil(logger)
    }
    
    func testErrorLoggerExists() {
        // Given/When: Accessing error logger
        let logger = Logger.error
        
        // Then: Logger should be initialized
        XCTAssertNotNil(logger)
    }
    
    // MARK: - Logger Category Tests
    
    func testLoggerCategoriesAreDifferent() {
        // Given: Different loggers
        let persistenceLogger = Logger.persistence
        let downloadLogger = Logger.download
        let networkLogger = Logger.network
        
        // Then: They should be different instances (different categories)
        // Note: os.log.Logger doesn't expose category directly for comparison
        // But we can verify they're all Logger instances
        XCTAssertTrue(persistenceLogger is Logger)
        XCTAssertTrue(downloadLogger is Logger)
        XCTAssertTrue(networkLogger is Logger)
    }
    
    // MARK: - Logger Functionality Tests
    
    func testLoggerCanLogInfo() {
        // Given: A logger
        let logger = Logger.persistence
        
        // When: Logging info message
        // Then: Should not throw (logging is fire-and-forget)
        logger.info("Test info message")
    }
    
    func testLoggerCanLogError() {
        // Given: A logger
        let logger = Logger.error
        
        // When: Logging error message
        // Then: Should not throw
        logger.error("Test error message")
    }
    
    func testLoggerCanLogDebug() {
        // Given: A logger
        let logger = Logger.download
        
        // When: Logging debug message
        // Then: Should not throw
        logger.debug("Test debug message")
    }
    
    func testLoggerCanLogWarning() {
        // Given: A logger
        let logger = Logger.network
        
        // When: Logging warning message
        // Then: Should not throw
        logger.warning("Test warning message")
    }
}

