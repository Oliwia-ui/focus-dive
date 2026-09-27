public enum FloatingTimerVisibility {
    public static func shouldShow(
        isRunning: Bool,
        isApplicationActive: Bool,
        isMainWindowMiniaturized: Bool,
        isPinned: Bool = false
    ) -> Bool {
        isRunning && (isPinned || !isApplicationActive || isMainWindowMiniaturized)
    }
}
