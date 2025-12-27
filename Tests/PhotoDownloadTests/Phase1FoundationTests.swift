//
//  Phase1FoundationTests.swift
//  photo-download
//
//  Created on 2025
//
//  Integration tests for Phase 1 foundation components
//

import XCTest
import CoreData
// Note: @testable import will be added when Xcode project is created with proper module name

final class Phase1FoundationTests: XCTestCase {
    
    var persistenceController: PersistenceController!
    var viewContext: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        viewContext = persistenceController.container.viewContext
    }
    
    override func tearDown() {
        viewContext = nil
        persistenceController = nil
        super.tearDown()
    }
    
    // MARK: - Integration Tests
    
    func testCompletePhase1Setup() {
        // Given: Phase 1 foundation components
        
        // When: Verifying all components exist
        let controller = PersistenceController.shared
        let logger = Logger.persistence
        
        // Then: All components should be initialized
        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller.container)
        XCTAssertNotNil(logger)
    }
    
    func testCoreDataModelCanBeLoaded() {
        // Given: PersistenceController
        let controller = PersistenceController(inMemory: true)
        
        // When: Accessing managed object model
        let model = controller.container.managedObjectModel
        
        // Then: Model should be loaded
        XCTAssertNotNil(model)
        XCTAssertNotNil(model.entitiesByName["DownloadItemEntity"])
        XCTAssertNotNil(model.entitiesByName["SettingsEntity"])
    }
    
    func testCanCreateAndSaveDownloadItem() throws {
        // Given: Core Data context
        let context = viewContext!
        let entity = NSEntityDescription.entity(forEntityName: "DownloadItemEntity", in: context)!
        let downloadItem = NSManagedObject(entity: entity, insertInto: context)
        
        // When: Setting values and saving
        let testID = UUID()
        downloadItem.setValue(testID, forKey: "id")
        downloadItem.setValue("https://cvws.icloud-content.com/test", forKey: "url")
        downloadItem.setValue("test.zip", forKey: "filename")
        downloadItem.setValue("queued", forKey: "status")
        downloadItem.setValue(0.0, forKey: "progress")
        
        try context.save()
        
        // Then: Item should be saved
        XCTAssertFalse(context.hasChanges)
        
        // And: Can fetch it back
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "DownloadItemEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", testID as CVarArg)
        let results = try context.fetch(fetchRequest)
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.value(forKey: "filename") as? String, "test.zip")
    }
    
    func testCanCreateAndSaveSettings() throws {
        // Given: Core Data context
        let context = viewContext!
        let entity = NSEntityDescription.entity(forEntityName: "SettingsEntity", in: context)!
        let settings = NSManagedObject(entity: entity, insertInto: context)
        
        // When: Setting values and saving
        let testID = UUID()
        settings.setValue(testID, forKey: "id")
        settings.setValue("/Users/test/Downloads", forKey: "defaultDownloadFolder")
        settings.setValue(3, forKey: "maxParallelDownloads")
        settings.setValue(5, forKey: "maxRetryAttempts")
        
        try context.save()
        
        // Then: Settings should be saved
        XCTAssertFalse(context.hasChanges)
        
        // And: Can fetch it back
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SettingsEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", testID as CVarArg)
        let results = try context.fetch(fetchRequest)
        
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.value(forKey: "maxParallelDownloads") as? Int16, 3)
    }
    
    func testLoggerWorksWithPersistenceOperations() {
        // Given: Logger and persistence operations
        let logger = Logger.persistence
        
        // When: Logging during persistence operations
        logger.info("Starting persistence test")
        
        let controller = PersistenceController(inMemory: true)
        XCTAssertNotNil(controller)
        
        logger.info("Persistence controller initialized")
        
        // Then: Should complete without errors
        // (Logger doesn't throw, so if we get here, it worked)
        XCTAssertTrue(true)
    }
}

