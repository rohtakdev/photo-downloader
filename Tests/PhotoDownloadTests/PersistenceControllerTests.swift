//
//  PersistenceControllerTests.swift
//  photo-download
//
//  Created on 2025
//

import XCTest
import CoreData
// Note: @testable import will be added when Xcode project is created with proper module name

final class PersistenceControllerTests: XCTestCase {
    
    var persistenceController: PersistenceController!
    
    override func setUp() {
        super.setUp()
        // Use in-memory store for tests
        persistenceController = PersistenceController(inMemory: true)
    }
    
    override func tearDown() {
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testPersistenceControllerInitialization() {
        // Given/When: Controller is initialized
        let controller = PersistenceController(inMemory: true)
        
        // Then: Container should be initialized
        XCTAssertNotNil(controller.container)
        XCTAssertNotNil(controller.container.persistentStoreDescriptions.first)
    }
    
    func testInMemoryStoreConfiguration() {
        // Given: In-memory controller
        let controller = PersistenceController(inMemory: true)
        
        // Then: Store URL should point to /dev/null
        let storeURL = controller.container.persistentStoreDescriptions.first?.url
        XCTAssertEqual(storeURL?.path, "/dev/null")
    }
    
    func testViewContextConfiguration() {
        // Given: Initialized controller
        let controller = PersistenceController(inMemory: true)
        
        // Then: View context should be configured correctly
        let viewContext = controller.container.viewContext
        XCTAssertTrue(viewContext.automaticallyMergesChangesFromParent)
        XCTAssertNotNil(viewContext.mergePolicy)
    }
    
    func testSharedInstance() {
        // Given/When: Accessing shared instance
        let shared1 = PersistenceController.shared
        let shared2 = PersistenceController.shared
        
        // Then: Should return same instance (singleton)
        XCTAssertTrue(shared1.container === shared2.container)
    }
    
    func testPreviewInstance() {
        // Given/When: Accessing preview instance
        let preview1 = PersistenceController.preview
        let preview2 = PersistenceController.preview
        
        // Then: Should return same instance
        XCTAssertTrue(preview1.container === preview2.container)
        
        // And: Should be in-memory
        let storeURL = preview1.container.persistentStoreDescriptions.first?.url
        XCTAssertEqual(storeURL?.path, "/dev/null")
    }
    
    // MARK: - Core Data Stack Tests
    
    func testPersistentStoreLoading() {
        // Given: In-memory controller
        let controller = PersistenceController(inMemory: true)
        
        // Then: Persistent stores should be loaded
        XCTAssertFalse(controller.container.persistentStoreDescriptions.isEmpty)
    }
    
    func testViewContextIsMainContext() {
        // Given: Initialized controller
        let controller = PersistenceController(inMemory: true)
        
        // Then: View context should be main context
        let viewContext = controller.container.viewContext
        XCTAssertEqual(viewContext.concurrencyType, .mainQueueConcurrencyType)
    }
}

