import SwiftUI

struct AlarmWindowSectionView: View {
    @ObservedObject var viewModel: TunerViewModel
    private let dayLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        Section("Alarm Window") {
            timeRow(hourKey: .alarmStartHour, minuteKey: .alarmStartMinute, label: "Start")
            timeRow(hourKey: .alarmEndHour, minuteKey: .alarmEndMinute, label: "End")
            ParamRow(
                label: "Interval",
                unit: "min",
                range: 1...60,
                step: 1,
                originalValue: viewModel.originalValue(for: .alarmIntervalMinutes),
                value: Binding(
                    get: { viewModel.config.value(for: .alarmIntervalMinutes) },
                    set: { viewModel.update(.alarmIntervalMinutes, to: $0) }
                )
            )
            HStack {
                ForEach(0..<7, id: \.self) { index in
                    Button(dayLabels[index]) {
                        viewModel.toggleAlarmDay(at: index)
                    }
                    .buttonStyle(.bordered)
                    .tint(viewModel.config.alarmDays[index] ? .accentColor : .gray)
                }
            }
        }
    }

    private func timeRow(hourKey: ConfigParamKey, minuteKey: ConfigParamKey, label: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline.weight(.semibold))
            Spacer()
            Picker("Hour", selection: Binding(
                get: { viewModel.config.value(for: hourKey) },
                set: { viewModel.update(hourKey, to: $0) }
            )) {
                ForEach(0..<24, id: \.self) { hour in
                    Text(String(format: "%02d", hour)).tag(hour)
                }
            }
            .pickerStyle(.menu)
            Text(":")
            Picker("Minute", selection: Binding(
                get: { viewModel.config.value(for: minuteKey) },
                set: { viewModel.update(minuteKey, to: $0) }
            )) {
                ForEach(0..<60, id: \.self) { minute in
                    Text(String(format: "%02d", minute)).tag(minute)
                }
            }
            .pickerStyle(.menu)
        }
    }
}
