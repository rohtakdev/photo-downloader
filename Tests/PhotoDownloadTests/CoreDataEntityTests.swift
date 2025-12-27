//
//  CoreDataEntityTests.swift
//  photo-download
//
//  Created on 2025
//

import XCTest
import CoreData
// Note: @testable import will be added when Xcode project is created with proper module name

final class CoreDataEntityTests: XCTestCase {
    
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
    
    // MARK: - DownloadItemEntity Tests
    
    func testDownloadItemEntityCreation() {
        // Given: Core Data context
        let context = viewContext
        
        // When: Creating DownloadItemEntity
        let entity = NSEntityDescription.entity(forEntityName: "DownloadItemEntity", in: context!)!
        let downloadItem = NSManagedObject(entity: entity, insertInto: context)
        
        // Then: Entity should be created
        XCTAssertNotNil(downloadItem)
        XCTAssertEqual(downloadItem.entity.name, "DownloadItemEntity")
    }
    
    func testDownloadItemEntityAttributes() {
        // Given: Core Data context
        let context = viewContext
        
        // When: Creating DownloadItemEntity
        let entity = NSEntityDescription.entity(forEntityName: "DownloadItemEntity", in: context!)!
        let downloadItem = NSManagedObject(entity: entity, insertInto: context)
        
        // Then: All required attributes should exist
        let attributes = entity.attributesByName
        XCTAssertNotNil(attributes["id"])
        XCTAssertNotNil(attributes["url"])
        XCTAssertNotNil(attributes["filename"])
        XCTAssertNotNil(attributes["status"])
        XCTAssertNotNil(attributes["progress"])
        XCTAssertNotNil(attributes["bytesDownloaded"])
        XCTAssertNotNil(attributes["size"])
        XCTAssertNotNil(attributes["speed"])
        XCTAssertNotNil(attributes["eta"])
        XCTAssertNotNil(attributes["retryCount"])
        XCTAssertNotNil(attributes["destination"])
        XCTAssertNotNil(attributes["errorMessage"])
        XCTAssertNotNil(attributes["createdAt"])
        XCTAssertNotNil(attributes["updatedAt"])
    }
    
    func testDownloadItemEntityIDIsRequired() {
        // Given: Core Data context
        let context = viewContext
        
        // When: Checking entity description
        let entity = NSEntityDescription.entity(forEntityName: "DownloadItemEntity", in: context!)!
        let idAttribute = entity.attributesByName["id"]
        
        // Then: ID should be required (non-optional)
        XCTAssertNotNil(idAttribute)
        XCTAssertFalse(idAttribute!.isOptional)
    }
    
    func testDownloadItemEntityDefaultValues() {
        // Given: Core Data context
        let context = viewContext
        
        // When: Creating DownloadItemEntity
        let entity = NSEntityDescription.entity(forEntityName: "DownloadItemEntity", in: context!)!
        let downloadItem = NSManagedObject(entity: entity, insertInto: context)
        
        // Then: Default values should be set
        let progress = downloadItem.value(forKey: "progress") as? Double
        let bytesDownloaded = downloadItem.value(forKey: "bytesDownloaded") as? Int64
        let retryCount = downloadItem.value(forKey: "retryCount") as? Int16
        
        XCTAssertEqual(progress, 0.0)
        XCTAssertEqual(bytesDownloaded, 0)
        XCTAssertEqual(retryCount, 0)
    }
    
    // MARK: - SettingsEntity Tests
    
    func testSettingsEntityCreation() {
        // Given: Core Data context
        let context = viewContext
        
        // When: Creating SettingsEntity
        let entity = NSEntityDescription.entity(forEntityName: "SettingsEntity", in: context!)!
        let settings = NSManagedObject(entity: entity, insertInto: context)
        
        // Then: Entity should be created
        XCTAssertNotNil(settings)
        XCTAssertEqual(settings.entity.name, "SettingsEntity")
    }
    
    func testSettingsEntityAttributes() {
        // Given: Core Data context
        let context = viewContext
        
        // When: Creating SettingsEntity
        let entity = NSEntityDescription.entity(forEntityName: "SettingsEntity", in: context!)!
        let settings = NSManagedObject(entity: entity, insertInto: context)
        
        // Then: All required attributes should exist
        let attributes = entity.attributesByName
        XCTAssertNotNil(attributes["id"])
        XCTAssertNotNil(attributes["defaultDownloadFolder"])
        XCTAssertNotNil(attributes["maxParallelDownloads"])
        XCTAssertNotNil(attributes["maxRetryAttempts"])
        XCTAssertNotNil(attributes["speedThrottle"])
        XCTAssertNotNil(attributes["updatedAt"])
    }
    
    func testSettingsEntityIDIsRequired() {
        // Given: Core Data context
        let context = viewContext
        
        // When: Checking entity description
        let entity = NSEntityDescription.entity(forEntityName: "SettingsEntity", in: context!)!
        let idAttribute = entity.attributesByName["id"]
        
        // Then: ID should be required (non-optional)
        XCTAssertNotNil(idAttribute)
        XCTAssertFalse(idAttribute!.isOptional)
    }
    
    func testSettingsEntityDefaultValues() {
        // Given: Core Data context
        let context = viewContext
        
        // When: Creating SettingsEntity
        let entity = NSEntityDescription.entity(forEntityName: "SettingsEntity", in: context!)!
        let settings = NSManagedObject(entity: entity, insertInto: context)
        
        // Then: Default values should be set
        let maxParallelDownloads = settings.value(forKey: "maxParallelDownloads") as? Int16
        let maxRetryAttempts = settings.value(forKey: "maxRetryAttempts") as? Int16
        let speedThrottle = settings.value(forKey: "speedThrottle") as? Int64
        
        XCTAssertEqual(maxParallelDownloads, 2)
        XCTAssertEqual(maxRetryAttempts, 3)
        XCTAssertEqual(speedThrottle, 0)
    }
    
    // MARK: - Context Save Tests
    
    func testContextSave() throws {
        // Given: Core Data context with entity
        let context = viewContext!
        let entity = NSEntityDescription.entity(forEntityName: "DownloadItemEntity", in: context)!
        let downloadItem = NSManagedObject(entity: entity, insertInto: context)
        
        // Set some values
        downloadItem.setValue(UUID(), forKey: "id")
        downloadItem.setValue("https://example.com/file.zip", forKey: "url")
        downloadItem.setValue("file.zip", forKey: "filename")
        downloadItem.setValue("queued", forKey: "status")
        
        // When: Saving context
        try context.save()
        
        // Then: Context should have no errors
        XCTAssertFalse(context.hasChanges)
    }
}

