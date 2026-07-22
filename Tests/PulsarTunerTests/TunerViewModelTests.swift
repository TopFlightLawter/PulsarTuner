import XCTest
@testable import PulsarTuner

final class MockConnectionSending: PulsarConnectionSending {
    var sentCommands: [OutgoingCommand] = []
    func send(_ command: OutgoingCommand) {
        sentCommands.append(command)
    }
}

@MainActor
final class TunerViewModelTests: XCTestCase {
    private func makeConfig() throws -> RuntimeConfig {
        let json = """
        {"PWM_WARNING_DURATION":7500,"PWM_WARNING_STEPS":10,"WARNING_PAUSE_DURATION":3000,"RAMP_INITIAL_STRENGTH":10,"RAMP_LOOPS_PER_LEVEL":2,"RAMP_DOUBLE_SPEED_THRESHOLD":60,"RAMP_MAX_STRENGTH":90,"ALARM_START_HOUR":20,"ALARM_START_MINUTE":30,"ALARM_END_HOUR":23,"ALARM_END_MINUTE":30,"ALARM_INTERVAL_MINUTES":3,"SNOOZE_DURATION":180000,"ALARM_DAYS":[true,true,true,true,true,true,true],"PWM_STEPS_ARRAY":[10,7,7,7,7,8,7,7,7,9]}
        """.data(using: .utf8)!
        return try JSONDecoder().decode(RuntimeConfig.self, from: json)
    }

    func test_updateMarksKeyDirtyWhenValueChanges() throws {
        let mock = MockConnectionSending()
        let vm = TunerViewModel(connection: mock, initialConfig: try makeConfig(), debounceNanoseconds: 10_000_000)
        vm.update(.rampMaxStrength, to: 95)
        XCTAssertTrue(vm.dirtyKeys.contains(.rampMaxStrength))
        XCTAssertEqual(vm.config.rampMaxStrength, 95)
    }

    func test_updateBackToOriginalValueClearsDirty() throws {
        let mock = MockConnectionSending()
        let vm = TunerViewModel(connection: mock, initialConfig: try makeConfig(), debounceNanoseconds: 10_000_000)
        vm.update(.rampMaxStrength, to: 95)
        vm.update(.rampMaxStrength, to: 90)
        XCTAssertFalse(vm.dirtyKeys.contains(.rampMaxStrength))
    }

    func test_updateSendsDebouncedSetConfig() async throws {
        let mock = MockConnectionSending()
        let vm = TunerViewModel(connection: mock, initialConfig: try makeConfig(), debounceNanoseconds: 10_000_000)
        vm.update(.rampMaxStrength, to: 95)
        try await Task.sleep(nanoseconds: 50_000_000)
        guard case .setConfig(let key, let value) = mock.sentCommands.last else {
            return XCTFail("expected a setConfig command")
        }
        XCTAssertEqual(key, .rampMaxStrength)
        XCTAssertEqual(value, 95)
    }

    func test_saveToFlashSendsCommandAndClearsDirty() throws {
        let mock = MockConnectionSending()
        let vm = TunerViewModel(connection: mock, initialConfig: try makeConfig(), debounceNanoseconds: 10_000_000)
        vm.update(.rampMaxStrength, to: 95)
        vm.saveToFlash()
        XCTAssertTrue(vm.dirtyKeys.isEmpty)
        guard case .saveToFlash = mock.sentCommands.last else {
            return XCTFail("expected saveToFlash command")
        }
    }

    func test_resetToOriginalRestoresConfigAndClearsDirty() throws {
        let mock = MockConnectionSending()
        let initial = try makeConfig()
        let vm = TunerViewModel(connection: mock, initialConfig: initial, debounceNanoseconds: 10_000_000)
        vm.update(.rampMaxStrength, to: 95)
        vm.resetToOriginal()
        XCTAssertEqual(vm.config, initial)
        XCTAssertTrue(vm.dirtyKeys.isEmpty)
    }

    func test_applyIncomingReplacesConfigAndOriginal() throws {
        let mock = MockConnectionSending()
        var updatedFromDevice = try makeConfig()
        let vm = TunerViewModel(connection: mock, initialConfig: updatedFromDevice, debounceNanoseconds: 10_000_000)
        vm.update(.rampMaxStrength, to: 95)
        updatedFromDevice.rampMaxStrength = 77
        vm.applyIncoming(updatedFromDevice)
        XCTAssertEqual(vm.config.rampMaxStrength, 77)
        XCTAssertTrue(vm.dirtyKeys.isEmpty)
    }

    func test_toggleAlarmDaySendsSetAlarmDays() throws {
        let mock = MockConnectionSending()
        let vm = TunerViewModel(connection: mock, initialConfig: try makeConfig(), debounceNanoseconds: 10_000_000)
        vm.toggleAlarmDay(at: 0)
        XCTAssertFalse(vm.config.alarmDays[0])
        guard case .setAlarmDays(let days) = mock.sentCommands.last else {
            return XCTFail("expected setAlarmDays command")
        }
        XCTAssertEqual(days[0], false)
    }
}
