import XCTest
@testable import PulsarTuner

final class IncomingMessageTests: XCTestCase {
    private static let configAllText = """
    {"type":"configAll","config":{"PWM_WARNING_DURATION":7500,"PWM_WARNING_STEPS":10,"WARNING_PAUSE_DURATION":3000,"RAMP_INITIAL_STRENGTH":10,"RAMP_LOOPS_PER_LEVEL":2,"RAMP_DOUBLE_SPEED_THRESHOLD":60,"RAMP_MAX_STRENGTH":90,"ALARM_START_HOUR":20,"ALARM_START_MINUTE":30,"ALARM_END_HOUR":23,"ALARM_END_MINUTE":30,"ALARM_INTERVAL_MINUTES":3,"SNOOZE_DURATION":180000,"ALARM_DAYS":[true,true,true,true,true,true,true],"PWM_STEPS_ARRAY":[10,7,7,7,7,8,7,7,7,9]}}
    """

    func test_parsesConfigAll() {
        guard case .configAll(let config) = IncomingMessage.parse(Self.configAllText) else {
            return XCTFail("expected .configAll")
        }
        XCTAssertEqual(config.rampMaxStrength, 90)
    }

    func test_parsesAck() {
        XCTAssertEqual(IncomingMessage.parse(#"{"type":"ack"}"#), .ack)
    }

    func test_parsesError() {
        XCTAssertEqual(IncomingMessage.parse(#"{"type":"error","message":"bad param"}"#), .error("bad param"))
    }

    func test_parsesUnknownGarbage() {
        guard case .unknown = IncomingMessage.parse("not json") else {
            return XCTFail("expected .unknown")
        }
    }
}
