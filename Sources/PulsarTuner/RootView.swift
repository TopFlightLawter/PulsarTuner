import SwiftUI

struct RootView: View {
    @ObservedObject var connection: PulsarConnection
    @State private var viewModel: TunerViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    TunerView(connection: connection, viewModel: viewModel)
                } else {
                    ConnectingView()
                }
            }
        }
        .onAppear { connection.connect() }
        .onChange(of: connection.config) { _, newConfig in
            guard let newConfig else { return }
            if let viewModel {
                viewModel.applyIncoming(newConfig)
            } else {
                viewModel = TunerViewModel(connection: connection, initialConfig: newConfig)
            }
        }
    }
}

struct ConnectingView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Connecting to Pulsar Flex…")
                .foregroundStyle(.secondary)
        }
    }
}
