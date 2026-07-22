import Foundation

struct RuntimeConfig: Codable, Equatable {
    var pwmWarningDuration: Int
    var pwmWarningStepCount: Int
    var warningPauseDuration: Int
    var rampInitialStrength: Int
    var rampLoopsPerLevel: Int
    var rampDoubleSpeedThreshold: Int
    var rampMaxStrength: Int
    var alarmStartHour: Int
    var alarmStartMinute: Int
    var alarmEndHour: Int
    var alarmEndMinute: Int
    var alarmIntervalMinutes: Int
    var snoozeDuration: Int
    var alarmDays: [Bool]
    var pwmStepsArray: [Int]

    enum CodingKeys: String, CodingKey {
        case pwmWarningDuration = "PWM_WARNING_DURATION"
        case pwmWarningStepCount = "PWM_WARNING_STEPS"
        case warningPauseDuration = "WARNING_PAUSE_DURATION"
        case rampInitialStrength = "RAMP_INITIAL_STRENGTH"
        case rampLoopsPerLevel = "RAMP_LOOPS_PER_LEVEL"
        case rampDoubleSpeedThreshold = "RAMP_DOUBLE_SPEED_THRESHOLD"
        case rampMaxStrength = "RAMP_MAX_STRENGTH"
        case alarmStartHour = "ALARM_START_HOUR"
        case alarmStartMinute = "ALARM_START_MINUTE"
        case alarmEndHour = "ALARM_END_HOUR"
        case alarmEndMinute = "ALARM_END_MINUTE"
        case alarmIntervalMinutes = "ALARM_INTERVAL_MINUTES"
        case snoozeDuration = "SNOOZE_DURATION"
        case alarmDays = "ALARM_DAYS"
        case pwmStepsArray = "PWM_STEPS_ARRAY"
    }
}

enum ConfigParamKey: String, CaseIterable, Hashable {
    case pwmWarningDuration = "PWM_WARNING_DURATION"
    case pwmWarningStepCount = "PWM_WARNING_STEPS"
    case warningPauseDuration = "WARNING_PAUSE_DURATION"
    case rampInitialStrength = "RAMP_INITIAL_STRENGTH"
    case rampLoopsPerLevel = "RAMP_LOOPS_PER_LEVEL"
    case rampDoubleSpeedThreshold = "RAMP_DOUBLE_SPEED_THRESHOLD"
    case rampMaxStrength = "RAMP_MAX_STRENGTH"
    case alarmStartHour = "ALARM_START_HOUR"
    case alarmStartMinute = "ALARM_START_MINUTE"
    case alarmEndHour = "ALARM_END_HOUR"
    case alarmEndMinute = "ALARM_END_MINUTE"
    case alarmIntervalMinutes = "ALARM_INTERVAL_MINUTES"
    case snoozeDuration = "SNOOZE_DURATION"
}

extension RuntimeConfig {
    func value(for key: ConfigParamKey) -> Int {
        switch key {
        case .pwmWarningDuration: return pwmWarningDuration
        case .pwmWarningStepCount: return pwmWarningStepCount
        case .warningPauseDuration: return warningPauseDuration
        case .rampInitialStrength: return rampInitialStrength
        case .rampLoopsPerLevel: return rampLoopsPerLevel
        case .rampDoubleSpeedThreshold: return rampDoubleSpeedThreshold
        case .rampMaxStrength: return rampMaxStrength
        case .alarmStartHour: return alarmStartHour
        case .alarmStartMinute: return alarmStartMinute
        case .alarmEndHour: return alarmEndHour
        case .alarmEndMinute: return alarmEndMinute
        case .alarmIntervalMinutes: return alarmIntervalMinutes
        case .snoozeDuration: return snoozeDuration
        }
    }

    mutating func setValue(_ newValue: Int, for key: ConfigParamKey) {
        switch key {
        case .pwmWarningDuration: pwmWarningDuration = newValue
        case .pwmWarningStepCount: pwmWarningStepCount = newValue
        case .warningPauseDuration: warningPauseDuration = newValue
        case .rampInitialStrength: rampInitialStrength = newValue
        case .rampLoopsPerLevel: rampLoopsPerLevel = newValue
        case .rampDoubleSpeedThreshold: rampDoubleSpeedThreshold = newValue
        case .rampMaxStrength: rampMaxStrength = newValue
        case .alarmStartHour: alarmStartHour = newValue
        case .alarmStartMinute: alarmStartMinute = newValue
        case .alarmEndHour: alarmEndHour = newValue
        case .alarmEndMinute: alarmEndMinute = newValue
        case .alarmIntervalMinutes: alarmIntervalMinutes = newValue
        case .snoozeDuration: snoozeDuration = newValue
        }
    }
}
