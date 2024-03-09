//
//  StatusBarController.swift
//  timeZoneFinder
//
//  Created by ryo fujimura on 3/8/24.
//

import Cocoa

class StatusBarController: NSObject {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var menu: NSMenu

    override init() {
        statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        menu = NSMenu()

        super.init()

        if let statusBarButton = statusItem.button {
            statusBarButton.title = "Time Zone"
        }

        let timeZoneItem = NSMenuItem(title: "Show Time Zone", action: #selector(showTimeZone), keyEquivalent: "")
        timeZoneItem.target = self
        menu.addItem(timeZoneItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc func showTimeZone() {
        // Implement your logic to show the time zone
        print("Show Time Zone")
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
}
