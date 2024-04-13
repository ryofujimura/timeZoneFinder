//
//  TimezoneFinderApp.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 3/25/24.
//
//

import SwiftUI

@main
struct TimezoneFinderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var contentView: ContentView?  // Hold ContentView as an optional

    
    func applicationDidFinishLaunching(_ notification: Notification) {
        initializePopover()
    }

    func initializePopover() {
        contentView = ContentView()  // Instantiate ContentView

        popover = NSPopover()
        popover.contentSize = NSSize(width: 416, height: 416)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView!)
        
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Open app")
            button.action = #selector(togglePopover(_:))
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusBarItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                // Reset the view every time before showing the popover
                contentView = ContentView()
                let hostingController = NSHostingController(rootView: contentView!)
                popover.contentViewController = hostingController
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                
                // Make the popover the active and key window
                NSApplication.shared.activate(ignoringOtherApps: true)
                hostingController.view.window?.makeKey()
            }
        }
    }

}

