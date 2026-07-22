import SwiftUI

struct TunerView: View {
    @ObservedObject var connection: PulsarConnection
    @ObservedObject var viewModel: TunerViewModel

    var body: some View {
        VStack(spacing: 0) {
            ConnectionBarView(connection: connection, viewModel: viewModel)
            Form {
                PWMWarningSectionView(viewModel: viewModel)
                RampAlarmSectionView(viewModel: viewModel)
                AlarmWindowSectionView(viewModel: viewModel)
                SnoozeSectionView(viewModel: viewModel)
            }
        }
        .navigationTitle("PulsarTuner")
    }
}
