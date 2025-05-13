//
//  ConfigureWindowController.swift
//  KarabinerFix
//
//  Created by Adam K Dean on 13/05/2025.
//

import Cocoa
import ApplicationServices

class ConfigureWindowController: NSWindowController {
    convenience init() {
        let vc = ConfigureViewController()
        let window = NSWindow(contentViewController: vc)
        window.title = "KarabinerFix Configuration"
        window.styleMask = [.titled, .closable]
        window.setContentSize(NSSize(width: 420, height: 435))
        window.center()
        self.init(window: window)
    }
}
