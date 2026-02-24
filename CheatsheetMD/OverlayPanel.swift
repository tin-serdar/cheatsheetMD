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

}

// MARK: - Controller

@Observable
@MainActor
final class OverlayPanelController {

    private var panel: OverlayPanel?
    private(set) var isVisible: Bool = false

    func show(cheatsheetManager: CheatsheetManager) {
        guard let screen = NSScreen.main else { return }

        let screenFrame = screen.visibleFrame
        let width = screenFrame.width * 0.95
        let height = screenFrame.height * 0.95
        let x = screenFrame.origin.x + (screenFrame.width - width) / 2
        let y = screenFrame.origin.y + (screenFrame.height - height) / 2
        let frame = NSRect(x: x, y: y, width: width, height: height)

        if panel == nil {
            createPanel(frame: frame, cheatsheetManager: cheatsheetManager)
        } else {
            panel?.setFrame(frame, display: false)
        }

        guard let panel else { return }
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate()
        isVisible = true
    }

    func hide() {
        panel?.orderOut(nil)
        isVisible = false
    }

    private func createPanel(frame: NSRect, cheatsheetManager: CheatsheetManager) {
        let panel = OverlayPanel(contentRect: frame)

        let editorView = EditorView(cheatsheetManager: cheatsheetManager)
            .clipShape(RoundedRectangle(cornerRadius: 12))

        let hostingView = NSHostingView(rootView: editorView)
        hostingView.frame = NSRect(origin: .zero, size: frame.size)
        hostingView.autoresizingMask = [.width, .height]

        panel.contentView = hostingView
        panel.contentView?.wantsLayer = true
        panel.contentView?.layer?.cornerRadius = 12
        panel.contentView?.layer?.masksToBounds = true

        self.panel = panel
    }
}
