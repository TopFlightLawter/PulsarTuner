import Foundation

enum OutgoingCommand: Equatable {
    case getConfig
    case setConfig(key: ConfigParamKey, value: Int)
    case saveToFlash
    case setAlarmDays([Bool])

    var jsonString: String {
        let object: [String: Any]
        switch self {
        case .getConfig:
            object = ["type": "getConfig"]
        case .setConfig(let key, let value):
            object = ["type": "setConfig", "param": key.rawValue, "value": value]
        case .saveToFlash:
            object = ["type": "saveToFlash"]
        case .setAlarmDays(let days):
            object = ["type": "setAlarmDays", "days": days]
        }
        guard let data = try? JSONSerialization.data(withJSONObject: object),
              let string = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return string
    }
}
