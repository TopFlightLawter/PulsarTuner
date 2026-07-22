import SwiftUI

struct RampAlarmSectionView: View {
    @ObservedObject var viewModel: TunerViewModel

    var body: some View {
        Section("Ramp Alarm") {
            row(.rampInitialStrength, label: "Initial Strength", unit: "%", range: 1...100, step: 1)
            row(.rampLoopsPerLevel, label: "Loops Per Level", unit: "", range: 1...20, step: 1)
            row(.rampDoubleSpeedThreshold, label: "Double-Speed Threshold", unit: "%", range: 1...100, step: 1)
            row(.rampMaxStrength, label: "Max Strength", unit: "%", range: 1...100, step: 1)
        }
    }

    private func row(_ key: ConfigParamKey, label: String, unit: String, range: ClosedRange<Double>, step: Double) -> some View {
        ParamRow(
            label: label,
            unit: unit,
            range: range,
            step: step,
            originalValue: viewModel.originalValue(for: key),
            value: Binding(
                get: { viewModel.config.value(for: key) },
                set: { viewModel.update(key, to: $0) }
            )
        )
    }
}
