import Foundation
import ApplicationServices

@Observable
@MainActor
final class AppState {

    let cheatsheetManager = CheatsheetManager()
    let overlayController = OverlayPanelController()
    let hotkeyManager = HotkeyManager()

    init() {
        cheatsheetManager.load()

        hotkeyManager.onShow = { [weak self] in
            guard let self else { return }
            self.overlayController.show(cheatsheetManager: self.cheatsheetManager)
        }
        hotkeyManager.onHide = { [weak self] in
            guard let self else { return }
            self.overlayController.hide()
        }

        hotkeyManager.start()

        if !hotkeyManager.isAccessibilityGranted {
            startAccessibilityPolling()
        }
    }

    private func startAccessibilityPolling() {
        Task {
            while !hotkeyManager.isAccessibilityGranted {
                try? await Task.sleep(for: .seconds(2))
                let granted = AXIsProcessTrusted()
                if granted {
                    hotkeyManager.isAccessibilityGranted = true
                    hotkeyManager.start()
                    break
                }
            }
        }
    }
}
