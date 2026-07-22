import SwiftUI

struct PWMWarningSectionView: View {
    @ObservedObject var viewModel: TunerViewModel

    var body: some View {
        Section("PWM Warning") {
            row(.pwmWarningDuration, label: "Duration", unit: "ms", range: 500...15000, step: 100)
            row(.pwmWarningStepCount, label: "Steps", unit: "", range: 1...10, step: 1)
            row(.warningPauseDuration, label: "Pause Duration", unit: "ms", range: 0...15000, step: 100)
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
