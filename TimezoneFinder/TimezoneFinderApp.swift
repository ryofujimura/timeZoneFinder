//
//  TimezoneFinderApp.swift
//  TimezoneFinder
//
//  Created by ryo fujimura on 3/25/24.
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
    var statusBarItem: NSStatusItem!
    var popover: NSPopover?
    private var eventMonitor: EventMonitor?

    var cityDataModel = CityDataViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBarItem()
        setupPopover()
        setupEventMonitor()
    }
    
    private func setupStatusBarItem() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusBarItem.button {
            button.title = "☁" // Consider making this title more descriptive or configurable
            button.action = #selector(togglePopover(_:))
        }
    }

    private func setupPopover() {
        let contentView = ContentView().environmentObject(cityDataModel)
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 416, height: 416)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: contentView)
    }

    private func setupEventMonitor() {
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover?.isShown ?? false {
                strongSelf.closePopover(event)
            }
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if popover?.isShown == true {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    private func showPopover(_ sender: AnyObject?) {
        if let button = statusBarItem.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            eventMonitor?.start()
        }
    }
    
    private func closePopover(_ sender: AnyObject?) {
        popover?.performClose(sender)
        eventMonitor?.stop()
        cityDataModel.settingsView = true
    }
}


class EventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void

    init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }

    deinit {
        stop()
    }

    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }

    func stop() {
        if monitor != nil {
            NSEvent.removeMonitor(monitor!)
            monitor = nil
        }
    }
}
