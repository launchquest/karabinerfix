//
//  AppDelegate.swift
//  KarabinerFix
//
//  Created by Adam K Dean on 13/05/2025.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var configWindow: ConfigureWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide Dock icon
        NSApp.setActivationPolicy(.accessory)

        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)
            let icon = NSImage(systemSymbolName: "keyboard.badge.eye", accessibilityDescription: "KarabinerFix")?.withSymbolConfiguration(config)
            button.image = icon
            button.imagePosition = .imageOnly
        }

        // Create the menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Configure", action: #selector(configure), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem?.menu = menu
        
        // Listen for screen lock/unlock events
        let dnc = DistributedNotificationCenter.default()
        dnc.addObserver(self,
                        selector: #selector(handleScreenLocked),
                        name: NSNotification.Name("com.apple.screenIsLocked"),
                        object: nil)
        dnc.addObserver(self,
                        selector: #selector(handleScreenUnlocked),
                        name: NSNotification.Name("com.apple.screenIsUnlocked"),
                        object: nil)
    }
    
    @objc func configure() {
        print("[KarabinerFix] Configure window opened")
        
        if configWindow == nil {
            configWindow = ConfigureWindowController()
        }
        configWindow?.showWindow(nil)
        configWindow?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func handleScreenLocked(_ notification: Notification) {
        print("[KarabinerFix] Screen locked → switching to Disabled profile")
        KarabinerProfileManager.shared.disable()
    }

    @objc func handleScreenUnlocked(_ notification: Notification) {
        print("[KarabinerFix] Screen unlocked → restoring user profile")
        KarabinerProfileManager.shared.enable()
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }
}
