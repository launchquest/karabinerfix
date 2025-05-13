//
//  KarabinerProfileManager.swift
//  KarabinerFix
//
//  Created by Adam K Dean on 13/05/2025.
//

import Foundation

final class KarabinerProfileManager {
    static let shared = KarabinerProfileManager()

    private init() {}

    private let disabledProfile = "Disabled"
    private var activeProfile: String {
        get { UserDefaults.standard.string(forKey: "ActiveKarabinerProfile") ?? "Default profile" }
        set { UserDefaults.standard.set(newValue, forKey: "ActiveKarabinerProfile") }
    }

    // MARK: – Public API -----------------------------------------------------

    func disable() {
        // Cache what’s currently selected so we can restore later
        if let current = currentProfile(), current != disabledProfile {
            activeProfile = current
        }
        selectProfile(disabledProfile)
    }

    func enable() {
        selectProfile(activeProfile)
    }

    // MARK: – Internals ------------------------------------------------------

    private func currentProfile() -> String? {
        let cfg = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/karabiner/karabiner.json")
        guard
            let data = try? Data(contentsOf: cfg),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let profiles = json["profiles"] as? [[String: Any]],
            let sel = profiles.first(where: { ($0["selected"] as? Bool) == true })
        else { return nil }

        return sel["name"] as? String
    }

    private func selectProfile(_ name: String) {
        let base = UserDefaults.standard.string(forKey: "KarabinerPath")
            ?? "/Library/Application Support/org.pqrs/Karabiner-Elements/bin"
        let cli  = URL(fileURLWithPath: base).appendingPathComponent("karabiner_cli").path

        let task = Process()
        task.launchPath = cli
        task.arguments = ["--select-profile", name]
        task.launch()
    }
}
