import Foundation

enum IncomingMessage: Equatable {
    case configAll(RuntimeConfig)
    case ack
    case error(String)
    case unknown(String)

    static func parse(_ text: String) -> IncomingMessage {
        guard let data = text.data(using: .utf8),
              let envelope = try? JSONDecoder().decode(Envelope.self, from: data) else {
            return .unknown(text)
        }
        switch envelope.type {
        case "configAll":
            guard let payload = try? JSONDecoder().decode(ConfigAllPayload.self, from: data) else {
                return .unknown(text)
            }
            return .configAll(payload.config)
        case "ack":
            return .ack
        case "error":
            return .error(envelope.message ?? "unknown error")
        default:
            return .unknown(envelope.type)
        }
    }

    private struct Envelope: Codable {
        let type: String
        let message: String?
    }

    private struct ConfigAllPayload: Codable {
        let type: String
        let config: RuntimeConfig
    }
}
