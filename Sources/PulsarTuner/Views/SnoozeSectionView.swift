import SwiftUI

struct SnoozeSectionView: View {
    @ObservedObject var viewModel: TunerViewModel

    var body: some View {
        Section("Snooze") {
            ParamRow(
                label: "Duration",
                unit: "min",
                range: 1...30,
                step: 1,
                originalValue: viewModel.originalValue(for: .snoozeDuration) / 60000,
                value: Binding(
                    get: { viewModel.config.value(for: .snoozeDuration) / 60000 },
                    set: { viewModel.update(.snoozeDuration, to: $0 * 60000) }
                )
            )
        }
    }
}
