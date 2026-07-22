import XCTest
@testable import PulsarTuner

final class MockWebSocketTask: WebSocketTaskProtocol {
    var sentMessages: [URLSessionWebSocketTask.Message] = []
    var resumeCallCount = 0
    private var receiveHandler: ((Result<URLSessionWebSocketTask.Message, Error>) -> Void)?

    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping (Error?) -> Void) {
        sentMessages.append(message)
        completionHandler(nil)
    }

    func receive(completionHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void) {
        receiveHandler = completionHandler
    }

    func resume() {
        resumeCallCount += 1
    }

    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {}

    func simulateIncoming(_ text: String) {
        receiveHandler?(.success(.string(text)))
    }
}

@MainActor
final class PulsarConnectionTests: XCTestCase {
    func test_connectSendsGetConfigAndResumesTask() {
        let mock = MockWebSocketTask()
        let connection = PulsarConnection(host: "pulsar.local", taskFactory: { _ in mock })
        connection.connect()
        XCTAssertEqual(mock.resumeCallCount, 1)
        guard case .string(let text) = mock.sentMessages.first else {
            return XCTFail("expected a string message")
        }
        XCTAssertTrue(text.contains("getConfig"))
    }

    func test_receivingConfigAllUpdatesPublishedConfig() async throws {
        let mock = MockWebSocketTask()
        let connection = PulsarConnection(host: "pulsar.local", taskFactory: { _ in mock })
        connection.connect()
        mock.simulateIncoming(#"{"type":"configAll","config":{"PWM_WARNING_DURATION":7500,"PWM_WARNING_STEPS":10,"WARNING_PAUSE_DURATION":3000,"RAMP_INITIAL_STRENGTH":10,"RAMP_LOOPS_PER_LEVEL":2,"RAMP_DOUBLE_SPEED_THRESHOLD":60,"RAMP_MAX_STRENGTH":90,"ALARM_START_HOUR":20,"ALARM_START_MINUTE":30,"ALARM_END_HOUR":23,"ALARM_END_MINUTE":30,"ALARM_INTERVAL_MINUTES":3,"SNOOZE_DURATION":180000,"ALARM_DAYS":[true,true,true,true,true,true,true],"PWM_STEPS_ARRAY":[10,7,7,7,7,8,7,7,7,9]}}"#)
        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(connection.state, .connected)
        XCTAssertEqual(connection.config?.rampMaxStrength, 90)
    }

    func test_sendEncodesSetConfigCommand() {
        let mock = MockWebSocketTask()
        let connection = PulsarConnection(host: "pulsar.local", taskFactory: { _ in mock })
        connection.connect()
        connection.send(.setConfig(key: .snoozeDuration, value: 120000))
        guard case .string(let text) = mock.sentMessages.last else {
            return XCTFail("expected a string message")
        }
        XCTAssertTrue(text.contains("SNOOZE_DURATION"))
        XCTAssertTrue(text.contains("120000"))
    }
}
