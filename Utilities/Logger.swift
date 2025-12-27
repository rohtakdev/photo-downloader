//
//  Logger.swift
//  photo-download
//
//  Created on 2024
//

import Foundation
import os.log

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier ?? "com.photodownload.app"
    
    // Category-based loggers
    static let persistence = Logger(subsystem: subsystem, category: "Persistence")
    static let download = Logger(subsystem: subsystem, category: "Download")
    static let network = Logger(subsystem: subsystem, category: "Network")
    static let ui = Logger(subsystem: subsystem, category: "UI")
    static let application = Logger(subsystem: subsystem, category: "Application")
    static let error = Logger(subsystem: subsystem, category: "Error")
}

