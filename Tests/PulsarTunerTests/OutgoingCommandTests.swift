import XCTest
@testable import PulsarTuner

final class OutgoingCommandTests: XCTestCase {
    private func decodedObject(_ command: OutgoingCommand) throws -> [String: Any] {
        let data = command.jsonString.data(using: .utf8)!
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    func test_getConfigEncodesTypeOnly() throws {
        let object = try decodedObject(.getConfig)
        XCTAssertEqual(object["type"] as? String, "getConfig")
    }

    func test_setConfigEncodesParamAndIntValue() throws {
        let object = try decodedObject(.setConfig(key: .rampMaxStrength, value: 85))
        XCTAssertEqual(object["type"] as? String, "setConfig")
        XCTAssertEqual(object["param"] as? String, "RAMP_MAX_STRENGTH")
        XCTAssertEqual(object["value"] as? Int, 85)
    }

    func test_saveToFlashEncodesTypeOnly() throws {
        let object = try decodedObject(.saveToFlash)
        XCTAssertEqual(object["type"] as? String, "saveToFlash")
    }

    func test_setAlarmDaysEncodesBoolArray() throws {
        let object = try decodedObject(.setAlarmDays([true, false, true, false, true, false, true]))
        XCTAssertEqual(object["type"] as? String, "setAlarmDays")
        XCTAssertEqual(object["days"] as? [Bool], [true, false, true, false, true, false, true])
    }
}
