import Foundation
import UIKit

// MARK: - WebSocket Configuration
struct WebSocketConfig {
    let url: URL
    let userId: String
    let reconnectDelay: TimeInterval
    let debug: Bool
}

// MARK: - Message Model
struct WebSocketMessage: Codable {
    let roomId: String
    let callName: String
    let type: String
    let status: String
    let timestamp: Int64
    let senderId: String
}

// MARK: - WebSocketService
class WebSocketService: NSObject {
    // MARK: - Singleton
    static let shared = WebSocketService()
    private override init() {
        super.init()
    }

    // MARK: - Properties
    private var config: WebSocketConfig?
    private var webSocketTask: URLSessionWebSocketTask?
    private var subscriptions: [String: (WebSocketMessage) -> Void] = [:]
    private var isConnected: Bool = false
    private var reconnectTimer: Timer?
    private let prefix = "CONVAY_WIDGET"

    // MARK: - Configuration
    func configure(with config: WebSocketConfig) {
        self.config = config
        setupWebSocket()
    }

    // MARK: - WebSocket Setup
    private func setupWebSocket() {
        guard let config = config else {
            print("\(prefix) Error: WebSocketConfig not set")
            return
        }
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
        webSocketTask = session.webSocketTask(with: config.url)
        connect()
    }

    // MARK: - Connection Management
    func connect() {
        guard let webSocketTask = webSocketTask else { return }
        webSocketTask.resume()
        receiveMessage()
        log("Connecting to server...")
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        subscriptions.removeAll()
        isConnected = false
        reconnectTimer?.invalidate()
        log("Disconnected from server")
    }

    // MARK: - Subscriptions
    func subscribeToRoom(roomId: String, callback: @escaping (WebSocketMessage) -> Void) {
        let destination = "/topic/room.\(roomId)"
        subscriptions[destination] = callback
        if isConnected {
            log("Subscribed to \(destination)")
            // If server requires explicit subscription message, implement here
            // Example: publish(to: "/app/subscribe", body: "{\"destination\": \"\(destination)\"}")
        } else {
            log("Connection not ready, subscription to \(destination) will be applied on connect")
        }
    }

    // MARK: - Message Receiving
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let message):
                self.handleMessage(message)
                self.receiveMessage() // Continue receiving
            case .failure(let error):
                self.log("Receive error: \(error)")
                self.handleError(error)
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        if case .string(let string) = message {
            do {
                let data = Data(string.utf8)
                let webSocketMessage = try JSONDecoder().decode(WebSocketMessage.self, from: data)
                for (destination, callback) in subscriptions {
                    if string.contains(destination) {
                        log("Message received for \(destination): \(webSocketMessage)")
                        callback(webSocketMessage)
                    }
                }
            } catch {
                log("Failed to parse message: \(error), raw: \(string)")
            }
        }
    }

    // MARK: - Error Handling and Reconnection
    private func handleError(_ error: Error) {
        log("Error: \(error)")
        isConnected = false
        guard let config = config else { return }
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: config.reconnectDelay, repeats: false) { [weak self] _ in
            self?.log("Attempting to reconnect...")
            self?.setupWebSocket()
        }
    }

    // MARK: - Logging
    private func log(_ message: String) {
        if config?.debug ?? false {
            print("\(prefix) \(message)")
        }
    }
}

// MARK: - URLSessionWebSocketDelegate
extension WebSocketService: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        isConnected = true
        log("Connected to server")
        subscriptions.forEach { destination, _ in
            log("Re-subscribing to \(destination)")
            // If server requires explicit subscription message, send here
        }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        isConnected = false
        log("Disconnected from server")
        handleError(NSError(domain: "WebSocket", code: closeCode.rawValue, userInfo: nil))
    }
}

