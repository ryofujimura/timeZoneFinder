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
    var sliderItem: NSMenuItem?
    var currentTimeButton: NSButton?
    var defaultTimeZones = ["Europe/London", "Asia/Tokyo", "America/Los_Angeles"]
    var isSliderAdjusted = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Set up the status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // Start the timer to update the time every second
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateTime()
        }

        // Initialize the menu and set it as the menu for the status bar item
        menu = NSMenu()
        menu?.appearance = NSAppearance(named: .darkAqua) // Dark theme for the menu
        statusBarItem?.menu = menu

        // Add default time zones to the menu
        updateTimeZones(defaultTimeZones)

        // Add the "Add Time Zone" option to the menu
        let addItem = NSMenuItem(title: "Add Time Zone", action: #selector(openSettings(_:)), keyEquivalent: "")
        menu?.addItem(addItem)

        // Initialize the settings window controller with default time zones
        settingsWindowController = SettingsWindowController()
        settingsWindowController?.selectedTimeZones = defaultTimeZones
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

    // Function to open the settings window
    @objc func openSettings(_ sender: NSMenuItem) {
        settingsWindowController?.showWindow()
    }

    // Function to update the menu with the selected time zones
    func updateTimeZones(_ timeZones: [String], offset: Int = 0) {
        menu?.removeAllItems()

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium

        for timeZone in timeZones {
            dateFormatter.timeZone = TimeZone(identifier: timeZone)
            let adjustedDate = Calendar.current.date(byAdding: .hour, value: offset, to: Date())
            let timeString = dateFormatter.string(from: adjustedDate ?? Date())
            let menuItemTitle = formatTimeZoneName(timeZoneIdentifier: timeZone, withOffset: offset)
            let menuItem = NSMenuItem(title: "\(menuItemTitle): \(timeString)", action: nil, keyEquivalent: "")
            menu?.addItem(menuItem)
        }

        // Add the slider if there are time zones selected
        if !timeZones.isEmpty {
            if sliderItem == nil {
                sliderItem = NSMenuItem()
                let slider = NSSlider(value: 0, minValue: -12, maxValue: 12, target: self, action: #selector(sliderValueChanged(_:)))
                slider.isEnabled = false // Disable the slider initially
                sliderItem!.view = slider
            }
            menu?.addItem(sliderItem!)
        }

        // Add the "Current Time" button if the slider is adjusted
        if isSliderAdjusted {
            if currentTimeButton == nil {
                currentTimeButton = NSButton(title: "Current Time", target: self, action: #selector(resetTime(_:)))
                currentTimeButton!.setButtonType(.momentaryLight)
                currentTimeButton!.bezelStyle = .rounded
                currentTimeButton!.frame = NSRect(x: 0, y: 0, width: 100, height: 20)
            }
            let currentTimeItem = NSMenuItem()
            currentTimeItem.view = currentTimeButton
            menu?.addItem(currentTimeItem)
        }

        // Add the "Add Time Zone" option back to the menu
        menu?.addItem(NSMenuItem.separator())
        let addItem = NSMenuItem(title: "Add Time Zone", action: #selector(openSettings(_:)), keyEquivalent: "")
        menu?.addItem(addItem)
    }

    // Function to handle changes in the slider's value
    @objc func sliderValueChanged(_ sender: NSSlider) {
        let offset = sender.intValue
        isSliderAdjusted = offset != 0
        updateTimeZones(settingsWindowController?.selectedTimeZones ?? defaultTimeZones, offset: Int(offset))
    }

    // Function to reset the time to the current time
    @objc func resetTime(_ sender: NSButton) {
        if let slider = sliderItem?.view as? NSSlider {
            slider.intValue = 0
            isSliderAdjusted = false
            sliderValueChanged(slider)
        }
    }

    // Function to format the time zone name according to the specified format
    func formatTimeZoneName(timeZoneIdentifier: String, withOffset offset: Int) -> String {
        guard let timeZone = TimeZone(identifier: timeZoneIdentifier) else { return timeZoneIdentifier }
        let timeZoneAbbr = timeZone.abbreviation() ?? ""
        let offsetHours = (timeZone.secondsFromGMT() + (offset * 3600)) / 3600
        let sign = offsetHours >= 0 ? "+" : ""
        let cityAndCountry = timeZoneIdentifier.components(separatedBy: "/").dropFirst().joined(separator: ", ")
        return "\(timeZoneAbbr) \(sign)\(offsetHours) - \(cityAndCountry)"
    }
}
