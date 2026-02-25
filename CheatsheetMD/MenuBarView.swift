import SwiftUI
import AppKit

struct MenuBarView: View {
    let appState: AppState

    var body: some View {
        Button("Edit Cheatsheet...") {
            NSWorkspace.shared.open(appState.cheatsheetManager.filePath)
        }
        .keyboardShortcut("e", modifiers: .command)

        Button("Show Cheatsheet") {
            appState.overlayController.show(
                cheatsheetManager: appState.cheatsheetManager
            )
        }

        Divider()

        if !appState.hotkeyManager.isAccessibilityGranted {
            Button("Grant Accessibility Access...") {
                appState.hotkeyManager.checkAccessibility()
            }
            Divider()
        }

        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q", modifiers: .command)
    }
}
