import Foundation
import CoreGraphics
import ApplicationServices

@Observable
@MainActor
final class HotkeyManager {

    var onShow: (() -> Void)?
    var onHide: (() -> Void)?
    var isAccessibilityGranted: Bool = false

    private var tapHandler: EventTapHandler?

    func start() {
        checkAccessibility()
        guard isAccessibilityGranted else { return }
        guard tapHandler == nil else { return }

        let handler = EventTapHandler(
            onShow: { [weak self] in
                Task { @MainActor [weak self] in
                    self?.onShow?()
                }
            },
            onHide: { [weak self] in
                Task { @MainActor [weak self] in
                    self?.onHide?()
                }
            }
        )
        tapHandler = handler
        handler.start()
    }

    func stop() {
        tapHandler?.stop()
        tapHandler = nil
    }

    func checkAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true] as CFDictionary
        isAccessibilityGranted = AXIsProcessTrustedWithOptions(options)
    }
}

// MARK: - Event Tap Handler (runs off the main actor)

private final class EventTapHandler: @unchecked Sendable {

    private let onShow: () -> Void
    private let onHide: () -> Void
    private var thread: Thread?
    private var runLoopRef: CFRunLoop?
    private var machPort: CFMachPort?

    private var rightCommandIsDown: Bool = false
    private var lastRightCommandDownTime: CFAbsoluteTime = 0
    private var isShowing: Bool = false

    private static let doublePressThreshold: CFTimeInterval = 0.4
    private static let rightCommandKeyCode: UInt16 = 0x36

    init(onShow: @escaping () -> Void, onHide: @escaping () -> Void) {
        self.onShow = onShow
        self.onHide = onHide
    }

    func start() {
        let thread = Thread { [weak self] in
            self?.runEventTapLoop()
        }
        thread.name = "com.cheatsheetmd.hotkey"
        thread.qualityOfService = .userInteractive
        thread.start()
        self.thread = thread
    }

    func stop() {
        if let runLoop = runLoopRef {
            CFRunLoopStop(runLoop)
        }
        thread = nil
        runLoopRef = nil
        machPort = nil
    }

    private func runEventTapLoop() {
        let eventMask: CGEventMask = (1 << CGEventType.flagsChanged.rawValue)

        let unmanagedSelf = Unmanaged.passUnretained(self)
        let userInfo = unmanagedSelf.toOpaque()

        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: eventMask,
            callback: { _, type, event, userInfo -> Unmanaged<CGEvent>? in
                guard let userInfo else { return Unmanaged.passUnretained(event) }
                let handler = Unmanaged<EventTapHandler>.fromOpaque(userInfo)
                    .takeUnretainedValue()
                handler.handleEvent(type: type, event: event)
                return Unmanaged.passUnretained(event)
            },
            userInfo: userInfo
        ) else {
            print("CheatsheetMD: Failed to create event tap. Check Accessibility permissions.")
            return
        }

        machPort = eventTap

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        let runLoop = CFRunLoopGetCurrent()
        CFRunLoopAddSource(runLoop, runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)

        runLoopRef = runLoop
        CFRunLoopRun()
    }

    private func handleEvent(type: CGEventType, event: CGEvent) {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let port = machPort {
                CGEvent.tapEnable(tap: port, enable: true)
            }
            return
        }

        let keyCode = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
        let flags = event.flags

        guard keyCode == Self.rightCommandKeyCode else { return }

        let isCommandDown = flags.contains(.maskCommand)

        if isCommandDown && !rightCommandIsDown {
            // Right Command pressed down
            rightCommandIsDown = true

            let now = CFAbsoluteTimeGetCurrent()
            let elapsed = now - lastRightCommandDownTime

            if elapsed < Self.doublePressThreshold && elapsed > 0.05 {
                // Double press detected — show
                isShowing = true
                onShow()
            }

            lastRightCommandDownTime = now
        } else if !isCommandDown && rightCommandIsDown {
            // Right Command released
            rightCommandIsDown = false

            if isShowing {
                isShowing = false
                onHide()
            }
        }
    }
}
