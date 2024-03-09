//
//  AppDelegate.swift
//  timeZoneFinder
//
//  Created by ryo fujimura on 3/8/24.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusBarItem: NSStatusItem?
    var menu: NSMenu?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Set up the status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem?.button?.title = "Loading..."

        // Start the timer to update the time every second
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateTime()
        }

        // Initialize the menu and set it as the menu for the status bar item
        menu = NSMenu()
        statusBarItem?.menu = menu

        // Add time zones to the menu
        addTimeZones()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    // Function to update the time displayed in the status bar
    func updateTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        statusBarItem?.button?.title = dateFormatter.string(from: Date())
    }

    // Function to add time zone menu items to the menu
    func addTimeZones() {
        let sliderItem = NSMenuItem()
        let slider = NSSlider(value: 0, minValue: -12, maxValue: 12, target: self, action: #selector(sliderValueChanged(_:)))
        sliderItem.view = slider
        menu?.addItem(sliderItem)
        menu?.addItem(NSMenuItem.separator())

        let timeZones = ["New York": "America/New_York", "London": "Europe/London", "Tokyo": "Asia/Tokyo"]
        
        for (name, identifier) in timeZones {
            let menuItem = NSMenuItem(title: name, action: #selector(showTimeZone(_:)), keyEquivalent: "")
            menuItem.representedObject = identifier
            menu?.addItem(menuItem)
        }
    }

    // Function to handle the selection of a time zone menu item
    @objc func showTimeZone(_ sender: NSMenuItem) {
        if let timeZoneIdentifier = sender.representedObject as? String {
            let offset = (menu?.item(at: 0)?.view as? NSSlider)?.intValue ?? 0
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .medium
            dateFormatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
            
            let adjustedDate = Calendar.current.date(byAdding: .hour, value: Int(offset), to: Date())
            let timeString = dateFormatter.string(from: adjustedDate ?? Date())
            statusBarItem?.button?.title = "\(sender.title.components(separatedBy: ":").first ?? ""): \(timeString)"
        }
    }

    // Function to handle changes in the slider's value
    @objc func sliderValueChanged(_ sender: NSSlider) {
        let offset = sender.intValue
        updateMenuItems(withOffset: Int(offset))
    }

    // Function to update the menu items with the adjusted time
    func updateMenuItems(withOffset offset: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        
        for item in menu?.items ?? [] {
            guard let identifier = item.representedObject as? String else { continue }
            dateFormatter.timeZone = TimeZone(identifier: identifier)
            
            let adjustedDate = Calendar.current.date(byAdding: .hour, value: Int(offset), to: Date())
            let timeString = dateFormatter.string(from: adjustedDate ?? Date())
            item.title = "\(item.title.components(separatedBy: ":").first ?? ""): \(timeString)"
        }
    }
}

