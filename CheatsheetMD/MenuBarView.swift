import SwiftUI

struct MenuBarView: View {
    let appState: AppState

    var body: some View {
        Button("Edit Cheatsheet") {
            appState.overlayController.toggle(
                cheatsheetManager: appState.cheatsheetManager
            )
        }
        .keyboardShortcut("e", modifiers: .command)

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
