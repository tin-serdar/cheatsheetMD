import Foundation

@Observable
final class CheatsheetManager {

    let filePath: URL
    var content: String = ""

    private var saveTask: Task<Void, Never>?

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
            content = """
            # My Cheatsheet

            Start typing your shortcuts and notes here...

            ## Example
            - **Cmd + C** — Copy
            - **Cmd + V** — Paste
            """
            saveToDisk()
        }
    }

    func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            saveToDisk()
        }
    }

    private func saveToDisk() {
        try? content.write(to: filePath, atomically: true, encoding: .utf8)
    }
}
