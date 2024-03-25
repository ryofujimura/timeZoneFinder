//
//  TimezoneFinderApp.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 3/25/24.
//

import SwiftUI
import AppKit

@main
struct TimezoneFinderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.setContentSize(NSSize(width: 500, height: 123)) // Initial size
            window.minSize = NSSize(width: 500, height: 123) // Minimum size
            window.maxSize = NSSize(width: 500, height: 123) // Minimum 
        }
    }
}

//    .frame(width: 500, height: 123)
