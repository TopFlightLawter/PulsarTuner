import Foundation

@MainActor
final class TunerViewModel: ObservableObject {
    @Published private(set) var config: RuntimeConfig
    @Published private(set) var dirtyKeys: Set<ConfigParamKey> = []

    private var original: RuntimeConfig
    private let connection: PulsarConnectionSending
    private let debounceNanoseconds: UInt64
    private var debounceTasks: [ConfigParamKey: Task<Void, Never>] = [:]

    init(connection: PulsarConnectionSending, initialConfig: RuntimeConfig, debounceNanoseconds: UInt64 = 300_000_000) {
        self.connection = connection
        self.config = initialConfig
        self.original = initialConfig
        self.debounceNanoseconds = debounceNanoseconds
    }

    func originalValue(for key: ConfigParamKey) -> Int {
        original.value(for: key)
    }

    func update(_ key: ConfigParamKey, to newValue: Int) {
        config.setValue(newValue, for: key)
        if newValue == original.value(for: key) {
            dirtyKeys.remove(key)
        } else {
            dirtyKeys.insert(key)
        }
        debounceTasks[key]?.cancel()
        let delay = debounceNanoseconds
        debounceTasks[key] = Task { [weak self] in
            try? await Task.sleep(nanoseconds: delay)
            guard !Task.isCancelled, let self else { return }
            self.connection.send(.setConfig(key: key, value: newValue))
        }
    }

    func toggleAlarmDay(at index: Int) {
        guard config.alarmDays.indices.contains(index) else { return }
        config.alarmDays[index].toggle()
        connection.send(.setAlarmDays(config.alarmDays))
    }

    func saveToFlash() {
        connection.send(.saveToFlash)
        original = config
        dirtyKeys.removeAll()
    }

    func resetToOriginal() {
        config = original
        dirtyKeys.removeAll()
    }

    func applyIncoming(_ newConfig: RuntimeConfig) {
        config = newConfig
        original = newConfig
        dirtyKeys.removeAll()
    }
}
