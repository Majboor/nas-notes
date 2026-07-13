import Cocoa
import WebKit

// Notes store — override with NAS_NOTES_DIR; defaults to ~/.rpidrive/notes.
let NOTES_DIR: String = {
    let env = ProcessInfo.processInfo.environment["NAS_NOTES_DIR"] ?? ""
    return ((env.isEmpty ? "~/.rpidrive/notes" : env) as NSString).expandingTildeInPath
}()
let CTD = NOTES_DIR + "/NAS.ctd"
let CHERRYTREE = "/opt/homebrew/bin/cherrytree"

struct Note { let name: String; let title: String; let body: String }

func loadNotes() -> [Note] {
    let fm = FileManager.default
    let preferred = ["NAS", "email"]
    let files = ((try? fm.contentsOfDirectory(atPath: NOTES_DIR)) ?? []).filter { $0.hasSuffix(".md") }
    func loadOne(_ base: String) -> Note? {
        let path = NOTES_DIR + "/" + base + ".md"
        guard let body = try? String(contentsOfFile: path, encoding: .utf8) else { return nil }
        var title = base
        for raw in body.split(separator: "\n") {
            let line = raw.trimmingCharacters(in: .whitespaces)
            if line.hasPrefix("# ") { title = String(line.dropFirst(2)); break }
        }
        return Note(name: base, title: title, body: body)
    }
    var notes: [Note] = []; var used = Set<String>()
    for base in preferred where files.contains(base + ".md") {
        if let n = loadOne(base) { notes.append(n); used.insert(base + ".md") }
    }
    for f in files.sorted() where !used.contains(f) {
        if let n = loadOne(String(f.dropLast(3))) { notes.append(n) }
    }
    return notes
}

func jsonString(_ s: String) -> String {
    let data = try! JSONSerialization.data(withJSONObject: [s], options: [])
    var str = String(data: data, encoding: .utf8)!
    str.removeFirst(); str.removeLast()   // strip the [ ]
    return str
}

final class AppDelegate: NSObject, NSApplicationDelegate, WKScriptMessageHandler, NSPopoverDelegate {
    var statusItem: NSStatusItem!
    let popover = NSPopover()
    var web: WKWebView!
    var notes: [Note] = []
    let clips = ClipStore()
    var clipTimer: Timer?

    func applicationDidFinishLaunching(_ n: Notification) {
        NSAppleEventManager.shared().setEventHandler(
            self, andSelector: #selector(handleURLEvent(_:reply:)),
            forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let b = statusItem.button {
            if let img = NSImage(systemSymbolName: "note.text", accessibilityDescription: "NAS notes") {
                img.isTemplate = true; b.image = img
                b.imagePosition = .imageLeading
            }
            b.title = " NAS"
            b.target = self; b.action = #selector(toggle(_:))
        }
        let cfg = WKWebViewConfiguration()
        cfg.userContentController.add(self, name: "bridge")
        web = WKWebView(frame: NSRect(x: 0, y: 0, width: 600, height: 680), configuration: cfg)
        let vc = NSViewController(); vc.view = web
        popover.contentViewController = vc
        popover.contentSize = NSSize(width: 600, height: 680)
        popover.behavior = .transient
        popover.delegate = self
        // watch the clipboard in the background so history accumulates even when the panel is closed
        clipTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in self?.clips.poll() }
        render()
    }

    func render(view: String = "home", active: Int = 0) {
        notes = loadNotes()
        let items = notes.map { "{name:\(jsonString($0.name)),title:\(jsonString($0.title)),body:\(jsonString($0.body))}" }.joined(separator: ",")
        let idx = (active >= 0 && active < notes.count) ? active : 0
        let html = htmlTemplate
            .replacingOccurrences(of: "/*__NOTES__*/", with: "[\(items)]")
            .replacingOccurrences(of: "/*__CLIPS__*/", with: clips.injectJSON())
            .replacingOccurrences(of: "/*__VIEW__*/", with: view)
            .replacingOccurrences(of: "/*__ACTIVE__*/", with: String(idx))
        web.loadHTMLString(html, baseURL: nil)
    }

    // Open the popover focused on a given note (by file name or tab title). Used by the per-note Spotlight apps.
    func showNote(named name: String) {
        let want = name.lowercased()
        notes = loadNotes()
        let idx = notes.firstIndex { $0.name.lowercased() == want || $0.title.lowercased() == want } ?? 0
        render(view: "note", active: idx)
        openPopover()
    }

    func openPopover() {
        NSApp.activate(ignoringOtherApps: true)
        if let b = statusItem.button {
            if popover.isShown { popover.performClose(nil) }
            popover.show(relativeTo: b.bounds, of: b, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKeyAndOrderFront(nil)
        }
    }

    // Persist edits, then regenerate the CherryTree doc + Spotlight launchers in the background.
    func rebuild() {
        let sh = NOTES_DIR + "/rebuild.sh"
        guard FileManager.default.isExecutableFile(atPath: sh) else { return }
        let p = Process(); p.executableURL = URL(fileURLWithPath: "/bin/bash"); p.arguments = [sh]
        try? p.run()
    }

    // custom URL scheme: nasnote://<name>
    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, reply: NSAppleEventDescriptor) {
        guard let s = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URLComponents(string: s) else { return }
        let name = url.host ?? url.path.replacingOccurrences(of: "/", with: "")
        showNote(named: name)
    }

    @objc func toggle(_ sender: Any?) {
        if popover.isShown { popover.performClose(sender); return }
        render(view: "home")   // reload notes each open so edits show up
        openPopover()
    }

    func userContentController(_ u: WKUserContentController, didReceive m: WKScriptMessage) {
        guard let body = m.body as? [String: Any], let action = body["action"] as? String else { return }
        switch action {
        case "copy":
            let text = (body["text"] as? String) ?? ""
            let pb = NSPasteboard.general; pb.clearContents(); pb.setString(text, forType: .string)
            notify("Copied", "Handover prompt copied to clipboard")
        case "cherrytree":
            openCherryTree()
        case "reveal":
            NSWorkspace.shared.selectFile(CTD, inFileViewerRootedAtPath: NOTES_DIR)
        case "edit":
            let name = (body["name"] as? String) ?? "NAS"
            NSWorkspace.shared.open(URL(fileURLWithPath: NOTES_DIR + "/" + name + ".md"))
        case "save":
            guard let name = body["name"] as? String, !name.isEmpty,
                  let text = body["text"] as? String ?? body["body"] as? String else { break }
            let safe = name.replacingOccurrences(of: "/", with: "-")
            try? FileManager.default.createDirectory(atPath: NOTES_DIR, withIntermediateDirectories: true)
            try? text.write(toFile: NOTES_DIR + "/" + safe + ".md", atomically: true, encoding: .utf8)
            rebuild()
            notify("Saved", "\(safe).md updated")
        case "delete":
            guard let name = body["name"] as? String, !name.isEmpty else { break }
            let safe = name.replacingOccurrences(of: "/", with: "-")
            try? FileManager.default.removeItem(atPath: NOTES_DIR + "/" + safe + ".md")
            rebuild()
        case "clip-copy":
            if let id = body["id"] as? String { clips.copyBack(id); notify("Copied", "From clipboard history") }
        case "clip-delete":
            if let id = body["id"] as? String { clips.delete(id) }
        case "clip-clear":
            clips.clearAll()
        case "quit":
            NSApp.terminate(nil)
        default: break
        }
    }

    func openCherryTree() {
        if FileManager.default.isExecutableFile(atPath: CHERRYTREE) {
            let p = Process(); p.executableURL = URL(fileURLWithPath: CHERRYTREE)
            p.arguments = [CTD]
            do { try p.run() } catch { NSWorkspace.shared.open(URL(fileURLWithPath: CTD)) }
        } else {
            NSWorkspace.shared.open(URL(fileURLWithPath: CTD))
        }
        popover.performClose(nil)
    }

    func notify(_ title: String, _ text: String) {
        let n = NSUserNotification(); n.title = title; n.informativeText = text
        NSUserNotificationCenter.default.deliver(n)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
