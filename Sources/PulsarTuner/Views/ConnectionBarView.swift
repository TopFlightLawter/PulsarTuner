import SwiftUI

struct ConnectionBarView: View {
    @ObservedObject var connection: PulsarConnection
    @ObservedObject var viewModel: TunerViewModel

    var body: some View {
        HStack {
            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)
            Text(connection.host)
                .font(.system(.footnote, design: .monospaced))
            Spacer()
            Button("Save to Flash") {
                viewModel.saveToFlash()
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.dirtyKeys.isEmpty)
        }
        .padding(.horizontal)
    }

    private var dotColor: Color {
        switch connection.state {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected: return .red
        }
    }
}
