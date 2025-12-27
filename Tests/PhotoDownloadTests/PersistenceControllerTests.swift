//
//  PersistenceControllerTests.swift
//  photo-download
//
//  Created on 2025
//

import XCTest
import CoreData
@testable import photo_download

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
        // Given/When: Controller is initialized (store loads asynchronously in init)
        let controller = PersistenceController(inMemory: true)
        
        // Wait for store to actually load (poll until ready)
        let expectation = expectation(description: "Store loaded")
        var attempts = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            attempts += 1
            if !controller.container.persistentStoreCoordinator.persistentStores.isEmpty || attempts > 20 {
                timer.invalidate()
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 2.0)
        
        // Then: Container should be initialized
        XCTAssertNotNil(controller.container)
        XCTAssertNotNil(controller.container.persistentStoreDescriptions.first)
    }
    
    func testInMemoryStoreConfiguration() {
        // Given: In-memory controller (store loads asynchronously in init)
        let controller = PersistenceController(inMemory: true)
        
        // Wait a moment for async load to complete
        let expectation = expectation(description: "Store loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        
        // Then: Store should be in-memory type
        let stores = controller.container.persistentStoreCoordinator.persistentStores
        XCTAssertFalse(stores.isEmpty, "Store should be loaded")
        if let store = stores.first {
            XCTAssertEqual(store.type, NSInMemoryStoreType, "Store should be in-memory type")
        }
    }
    
    func testViewContextConfiguration() {
        // Given: Initialized controller (store loads asynchronously in init)
        let controller = PersistenceController(inMemory: true)
        
        // Wait a moment for async load to complete
        let expectation = expectation(description: "Store loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        
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
        let stores = preview1.container.persistentStoreCoordinator.persistentStores
        XCTAssertFalse(stores.isEmpty, "Store should be loaded")
        if let store = stores.first {
            XCTAssertEqual(store.type, NSInMemoryStoreType, "Store should be in-memory type")
        }
    }
    
    // MARK: - Core Data Stack Tests
    
    func testPersistentStoreLoading() {
        // Given: In-memory controller (store loads asynchronously in init)
        let controller = PersistenceController(inMemory: true)
        
        // Wait a moment for async load to complete
        let expectation = expectation(description: "Store loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        
        // Then: Persistent stores should be loaded
        XCTAssertFalse(controller.container.persistentStoreDescriptions.isEmpty)
        XCTAssertNotNil(controller.container.persistentStoreCoordinator.persistentStores.first)
    }
    
    func testViewContextIsMainContext() {
        // Given: Initialized controller (store loads asynchronously in init)
        let controller = PersistenceController(inMemory: true)
        
        // Wait a moment for async load to complete
        let expectation = expectation(description: "Store loaded")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        
        // Then: View context should be main context
        let viewContext = controller.container.viewContext
        XCTAssertEqual(viewContext.concurrencyType, .mainQueueConcurrencyType)
    }
}

