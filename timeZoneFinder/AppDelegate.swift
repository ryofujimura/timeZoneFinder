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
    var settingsWindowController: SettingsWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Set up the status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // Start the timer to update the time every second
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateTime()
        }

        // Initialize the menu and set it as the menu for the status bar item
        menu = NSMenu()
        statusBarItem?.menu = menu

        // Add the slider to the menu
        let sliderItem = NSMenuItem()
        let slider = NSSlider(value: 0, minValue: -12, maxValue: 12, target: self, action: #selector(sliderValueChanged(_:)))
        sliderItem.view = slider
        menu?.addItem(sliderItem)
        menu?.addItem(NSMenuItem.separator())

        // Add the "Add Time Zone" option to the menu
        let addItem = NSMenuItem(title: "Add Time Zone", action: #selector(openSettings(_:)), keyEquivalent: "")
        menu?.addItem(addItem)
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

    // Function to handle changes in the slider's value
    @objc func sliderValueChanged(_ sender: NSSlider) {
        let offset = sender.intValue
        updateTimeZones(settingsWindowController?.selectedTimeZones ?? [], offset: Int(offset))
    }

    // Function to open the settings window
    @objc func openSettings(_ sender: NSMenuItem) {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController()
        }
        settingsWindowController?.showWindow()
    }

    // Function to update the menu with the selected time zones
    func updateTimeZones(_ timeZones: [String], offset: Int = 0) {
        // Remove all items except the slider and the "Add Time Zone" option
        while menu?.items.count ?? 0 > 2 {
            menu?.removeItem(at: 2)
        }

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium

        for timeZone in timeZones {
            dateFormatter.timeZone = TimeZone(identifier: timeZone)
            let adjustedDate = Calendar.current.date(byAdding: .hour, value: offset, to: Date())
            let timeString = dateFormatter.string(from: adjustedDate ?? Date())
            let menuItem = NSMenuItem(title: "\(timeZone): \(timeString)", action: nil, keyEquivalent: "")
            menu?.insertItem(menuItem, at: 2)
        }
    }
}
