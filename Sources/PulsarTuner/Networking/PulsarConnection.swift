import Foundation

protocol WebSocketTaskProtocol: AnyObject {
    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping (Error?) -> Void)
    func receive(completionHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void)
    func resume()
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
}

extension URLSessionWebSocketTask: WebSocketTaskProtocol {}

enum ConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
}

protocol PulsarConnectionSending: AnyObject {
    func send(_ command: OutgoingCommand)
}

@MainActor
final class PulsarConnection: ObservableObject, PulsarConnectionSending {
    @Published private(set) var state: ConnectionState = .disconnected
    @Published private(set) var config: RuntimeConfig?

    private(set) var host: String
    private let taskFactory: (URL) -> WebSocketTaskProtocol
    private let reconnectDelay: TimeInterval
    private var task: WebSocketTaskProtocol?
    private var reconnectTimer: Timer?

    init(
        host: String,
        reconnectDelay: TimeInterval = 4.0,
        taskFactory: @escaping (URL) -> WebSocketTaskProtocol = { URLSession.shared.webSocketTask(with: $0) }
    ) {
        self.host = host
        self.reconnectDelay = reconnectDelay
        self.taskFactory = taskFactory
    }

    func connect() {
        reconnectTimer?.invalidate()
        guard let url = URL(string: "ws://\(host):81") else { return }
        state = .connecting
        let newTask = taskFactory(url)
        task = newTask
        newTask.resume()
        listen()
        send(.getConfig)
    }

    func disconnect() {
        reconnectTimer?.invalidate()
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        state = .disconnected
    }

    func send(_ command: OutgoingCommand) {
        task?.send(.string(command.jsonString)) { _ in }
    }

    private func listen() {
        task?.receive { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success(let message):
                    if case .string(let text) = message {
                        self.handle(IncomingMessage.parse(text))
                    }
                    self.listen()
                case .failure:
                    self.state = .disconnected
                    self.scheduleReconnect()
                }
            }
        }
    }

    private func handle(_ message: IncomingMessage) {
        switch message {
        case .configAll(let newConfig):
            state = .connected
            config = newConfig
        case .ack, .unknown, .error:
            state = .connected
        }
    }

    private func scheduleReconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: reconnectDelay, repeats: false) { [weak self] _ in
            Task { @MainActor in self?.connect() }
        }
    }
}
