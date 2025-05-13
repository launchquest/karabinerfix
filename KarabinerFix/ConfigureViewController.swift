//
//  ConfigureViewController.swift
//  KarabinerFix
//
//  Created by Adam K Dean on 13/05/2025.
//

import Cocoa
import ApplicationServices
import ServiceManagement

class ConfigureViewController: NSViewController {
    private let iconView = NSImageView()
    private let versionLabel = NSTextField(labelWithString: "")

    // Permissions
    private let accessibilityButton = NSButton(title: "", target: nil, action: nil)

    // Karabiner
    private let karabinerPathLabel = NSTextField(labelWithString: "Karabiner Binary Path:")
    private let karabinerPathField = NSTextField()
    private let browseKarabinerPathButton = NSButton(title: "Browse", target: nil, action: nil)
    private let enableKarabinerButton = NSButton(title: "Enable Karabiner", target: nil, action: nil)
    private let disableKarabinerButton = NSButton(title: "Disable Karabiner", target: nil, action: nil)
    private let configureProfileButton = NSButton(title: "Configure Disabled Profile", target: nil, action: nil)
    private let karabinerPathDefault = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin"
    
    // Startup
    private let launchAtLoginCheckbox = NSButton(checkboxWithTitle: "Launch KarabinerFix at login", target: nil, action: nil)

    // Profiles
    private let disabledProfileName = "Disabled"
    private var activeProfileName: String? {
        didSet {
            if let name = activeProfileName, name != disabledProfileName {
                UserDefaults.standard.set(name, forKey: "ActiveKarabinerProfile")
            }
        }
    }

    private var permissionCheckTimer: Timer?

    // MARK: - View Lifecycle

    override func loadView() {
        self.view = NSView()
        self.view.translatesAutoresizingMaskIntoConstraints = false

        // Icon
        let config = NSImage.SymbolConfiguration(pointSize: 40, weight: .regular)
        let icon = NSImage(systemSymbolName: "keyboard.badge.eye", accessibilityDescription: "KarabinerFix")?.withSymbolConfiguration(config)
        iconView.image = icon
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.imageScaling = .scaleProportionallyUpOrDown

        // Version
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?.?"
        versionLabel.stringValue = "KarabinerFix v\(version)\n© 2025 Adam K Dean"
        versionLabel.alignment = .center
        versionLabel.font = NSFont.systemFont(ofSize: 14)
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        versionLabel.lineBreakMode = .byWordWrapping
        versionLabel.maximumNumberOfLines = 2

        // Accessibility
        accessibilityButton.target = self
        accessibilityButton.action = #selector(openAccessibilitySettings)
        accessibilityButton.bezelStyle = .rounded
        accessibilityButton.translatesAutoresizingMaskIntoConstraints = false
        updateAccessibilityButton()

        // Karabiner Path
        karabinerPathLabel.translatesAutoresizingMaskIntoConstraints = false
        karabinerPathLabel.font = NSFont.boldSystemFont(ofSize: 13)

        karabinerPathField.translatesAutoresizingMaskIntoConstraints = false
        karabinerPathField.placeholderString = karabinerPathDefault
        karabinerPathField.stringValue = getKarabinerPath()
        karabinerPathField.isEditable = true
        karabinerPathField.lineBreakMode = .byTruncatingMiddle
        karabinerPathField.usesSingleLineMode = true
        karabinerPathField.target = self
        karabinerPathField.action = #selector(saveKarabinerPath)

        browseKarabinerPathButton.translatesAutoresizingMaskIntoConstraints = false
        browseKarabinerPathButton.bezelStyle = .rounded
        browseKarabinerPathButton.title = "Browse"
        browseKarabinerPathButton.target = self
        browseKarabinerPathButton.action = #selector(handleBrowsePath)

        // Enable/Disable buttons
        enableKarabinerButton.bezelStyle = .rounded
        enableKarabinerButton.translatesAutoresizingMaskIntoConstraints = false
        enableKarabinerButton.target = self
        enableKarabinerButton.action = #selector(enableKarabiner)

        disableKarabinerButton.bezelStyle = .rounded
        disableKarabinerButton.translatesAutoresizingMaskIntoConstraints = false
        disableKarabinerButton.target = self
        disableKarabinerButton.action = #selector(disableKarabiner)

        configureProfileButton.bezelStyle = .rounded
        configureProfileButton.translatesAutoresizingMaskIntoConstraints = false
        configureProfileButton.target = self
        configureProfileButton.action = #selector(configureDisabledProfile)
        
        launchAtLoginCheckbox.target = self
        launchAtLoginCheckbox.action = #selector(toggleLaunchAtLogin)
        launchAtLoginCheckbox.translatesAutoresizingMaskIntoConstraints = false
        launchAtLoginCheckbox.state = isLoginItemEnabled() ? .on : .off

        // Boxes
        let permissionBox = NSBox()
        permissionBox.title = "Permissions"
        permissionBox.boxType = .primary
        permissionBox.contentViewMargins = NSSize(width: 10, height: 10)
        permissionBox.translatesAutoresizingMaskIntoConstraints = false
        permissionBox.contentView = NSView()
        permissionBox.contentView?.addSubview(accessibilityButton)
        permissionBox.contentView?.addSubview(launchAtLoginCheckbox)

        let karabinerBox = NSBox()
        karabinerBox.title = "Karabiner"
        karabinerBox.boxType = .primary
        karabinerBox.contentViewMargins = NSSize(width: 10, height: 10)
        karabinerBox.translatesAutoresizingMaskIntoConstraints = false
        karabinerBox.contentView = NSView()
        karabinerBox.contentView?.addSubview(karabinerPathLabel)
        karabinerBox.contentView?.addSubview(karabinerPathField)
        karabinerBox.contentView?.addSubview(browseKarabinerPathButton)
        karabinerBox.contentView?.addSubview(enableKarabinerButton)
        karabinerBox.contentView?.addSubview(disableKarabinerButton)
        karabinerBox.contentView?.addSubview(configureProfileButton)

        // Layout
        view.addSubview(iconView)
        view.addSubview(versionLabel)
        view.addSubview(permissionBox)
        view.addSubview(karabinerBox)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            iconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 40),
            iconView.widthAnchor.constraint(equalToConstant: 40),

            versionLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 10),
            versionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            permissionBox.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 20),
            permissionBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            permissionBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            accessibilityButton.topAnchor.constraint(equalTo: permissionBox.contentView!.topAnchor, constant: 10),
            accessibilityButton.centerXAnchor.constraint(equalTo: permissionBox.contentView!.centerXAnchor),
            
            launchAtLoginCheckbox.topAnchor.constraint(equalTo: accessibilityButton.bottomAnchor, constant: 10),
            launchAtLoginCheckbox.centerXAnchor.constraint(equalTo: karabinerBox.contentView!.centerXAnchor),
            launchAtLoginCheckbox.bottomAnchor.constraint(equalTo: permissionBox.contentView!.bottomAnchor, constant: -10),

            karabinerBox.topAnchor.constraint(equalTo: permissionBox.bottomAnchor, constant: 20),
            karabinerBox.leadingAnchor.constraint(equalTo: permissionBox.leadingAnchor),
            karabinerBox.trailingAnchor.constraint(equalTo: permissionBox.trailingAnchor),

            karabinerPathLabel.topAnchor.constraint(equalTo: karabinerBox.contentView!.topAnchor, constant: 10),
            karabinerPathLabel.leadingAnchor.constraint(equalTo: karabinerBox.contentView!.leadingAnchor, constant: 10),

            karabinerPathField.topAnchor.constraint(equalTo: karabinerPathLabel.bottomAnchor, constant: 5),
            karabinerPathField.leadingAnchor.constraint(equalTo: karabinerBox.contentView!.leadingAnchor, constant: 10),
            karabinerPathField.trailingAnchor.constraint(equalTo: browseKarabinerPathButton.leadingAnchor, constant: -8),

            browseKarabinerPathButton.centerYAnchor.constraint(equalTo: karabinerPathField.centerYAnchor),
            browseKarabinerPathButton.trailingAnchor.constraint(equalTo: karabinerBox.contentView!.trailingAnchor, constant: -10),

            enableKarabinerButton.topAnchor.constraint(equalTo: karabinerPathField.bottomAnchor, constant: 15),
            enableKarabinerButton.trailingAnchor.constraint(equalTo: karabinerBox.contentView!.centerXAnchor, constant: -5),

            disableKarabinerButton.centerYAnchor.constraint(equalTo: enableKarabinerButton.centerYAnchor),
            disableKarabinerButton.leadingAnchor.constraint(equalTo: karabinerBox.contentView!.centerXAnchor, constant: 5),

            configureProfileButton.topAnchor.constraint(equalTo: enableKarabinerButton.bottomAnchor, constant: 15),
            configureProfileButton.centerXAnchor.constraint(equalTo: karabinerBox.contentView!.centerXAnchor),
            configureProfileButton.bottomAnchor.constraint(equalTo: karabinerBox.contentView!.bottomAnchor, constant: -10)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeActiveProfile()
        updateKarabinerButtons()
        updateConfigureProfileButton()
        startPermissionCheckTimer()
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        stopPermissionCheckTimer()
        saveKarabinerPath()
    }

    // MARK: - Timers

    private func startPermissionCheckTimer() {
        permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.updateAccessibilityButton()
            self?.updateKarabinerButtons()
            self?.updateConfigureProfileButton()
        }
    }

    private func stopPermissionCheckTimer() {
        permissionCheckTimer?.invalidate()
        permissionCheckTimer = nil
    }

    // MARK: - UI Updates

    private func updateAccessibilityButton() {
        let trusted = AXIsProcessTrusted()
        accessibilityButton.title = trusted ? "Accessibility access granted" : "Grant Accessibility Access"
        accessibilityButton.isEnabled = !trusted
    }

    private func updateKarabinerButtons() {
        guard let currentProfile = readCurrentKarabinerProfile() else {
            enableKarabinerButton.isEnabled = false
            disableKarabinerButton.isEnabled = false
            return
        }

        if currentProfile != disabledProfileName {
            activeProfileName = currentProfile
        }

        enableKarabinerButton.isEnabled = currentProfile == disabledProfileName
        disableKarabinerButton.isEnabled = currentProfile != disabledProfileName
    }

    private func updateConfigureProfileButton() {
        configureProfileButton.isEnabled = !disabledProfileExists()
    }

    // MARK: - Profile Handling

    private func initializeActiveProfile() {
        if let stored = UserDefaults.standard.string(forKey: "ActiveKarabinerProfile") {
            activeProfileName = stored
        } else if let current = readCurrentKarabinerProfile(), current != disabledProfileName {
            activeProfileName = current
        }
    }

    private func readCurrentKarabinerProfile() -> String? {
        let configPath = NSHomeDirectory() + "/.config/karabiner/karabiner.json"
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath)),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let profiles = json["profiles"] as? [[String: Any]],
              let selected = profiles.first(where: { ($0["selected"] as? Bool) == true }),
              let name = selected["name"] as? String else {
            return nil
        }
        return name
    }

    private func disabledProfileExists() -> Bool {
        let configPath = NSHomeDirectory() + "/.config/karabiner/karabiner.json"
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: configPath)),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let profiles = json["profiles"] as? [[String: Any]] else {
            return false
        }
        return profiles.contains(where: { ($0["name"] as? String) == disabledProfileName })
    }

    // MARK: - User Defaults

    private func getKarabinerPath() -> String {
        let saved = UserDefaults.standard.string(forKey: "KarabinerPath")
        return saved?.isEmpty == false ? saved! : karabinerPathDefault
    }

    @objc private func saveKarabinerPath() {
        let trimmed = karabinerPathField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaults.standard.set(trimmed, forKey: "KarabinerPath")
        print("[KarabinerFix] Saved path: \(trimmed)")
    }

    // MARK: - Accessibility

    @objc private func openAccessibilitySettings() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Access Required"
        alert.informativeText = "KarabinerFix needs Accessibility permission to monitor screen lock and unlock events."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open Settings")
        alert.addButton(withTitle: "Cancel")

        guard alert.runModal() == .alertFirstButtonReturn else { return }

        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)

        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Path Browsing

    @objc private func handleBrowsePath() {
        let panel = NSOpenPanel()
        panel.title = "Select Karabiner Binary"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.directoryURL = URL(fileURLWithPath: karabinerPathDefault)

        panel.begin { response in
            if response == .OK, let url = panel.url {
                self.karabinerPathField.stringValue = url.path
                self.saveKarabinerPath()
            }
        }
    }

    // MARK: - Enable / Disable Actions

    @objc private func enableKarabiner() {
        KarabinerProfileManager.shared.enable()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.updateKarabinerButtons() }
    }

    @objc private func disableKarabiner() {
        KarabinerProfileManager.shared.disable()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.updateKarabinerButtons() }
    }

    @objc private func configureDisabledProfile() {
        let alert = NSAlert()
        alert.messageText = "Configure Disabled Profile"
        alert.informativeText = "This will create a 'Disabled' profile by copying your current profile and ignoring all attached devices."
        alert.addButton(withTitle: "Continue")
        alert.addButton(withTitle: "Cancel")
        guard alert.runModal() == .alertFirstButtonReturn else { return }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        let timestamp = dateFormatter.string(from: Date())
        let configPath = NSHomeDirectory() + "/.config/karabiner/karabiner.json"
        let backupPath = "\(configPath).\(timestamp).bak"

        do {
            print("[KarabinerFix] Looking for config at: \(configPath)")
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: configPath))
            guard var config = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                  var profiles = config["profiles"] as? [[String: Any]] else {
                showError("Could not parse profiles from configuration file.")
                return
            }

            // Backup
            try FileManager.default.copyItem(atPath: configPath, toPath: backupPath)

            // Find selected profile
            guard let selected = profiles.first(where: { ($0["selected"] as? Bool) == true }),
                  let devices = selected["devices"] as? [[String: Any]] else {
                showError("Could not locate active profile or device data.")
                return
            }

            let ignoredDevices = devices.map { device -> [String: Any] in
                var modified = device
                modified["ignore"] = true
                return modified
            }

            var newProfile = selected
            newProfile["name"] = disabledProfileName
            newProfile["selected"] = false
            newProfile["devices"] = ignoredDevices
            profiles.append(newProfile)
            config["profiles"] = profiles

            let output = try JSONSerialization.data(withJSONObject: config, options: [.prettyPrinted, .sortedKeys])
            try output.write(to: URL(fileURLWithPath: configPath), options: .atomic)

            let successAlert = NSAlert()
            successAlert.messageText = "Disabled profile added"
            successAlert.informativeText = "You can now switch to the Disabled profile via the KarabinerFix menu."
            successAlert.runModal()

            updateConfigureProfileButton()

        } catch {
            showError("Failed to configure disabled profile: \(error.localizedDescription)")
        }
    }

    // MARK: - Utility

    private func runKarabinerCLI(arguments: [String]) {
        let path = (karabinerPathField.stringValue as NSString).appendingPathComponent("karabiner_cli")
        let task = Process()
        task.launchPath = path
        task.arguments = arguments
        task.launch()
    }

    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Error"
        alert.informativeText = message
        alert.alertStyle = .critical
        alert.runModal()
    }
    
    @objc private func toggleLaunchAtLogin(_ sender: NSButton) {
        let enable = sender.state == .on
        do {
            if enable {
                try SMAppService.mainApp.register()
                print("[KarabinerFix] Registered for login")
            } else {
                try SMAppService.mainApp.unregister()
                print("[KarabinerFix] Unregistered from login")
            }
        } catch {
            showError("Failed to update login item: \(error.localizedDescription)")
            sender.state = isLoginItemEnabled() ? .on : .off
        }
    }

    private func isLoginItemEnabled() -> Bool {
        SMAppService.mainApp.status == .enabled
    }
}
