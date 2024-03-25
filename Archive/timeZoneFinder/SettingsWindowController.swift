//
//  SettingsWindowController.swift
//  timeZoneFinder
//
//  Created by ryo fujimura on 3/8/24.
//

import Cocoa

class SettingsWindowController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate {

    var selectedTimeZones: [String] = []
    var tableView: NSTableView!

    override func windowDidLoad() {
        super.windowDidLoad()
        // Set up the settings window
    }

    func showWindow() {
        if window == nil {
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 400, height: 400), styleMask: [.titled, .closable], backing: .buffered, defer: false)
            window.title = "Time Zone Settings"
            window.appearance = NSAppearance(named: .vibrantDark)

            let scrollView = NSScrollView(frame: NSRect(x: 0, y: 50, width: 400, height: 350))
            tableView = NSTableView(frame: scrollView.bounds)
            tableView.dataSource = self
            tableView.delegate = self

            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "TimeZoneColumn"))
            column.title = "Time Zones"
            tableView.addTableColumn(column)

            scrollView.documentView = tableView
            scrollView.hasVerticalScroller = true
            window.contentView?.addSubview(scrollView)

            let addButton = NSButton(frame: NSRect(x: 50, y: 10, width: 100, height: 30))
            addButton.title = "Add"
            addButton.target = self
            addButton.action = #selector(addTimeZone(_:))
            window.contentView?.addSubview(addButton)

            let removeButton = NSButton(frame: NSRect(x: 250, y: 10, width: 100, height: 30))
            removeButton.title = "Remove"
            removeButton.target = self
            removeButton.action = #selector(removeTimeZone(_:))
            window.contentView?.addSubview(removeButton)

            self.window = window
        }
        self.showWindow(nil)
    }

    @objc func addTimeZone(_ sender: NSButton) {
        let timeZoneNames = TimeZone.knownTimeZoneIdentifiers.map { timeZoneIdentifier -> String in
            let timeZone = TimeZone(identifier: timeZoneIdentifier)!
            let abbreviation = timeZone.abbreviation() ?? ""
            let offset = timeZone.secondsFromGMT() / 3600
            let sign = offset >= 0 ? "+" : ""
            let cityAndCountry = timeZoneIdentifier.components(separatedBy: "/").dropFirst().joined(separator: ", ")
            return "\(abbreviation) \(sign)\(offset) - \(cityAndCountry)"
        }

        let alert = NSAlert()
        alert.messageText = "Select a Time Zone"
        let comboBox = NSComboBox(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        comboBox.addItems(withObjectValues: timeZoneNames)
        comboBox.completes = true
        alert.accessoryView = comboBox
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        let response = alert.runModal()
        if response == .alertFirstButtonReturn, let selection = comboBox.objectValueOfSelectedItem as? String, let selectedTimeZone = selection.components(separatedBy: " - ").last, !selectedTimeZone.isEmpty, !selectedTimeZones.contains(selectedTimeZone) {
            selectedTimeZones.append(selectedTimeZone)
            tableView.reloadData()
            (NSApp.delegate as? AppDelegate)?.updateTimeZones(selectedTimeZones)
        }
    }

    @objc func removeTimeZone(_ sender: NSButton) {
        let selectedRow = tableView.selectedRow
        if selectedRow >= 0 {
            selectedTimeZones.remove(at: selectedRow)
            tableView.reloadData()
            (NSApp.delegate as? AppDelegate)?.updateTimeZones(selectedTimeZones)
        }
    }

    // MARK: - NSTableViewDataSource

    func numberOfRows(in tableView: NSTableView) -> Int {
        return selectedTimeZones.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let timeZoneIdentifier = selectedTimeZones[row]
        return (NSApp.delegate as? AppDelegate)?.formatTimeZoneName(timeZoneIdentifier: timeZoneIdentifier, withOffset: 0)
    }

    // MARK: - NSTableViewDelegate

    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
}
