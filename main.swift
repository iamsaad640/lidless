import AppKit
import IOKit
import ServiceManagement

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let menu = NSMenu()
    private let loginItem = NSMenuItem(title: "Open at Login", action: #selector(AppDelegate.toggleLoginItem), keyEquivalent: "")
    private let pmRoot = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPMrootDomain"))

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Only auto-register once, so turning it off from the menu or System Settings sticks.
        if !UserDefaults.standard.bool(forKey: "loginItemConfigured") {
            try? SMAppService.mainApp.register()
            UserDefaults.standard.set(true, forKey: "loginItemConfigured")
        }
        loginItem.target = self
        menu.addItem(loginItem)
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Sleep Toggle", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        item.button?.target = self
        item.button?.action = #selector(clicked)
        item.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        refresh()
        // pmset can be changed from the terminal too, so keep the icon in sync.
        let timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(refresh), userInfo: nil, repeats: true)
        timer.tolerance = 10
    }

    @objc private func clicked() {
        if NSApp.currentEvent?.type == .rightMouseUp {
            loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
            item.menu = menu
            item.button?.performClick(nil)
            item.menu = nil
            return
        }
        let disable = !sleepDisabled()
        let result = run("/usr/bin/sudo", ["-n", "/usr/bin/pmset", "disablesleep", disable ? "1" : "0"])
        if result.status != 0 {
            let alert = NSAlert()
            alert.messageText = "Couldn't change sleep setting"
            alert.informativeText = "sudo needs a NOPASSWD rule for pmset in /etc/sudoers.d/pmset.\n\n\(result.output)"
            NSApp.activate(ignoringOtherApps: true)
            alert.runModal()
            refresh()
            return
        }
        // powerd updates the kernel flag asynchronously, so trust the successful pmset exit.
        render(disabled: disable)
    }

    @objc private func toggleLoginItem() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Couldn't change login item"
            alert.informativeText = error.localizedDescription
            NSApp.activate(ignoringOtherApps: true)
            alert.runModal()
        }
    }

    @objc private func refresh() {
        render(disabled: sleepDisabled())
    }

    private func render(disabled: Bool) {
        item.button?.image = NSImage(
            systemSymbolName: disabled ? "cup.and.saucer.fill" : "moon.zzz.fill",
            accessibilityDescription: disabled ? "Sleep disabled" : "Sleep enabled"
        )
        item.button?.toolTip = disabled ? "Sleep disabled — click to allow sleep" : "Sleep allowed — click to disable"
    }

    private func sleepDisabled() -> Bool {
        let value = IORegistryEntryCreateCFProperty(pmRoot, "SleepDisabled" as CFString, kCFAllocatorDefault, 0)?.takeRetainedValue()
        return (value as? Bool) ?? false
    }

    private func run(_ path: String, _ args: [String]) -> (status: Int32, output: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: path)
        process.arguments = args
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        do { try process.run() } catch { return (-1, error.localizedDescription) }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return (process.terminationStatus, String(decoding: data, as: UTF8.self))
    }
}

MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory)
    app.run()
}
