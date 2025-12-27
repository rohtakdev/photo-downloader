//
//  PhotoDownloadApp.swift
//  photo-download
//
//  Created on 2025
//

import SwiftUI

@main
struct PhotoDownloadApp: App {
    @StateObject private var persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}

