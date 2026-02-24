import AppKit
import SwiftUI

// MARK: - NSPanel Subclass

final class OverlayPanel: NSPanel {

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: true
        )

        isFloatingPanel = true
        level = .floating
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        hidesOnDeactivate = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isMovableByWindowBackground = false
        animationBehavior = .utilityWindow
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape
            orderOut(nil)
            NSApp.hide(nil)
        } else {
            super.keyDown(with: event)
        }
    }
}

// MARK: - Controller

@Observable
@MainActor
final class OverlayPanelController {

    private var panel: OverlayPanel?
    private(set) var isVisible: Bool = false

    func toggle(cheatsheetManager: CheatsheetManager) {
        if isVisible {
            hide()
        } else {
            show(cheatsheetManager: cheatsheetManager)
        }
    }

    func show(cheatsheetManager: CheatsheetManager) {
        if panel == nil {
            createPanel(cheatsheetManager: cheatsheetManager)
        }

        guard let panel, let screen = NSScreen.main else { return }

        // 90% of the visible screen area, centered
        let screenFrame = screen.visibleFrame
        let width = screenFrame.width * 0.95
        let height = screenFrame.height * 0.95
        let x = screenFrame.origin.x + (screenFrame.width - width) / 2
        let y = screenFrame.origin.y + (screenFrame.height - height) / 2

        panel.setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate()
        isVisible = true
    }

    func hide() {
        panel?.orderOut(nil)
        isVisible = false
    }

    private func createPanel(cheatsheetManager: CheatsheetManager) {
        let panel = OverlayPanel(contentRect: .zero)

        let editorView = EditorView(
            cheatsheetManager: cheatsheetManager,
            onClose: { [weak self] in
                self?.hide()
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))

        let hostingView = NSHostingView(rootView: editorView)
        panel.contentView = hostingView
        panel.contentView?.wantsLayer = true
        panel.contentView?.layer?.cornerRadius = 12
        panel.contentView?.layer?.masksToBounds = true

        self.panel = panel
    }
}
