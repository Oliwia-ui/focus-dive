import AppKit
import FocusDiveCore
import SwiftUI

private final class FloatingTimerPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

struct FloatingTimerWindowObserver: View {
    @ObservedObject var model: FocusDiveViewModel
    @StateObject private var presenter = FloatingTimerWindowPresenter()

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .onAppear {
                presenter.install(model: model)
            }
            .onChange(of: model.timerState) { _, _ in
                presenter.updateVisibility()
            }
            .onChange(of: model.keepFloatingTimerVisible) { _, _ in
                presenter.updateVisibility()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                presenter.updateVisibility()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
                presenter.updateVisibility()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didMiniaturizeNotification)) { notification in
                presenter.setMainWindowMiniaturized(true, window: notification.object as? NSWindow)
            }
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didDeminiaturizeNotification)) { notification in
                presenter.setMainWindowMiniaturized(false, window: notification.object as? NSWindow)
            }
    }
}

@MainActor
final class FloatingTimerWindowPresenter: NSObject, ObservableObject {
    private weak var model: FocusDiveViewModel?
    private weak var mainWindow: NSWindow?
    private var panel: NSPanel?
    private var mainWindowIsMiniaturized = false
    private var snapWorkItem: DispatchWorkItem?
    private var isSnapping = false

    func install(model: FocusDiveViewModel) {
        self.model = model
        if panel == nil {
            panel = makePanel(model: model)
        }
        DispatchQueue.main.async { [weak self] in
            self?.captureMainWindow()
            self?.updateVisibility()
        }
    }

    func setMainWindowMiniaturized(_ miniaturized: Bool, window: NSWindow?) {
        guard let window, window !== panel else { return }
        mainWindow = window
        mainWindowIsMiniaturized = miniaturized
        updateVisibility()
    }

    func updateVisibility() {
        guard let model, let panel else { return }
        captureMainWindow()
        let shouldShow = FloatingTimerVisibility.shouldShow(
            isRunning: model.isRunning,
            isApplicationActive: NSApp.isActive,
            isMainWindowMiniaturized: mainWindowIsMiniaturized,
            isPinned: model.keepFloatingTimerVisible
        )

        if shouldShow {
            if !panel.isVisible {
                positionPanel(panel)
                panel.orderFrontRegardless()
            }
        } else {
            panel.orderOut(nil)
        }
    }

    private func makePanel(model: FocusDiveViewModel) -> NSPanel {
        let size = NSSize(width: 360, height: 108)
        let panel = FloatingTimerPanel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.titled, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.hidesOnDeactivate = false
        panel.becomesKeyOnlyIfNeeded = false
        panel.isReleasedWhenClosed = false
        panel.isMovableByWindowBackground = true
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.contentView = NSHostingView(rootView: CompactTimerView(model: model))
        panel.setContentSize(size)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(panelDidMove(_:)),
            name: NSWindow.didMoveNotification,
            object: panel
        )
        return panel
    }

    private func captureMainWindow() {
        guard let panel else { return }
        if let candidate = NSApp.windows.first(where: { $0 !== panel && !($0 is NSPanel) }) {
            mainWindow = candidate
            mainWindowIsMiniaturized = candidate.isMiniaturized
        }
    }

    private func positionPanel(_ panel: NSPanel) {
        guard let screen = panel.screen ?? NSScreen.main else { return }
        let frame = screen.visibleFrame
        let margin: CGFloat = 22
        let corner = UserDefaults.standard.string(forKey: "floatingTimerCorner") ?? "topRight"
        let origins = cornerOrigins(for: panel.frame.size, in: frame, margin: margin)
        panel.setFrameOrigin(origins[corner] ?? origins["topRight"]!)
    }

    @objc private func panelDidMove(_ notification: Notification) {
        guard !isSnapping, let panel = notification.object as? NSPanel, panel.isVisible else { return }
        snapWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self, weak panel] in
            guard let self, let panel else { return }
            self.snapToNearestCorner(panel)
        }
        snapWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: item)
    }

    private func snapToNearestCorner(_ panel: NSPanel) {
        guard let screen = panel.screen ?? NSScreen.main else { return }
        let origins = cornerOrigins(for: panel.frame.size, in: screen.visibleFrame, margin: 22)
        let current = panel.frame.origin
        guard let nearest = origins.min(by: {
            distance(from: current, to: $0.value) < distance(from: current, to: $1.value)
        }) else { return }

        isSnapping = true
        panel.setFrameOrigin(nearest.value)
        UserDefaults.standard.set(nearest.key, forKey: "floatingTimerCorner")
        DispatchQueue.main.async { [weak self] in self?.isSnapping = false }
    }

    private func cornerOrigins(
        for size: NSSize,
        in frame: NSRect,
        margin: CGFloat
    ) -> [String: NSPoint] {
        [
            "topLeft": NSPoint(x: frame.minX + margin, y: frame.maxY - size.height - margin),
            "topRight": NSPoint(x: frame.maxX - size.width - margin, y: frame.maxY - size.height - margin),
            "bottomLeft": NSPoint(x: frame.minX + margin, y: frame.minY + margin),
            "bottomRight": NSPoint(x: frame.maxX - size.width - margin, y: frame.minY + margin)
        ]
    }

    private func distance(from lhs: NSPoint, to rhs: NSPoint) -> CGFloat {
        hypot(lhs.x - rhs.x, lhs.y - rhs.y)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
