//
//  ContentView.swift
//  photo-download
//
//  Created on 2025
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Photo Download Manager")
                .font(.largeTitle)
                .padding()
            
            Text("Foundation layer initialized")
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

