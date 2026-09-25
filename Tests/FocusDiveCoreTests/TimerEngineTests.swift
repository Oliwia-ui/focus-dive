import Foundation
import Testing
@testable import FocusDiveCore

@Test func startPauseAndResumeTransitions() {
    var timer = DiveTimer(duration: 1_500)

    timer.start(at: Date(timeIntervalSince1970: 100))
    #expect(timer.state == .running)

    timer.pause(at: Date(timeIntervalSince1970: 110))
    #expect(timer.state == .paused)
    #expect(timer.remainingSeconds == 1_490)

    timer.start(at: Date(timeIntervalSince1970: 120))
    #expect(timer.state == .running)
    #expect(timer.remainingSeconds(at: Date(timeIntervalSince1970: 130)) == 1_480)
}

@Test func resetRestoresConfiguredDuration() {
    var timer = DiveTimer(duration: 300)
    timer.start(at: Date(timeIntervalSince1970: 0))
    _ = timer.tick(at: Date(timeIntervalSince1970: 42))

    timer.reset()

    #expect(timer.state == .idle)
    #expect(timer.remainingSeconds == 300)
}

@Test func tickCompletesAtZeroExactlyOnce() {
    var timer = DiveTimer(duration: 2)
    timer.start(at: Date(timeIntervalSince1970: 0))

    #expect(timer.tick(at: Date(timeIntervalSince1970: 1)) == false)
    #expect(timer.tick(at: Date(timeIntervalSince1970: 2)) == true)
    #expect(timer.tick(at: Date(timeIntervalSince1970: 3)) == false)
    #expect(timer.state == .completed)
    #expect(timer.remainingSeconds == 0)
}

@Test func depthAscendsTowardSurface() {
    var timer = DiveTimer(duration: 100)
    #expect(abs(timer.depthMeters - 60) < 0.001)

    timer.start(at: Date(timeIntervalSince1970: 0))
    _ = timer.tick(at: Date(timeIntervalSince1970: 50))
    #expect(abs(timer.depthMeters - 30) < 0.001)

    _ = timer.tick(at: Date(timeIntervalSince1970: 100))
    #expect(abs(timer.depthMeters) < 0.001)
}

@Test func frequentTicksAccumulateElapsedTime() {
    var timer = DiveTimer(duration: 10)
    timer.start(at: Date(timeIntervalSince1970: 0))

    _ = timer.tick(at: Date(timeIntervalSince1970: 0.25))
    _ = timer.tick(at: Date(timeIntervalSince1970: 0.50))
    _ = timer.tick(at: Date(timeIntervalSince1970: 0.75))
    _ = timer.tick(at: Date(timeIntervalSince1970: 1.00))

    #expect(timer.remainingSeconds == 9)
}
