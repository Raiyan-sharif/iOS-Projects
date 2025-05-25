//
//  ViewController.swift
//  WebSocketStomClientProject
//
//

import Foundation
import UIKit
import StompClientLib

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
class WebSocketService: StompClientLibDelegate {
    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?, akaStringBody stringBody: String?, withHeader header: [String : String]?, withDestination destination: String) {
        print("\(jsonBody)")
    }
    
    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        print("\(receiptId)")
    }
    
    func serverDidSendPing() {
        print("Pingged")
    }
    

    
    
    static let shared = WebSocketService()
    private var socketClient: StompClientLib?
    private var config: WebSocketConfig?
    private var subscriptions: [String: (WebSocketMessage) -> Void] = [:]
    private let prefix = "CONVAY_WIDGET"

    func configure(with config: WebSocketConfig) {
        self.config = config
        socketClient = StompClientLib()
        connect()
    }

    func connect() {
        guard let config = config else {
            log("Error: WebSocketConfig not set")
            return
        }
        socketClient?.openSocketWithURLRequest(
            request: URLRequest(url: config.url) as NSURLRequest,
            delegate: self
        )
    }

    func disconnect() {
        socketClient?.disconnect()
        subscriptions.removeAll()
        log("Disconnected from server")
    }

    func subscribeToRoom(roomId: String, callback: @escaping (WebSocketMessage) -> Void) {
        let destination = "/topic/room.\(roomId)"
        subscriptions[destination] = callback
//        if socketClient?.socket?.isConnected ?? false {
            socketClient?.subscribe(destination: destination)
            log("Subscribed to \(destination)")
//        } else {
            log("Connection not ready, subscription to \(destination) will be applied on connect")
//        }
    }

    func stompClient(client: StompClientLib, didReceiveMessageWithJSONBody jsonBody: Any?, aka: String?, withHeader header: [String: String]?, withDestination destination: String) {
        guard let json = jsonBody as? [String: Any], let callback = subscriptions[destination] else {
            log("No callback for destination \(destination) or invalid JSON")
            return
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: json)
            let message = try JSONDecoder().decode(WebSocketMessage.self, from: data)
            log("Received message on \(destination): \(message)")
            callback(message)
        } catch {
            log("Failed to parse message: \(error), raw: \(String(describing: jsonBody))")
        }
    }

    func stompClientDidConnect(client: StompClientLib) {
        log("Connected to server")
        subscriptions.forEach { destination, _ in
            client.subscribe(destination: destination)
            log("Re-subscribing to \(destination)")
        }
    }

    func stompClientDidDisconnect(client: StompClientLib) {
        log("Disconnected from server")
        handleError(NSError(domain: "STOMP", code: -1, userInfo: nil))
    }

    func serverDidSendError(client: StompClientLib, withErrorMessage description: String, detailedErrorMessage message: String?) {
        log("STOMP Error: \(description)")
        handleError(NSError(domain: "STOMP", code: -1, userInfo: ["message": description]))
    }

    private func handleError(_ error: Error) {
        log("Error: \(error)")
        guard let config = config else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + config.reconnectDelay) {
            self.log("Attempting to reconnect...")
            self.connect()
        }
    }

    private func log(_ message: String) {
        if config?.debug ?? false {
            print("\(prefix) \(message)")
        }
    }
}



// MARK: - Sample View Controller
class ViewController: UIViewController {
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebSocket()
    }

    private func setupUI() {
        view.backgroundColor = .white
        statusLabel.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 50)
        statusLabel.text = "Waiting for messages..."
        statusLabel.textAlignment = .center
        view.addSubview(statusLabel)
    }

    private func setupWebSocket() {
        guard let url = URL(string: "wss://meet2.synesisit.info:8001/ws/516/qjgckwbq/websocket") else {
            statusLabel.text = "Invalid WebSocket URL"
            return
        }
        let config = WebSocketConfig(
            url: url,
            userId: "raiyan.sharif@synesisit.info",
            reconnectDelay: 5.0,
            debug: true
        )

        WebSocketService.shared.configure(with: config)
        WebSocketService.shared.connect()

        WebSocketService.shared.subscribeToRoom(roomId: "giIHoqCnTIYhiSfcjj") { [weak self] message in
            DispatchQueue.main.async {
                self?.statusLabel.text = "Call: \(message.callName), Status: \(message.status)"
                print("Received: Room: \(message.roomId), Call: \(message.callName), Status: \(message.status)")
            }
        }
    }

    deinit {
        WebSocketService.shared.disconnect()
    }
}

