//
//  SettingsWindowController.swift
//  timeZoneFinder
//
//  Created by ryo fujimura on 3/8/24.
//
import Cocoa

class SettingsWindowController: NSWindowController {

    var selectedTimeZones: [String] = []

    override func windowDidLoad() {
        super.windowDidLoad()
        // Set up the settings window
    }

    func showWindow() {
        if window == nil {
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 200), styleMask: [.titled, .closable], backing: .buffered, defer: false)
            window.title = "Time Zone Settings"
            let cityList = NSPopUpButton(frame: NSRect(x: 50, y: 100, width: 200, height: 30))
            cityList.addItems(withTitles: ["New York", "London", "Tokyo"]) // Add more cities as needed
            window.contentView?.addSubview(cityList)

            let addButton = NSButton(frame: NSRect(x: 50, y: 60, width: 100, height: 30))
            addButton.image = NSImage(named: NSImage.addTemplateName)
            addButton.target = self
            addButton.action = #selector(addTimeZone(_:))
            window.contentView?.addSubview(addButton)

            let removeButton = NSButton(frame: NSRect(x: 150, y: 60, width: 100, height: 30))
            removeButton.image = NSImage(named: NSImage.removeTemplateName)
            removeButton.target = self
            removeButton.action = #selector(removeTimeZone(_:))
            window.contentView?.addSubview(removeButton)

            self.window = window
        }
        self.showWindow(nil)
    }

    @objc func addTimeZone(_ sender: NSButton) {
        if let window = window, let cityList = window.contentView?.subviews.first(where: { $0 is NSPopUpButton }) as? NSPopUpButton {
            let selectedTimeZone = cityList.titleOfSelectedItem ?? ""
            if !selectedTimeZones.contains(selectedTimeZone) {
                selectedTimeZones.append(selectedTimeZone)
                (NSApp.delegate as? AppDelegate)?.updateTimeZones(selectedTimeZones)
            }
        }
    }

    @objc func removeTimeZone(_ sender: NSButton) {
        if let window = window, let cityList = window.contentView?.subviews.first(where: { $0 is NSPopUpButton }) as? NSPopUpButton {
            let selectedTimeZone = cityList.titleOfSelectedItem ?? ""
            if let index = selectedTimeZones.firstIndex(of: selectedTimeZone) {
                selectedTimeZones.remove(at: index)
                (NSApp.delegate as? AppDelegate)?.updateTimeZones(selectedTimeZones)
            }
        }
    }
}
