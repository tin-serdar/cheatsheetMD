import Foundation

@Observable
final class CheatsheetManager {

    let filePath: URL
    var content: String = ""

    static let defaultDirectory: URL = {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/cheatsheetmd", isDirectory: true)
    }()

    static let defaultFilePath: URL = {
        defaultDirectory.appendingPathComponent("cheatsheet.md")
    }()

    init(filePath: URL = CheatsheetManager.defaultFilePath) {
        self.filePath = filePath
    }

    func load() {
        let directory = filePath.deletingLastPathComponent()
        try? FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        if FileManager.default.fileExists(atPath: filePath.path) {
            content = (try? String(contentsOf: filePath, encoding: .utf8)) ?? ""
        } else {
            content = defaultContent
            saveToDisk()
        }
    }

    private func saveToDisk() {
        try? content.write(to: filePath, atomically: true, encoding: .utf8)
    }

    private let defaultContent = """
## General
- **⌘ C** — Copy
- **⌘ V** — Paste
- **⌘ X** — Cut
- **⌘ Z** — Undo
- **⌘ ⇧ Z** — Redo
- **⌘ A** — Select All
- **⌘ F** — Find

## Files
- **⌘ N** — New
- **⌘ O** — Open
- **⌘ S** — Save
- **⌘ ⇧ S** — Save As
- **⌘ W** — Close Window
- **⌘ Q** — Quit

## Navigation
- **⌘ T** — New Tab
- **⌘ ⇧ T** — Reopen Closed Tab
- **⌘ L** — Focus Address Bar
- **⌘ [** — Go Back
- **⌘ ]** — Go Forward

## Window
- **⌘ M** — Minimize
- **⌘ H** — Hide App
- **⌘ ⌥ H** — Hide Others
- **⌘ `** — Cycle Windows
- **⌃ ⌘ F** — Toggle Fullscreen

## Screenshots
- **⌘ ⇧ 3** — Capture Screen
- **⌘ ⇧ 4** — Capture Selection
- **⌘ ⇧ 5** — Screenshot Toolbar

## Spotlight
- **⌘ Space** — Open Spotlight
"""
}
