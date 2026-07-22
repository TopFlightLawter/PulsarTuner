import XCTest
@testable import PulsarTuner

final class RuntimeConfigTests: XCTestCase {
    static let sampleJSON = """
    {
        "PWM_WARNING_DURATION": 7500,
        "PWM_WARNING_STEPS": 10,
        "WARNING_PAUSE_DURATION": 3000,
        "RAMP_INITIAL_STRENGTH": 10,
        "RAMP_LOOPS_PER_LEVEL": 2,
        "RAMP_DOUBLE_SPEED_THRESHOLD": 60,
        "RAMP_MAX_STRENGTH": 90,
        "ALARM_START_HOUR": 20,
        "ALARM_START_MINUTE": 30,
        "ALARM_END_HOUR": 23,
        "ALARM_END_MINUTE": 30,
        "ALARM_INTERVAL_MINUTES": 3,
        "SNOOZE_DURATION": 180000,
        "ALARM_DAYS": [true, true, true, true, true, true, true],
        "PWM_STEPS_ARRAY": [10, 7, 7, 7, 7, 8, 7, 7, 7, 9]
    }
    """.data(using: .utf8)!

    func test_decodesWireFormatCorrectly() throws {
        let config = try JSONDecoder().decode(RuntimeConfig.self, from: Self.sampleJSON)
        XCTAssertEqual(config.pwmWarningDuration, 7500)
        XCTAssertEqual(config.rampMaxStrength, 90)
        XCTAssertEqual(config.alarmDays, [true, true, true, true, true, true, true])
        XCTAssertEqual(config.pwmStepsArray, [10, 7, 7, 7, 7, 8, 7, 7, 7, 9])
    }

    func test_valueForKeyReadsCorrectField() throws {
        let config = try JSONDecoder().decode(RuntimeConfig.self, from: Self.sampleJSON)
        XCTAssertEqual(config.value(for: .rampInitialStrength), 10)
        XCTAssertEqual(config.value(for: .snoozeDuration), 180000)
    }

    func test_setValueForKeyWritesCorrectField() throws {
        var config = try JSONDecoder().decode(RuntimeConfig.self, from: Self.sampleJSON)
        config.setValue(99, for: .rampMaxStrength)
        XCTAssertEqual(config.rampMaxStrength, 99)
        XCTAssertEqual(config.value(for: .rampMaxStrength), 99)
    }

    func test_allConfigParamKeyCasesRoundTrip() throws {
        var config = try JSONDecoder().decode(RuntimeConfig.self, from: Self.sampleJSON)
        for key in ConfigParamKey.allCases {
            config.setValue(42, for: key)
            XCTAssertEqual(config.value(for: key), 42, "key \(key.rawValue) did not round-trip")
        }
    }
}
