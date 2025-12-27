//
//  PersistenceController.swift
//  photo-download
//
//  Created on 2025
//

import CoreData
import Foundation
import Combine
import os.log

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        // Add preview data here if needed
        return controller
    }()
    
    let container: NSPersistentContainer
    private(set) var loadError: Error?
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PhotoDownloadModel")
        
        if inMemory {
            // Configure for in-memory store
            let description = container.persistentStoreDescriptions.first!
            description.type = NSInMemoryStoreType
            description.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Configure persistent store
            let storeURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent("PhotoDownload.sqlite")
            
            if let storeURL = storeURL {
                container.persistentStoreDescriptions.first?.url = storeURL
            }
        }
        
        // Load persistent stores
        let semaphore = DispatchSemaphore(value: 0)
        
        container.loadPersistentStores { description, error in
            self.loadError = error
            if let error = error {
                Logger.persistence.error("Core Data store failed to load: \(error.localizedDescription)")
                Logger.persistence.error("Error details: \(String(describing: error))")
                if let nsError = error as NSError? {
                    Logger.persistence.error("Domain: \(nsError.domain), Code: \(nsError.code)")
                    Logger.persistence.error("UserInfo: \(nsError.userInfo)")
                    // Print to stderr so it shows in test output
                    let errorMsg = """
                    ❌ Core Data Error: \(nsError.localizedDescription)
                       Domain: \(nsError.domain), Code: \(nsError.code)
                    """
                    FileHandle.standardError.write(Data(errorMsg.utf8))
                    if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
                        let underlyingMsg = "\n   Underlying: \(underlyingError.localizedDescription)\n"
                        FileHandle.standardError.write(Data(underlyingMsg.utf8))
                    }
                }
            }
            semaphore.signal()
        }
        
        // Wait for load to complete (synchronously for initialization)
        semaphore.wait()
        
        // Only fatalError if not in test environment
        if let error = loadError {
            // Check if we're in a test environment
            let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
            if isTesting {
                // In tests, log the error but don't fatalError - let tests handle it
                Logger.persistence.error("Core Data failed in test - test will fail when accessing container")
            } else {
                fatalError("Core Data store failed to load: \(error.localizedDescription)")
            }
        }
        
        // Configure view context for automatic merging
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

