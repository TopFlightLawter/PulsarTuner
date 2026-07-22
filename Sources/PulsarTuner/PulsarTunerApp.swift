import SwiftUI

@main
struct PulsarTunerApp: App {
    @StateObject private var connection = PulsarConnection(host: "pulsar.local")

    var body: some Scene {
        WindowGroup {
            RootView(connection: connection)
        }
    }
}
