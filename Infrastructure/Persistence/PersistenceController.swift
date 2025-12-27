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
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PhotoDownloadModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Configure persistent store
            let storeURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent("PhotoDownload.sqlite")
            
            if let storeURL = storeURL {
                container.persistentStoreDescriptions.first?.url = storeURL
            }
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application.
                Logger.persistence.error("Core Data store failed to load: \(error.localizedDescription)")
                fatalError("Core Data store failed to load: \(error.localizedDescription)")
            }
        }
        
        // Configure view context for automatic merging
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

