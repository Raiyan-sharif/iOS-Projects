//
//  ViewController.swift
//  WebSocketStompClientProject
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
    static let shared = WebSocketService()
    
    private var socketClient = StompClientLib()
    private var config: WebSocketConfig?
    private var subscriptions: [String: (WebSocketMessage) -> Void] = [:]
    private let prefix = "CONVAY_WIDGET"
    private var pendingSubscriptions: Set<String> = ["!NzZdEMBforfKvTdMpv:convaychat.convay.com"]
    private var pendingNotifications: [WebSocketMessage] = []

    private func sendHello() {
        let destination = "/app/hello"
        let message = "Hello, server!"
        if socketClient.isConnected() {
            socketClient.sendMessage(message: message, toDestination: destination, withHeaders: nil, withReceipt: nil)
            log("Sent hello message")
        }
    }
    
    private func sendMeetingCheck() {
        let destination = "/app/meeting.check"
        let message = "[!NzZdEMBforfKvTdMpv:convaychat.convay.com]"
        if socketClient.isConnected() {
            socketClient.sendMessage(message: message, toDestination: destination, withHeaders: nil, withReceipt: nil)
            log("sendMeetingCheckmessage")
        }
    }

//    private func subscribeToErrorQueue() {
//        guard let userId = config?.userId else { return }
//        let destination = "/user/\(userId)/queue/errors"
////        subscribe(destination: destination) { message in
////            self.log("Error received: \(message)")
////        }
//    }

    private func checkActiveMeeting() {
        guard let lastRoomId = UserDefaults.standard.string(forKey: "mx_last_room_id") else {
            log("No last room ID found")
            return
        }
        let destination = "/app/meeting.check"
        let payload = "[\"\(lastRoomId)\"]"
        socketClient.sendMessage(message: payload, toDestination: destination, withHeaders: nil, withReceipt: nil)
        log("Sent active meeting check for room \(lastRoomId)")
    }
    
    private init() {}

    func configure(with config: WebSocketConfig) {
        self.config = config
        connect()
    }

    func connect() {
        guard let config = config else {
            log("Error: WebSocketConfig not set")
            return
        }
        let request = NSURLRequest(url: config.url)
//        request.setValuesForKeys(["Sec-Websocket-Accept" : "ZfpESQFXI4YGUA+2Z+E+Sp4VunU="])
        socketClient.openSocketWithURLRequest(request: request, delegate: self)
    }

    func disconnect() {
        socketClient.disconnect()
        subscriptions.removeAll()
        log("Disconnected from server")
    }

    func subscribeToRoom(roomId: String, callback: @escaping (WebSocketMessage) -> Void) {
        let destination = "/topic/room.\(roomId)"
            subscriptions[destination] = callback

            if socketClient.isConnected() {
                socketClient.subscribe(destination: destination)
                log("Subscribed to \(destination)")
                UserDefaults.standard.set(roomId, forKey: "mx_last_room_id")

                // Delay check meeting state like JS
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.checkActiveMeeting()
                }
            } else {
                pendingSubscriptions.insert(roomId)
                log("Connection not ready, queued subscription to \(destination)")
            }
    }
    
    private func subscribeToErrorQueue() {
        guard let userId = config?.userId else { return }
        let destination = "/user/\(userId)/queue/errors"
        socketClient.subscribe(destination: destination)
        subscriptions[destination] = { message in
            self.log("Error received: \(message)")
        }
        log("Subscribed to error queue at \(destination)")
    }
    
    private func subscribeToMeetingCheckQueue() {
        guard let userId = config?.userId else { return }
        let destination = "/user/\(userId)/queue/meeting_check"
        socketClient.subscribe(destination: destination)
        subscriptions[destination] = { message in
            self.log("Meeting check response: \(message)")
        }
        log("Subscribed to meeting check at \(destination)")
    }

    

    func sendCallNotification(_ message: WebSocketMessage) {
        let destination = "/app/notification.send"
            guard let jsonData = try? JSONEncoder().encode(message),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                log("Failed to encode message")
                return
            }

            if socketClient.isConnected() {
                socketClient.sendMessage(message: jsonString, toDestination: destination, withHeaders: nil, withReceipt: nil)
                log("Sent notification to \(destination): \(jsonString)")
            } else {
                log("Connection not ready, queued notification for \(message.roomId)")
                pendingNotifications.append(message)
            }
    }

    private func log(_ message: String) {
        if config?.debug ?? false {
            print("\(prefix) \(message)")
        }
    }

    // MARK: - StompClientLibDelegate Methods

    func stompClientDidConnect(client: StompClientLib!) {
        log("Connected to server")
        subscribeToErrorQueue()
        subscribeToMeetingCheckQueue()

           
           sendHello()
        sendMeetingCheck()


            // Re-subscribe to existing rooms
            for destination in subscriptions.keys {
                client.subscribe(destination: destination)
                log("subscribed to \(destination)")
            }

            // Process pending subscriptions
//            for roomId in pendingSubscriptions {
//                subscribeToRoom(roomId: roomId, callback: subscriptions["/topic/room.\(roomId)"]!)
//            }
//            pendingSubscriptions.removeAll()

            // Send any queued notifications
            for message in pendingNotifications {
                sendCallNotification(message)
            }
            pendingNotifications.removeAll()
    }

    func stompClientDidDisconnect(client: StompClientLib!) {
        log("Disconnected from server")
        attemptReconnect()
    }

    func stompClient(client: StompClientLib!, didReceiveMessageWithJSONBody jsonBody: AnyObject?,
                     akaStringBody stringBody: String?, withHeader header: [String: String]?, withDestination destination: String) {
        guard let json = jsonBody as? [String: Any],
              let callback = subscriptions[destination] else {
            log("No callback for destination \(jsonBody) or invalid JSON")
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

    func serverDidSendReceipt(client: StompClientLib!, withReceiptId receiptId: String) {
        log("Received receipt: \(receiptId)")
    }

    func serverDidSendPing() {
        log("Received ping")
    }

    func serverDidSendError(client: StompClientLib!, withErrorMessage description: String, detailedErrorMessage message: String?) {
        log("STOMP Error: \(description), Details: \(message ?? "")")
        attemptReconnect()
    }

    private func attemptReconnect() {
        guard let delay = config?.reconnectDelay else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.log("Attempting to reconnect...")
            self?.connect()
        }
    }
    
    func unsubscribeFromRoom(roomId: String) {
        let destination = "/topic/room.\(roomId)"
        if subscriptions[destination] != nil {
            socketClient.unsubscribe(destination: destination)
            subscriptions.removeValue(forKey: destination)
            log("Unsubscribed from \(destination)")
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
//        guard let url = URL(string: "wss://meet2.synesisit.info:8001/ws/516/giIHoqCnTIYhiSfcjj/websocket") else {
        guard let url = URL(string: "wss://bcc-ml.synesisit.info:8001/ws/websocket?userId=raiyan.sharifatsynesisit.info") else {
            statusLabel.text = "Invalid WebSocket URL"
            return
        }
        let config = WebSocketConfig(
            url: url,
            userId: "raiyan.sharifatsynesisit.info",
            reconnectDelay: 5.0,
            debug: true
        )

        WebSocketService.shared.configure(with: config)

        WebSocketService.shared.subscribeToRoom(roomId: "!NzZdEMBforfKvTdMpv:convaychat.convay.com") { [weak self] message in
            DispatchQueue.main.async {
                self?.statusLabel.text = "Call: \(message.callName), Status: \(message.status)"
                print("Received: Room: \(message.roomId), Call: \(message.callName), Status: \(message.status)")
            }
        }
        
//        WebSocketService.shared.sendCallNotification(WebSocketMessage(roomId: "NzZdEMBforfKvTdMpv", callName: , type: <#T##String#>, status: <#T##String#>, timestamp: <#T##Int64#>, senderId: <#T##String#>))
        
        
        
        
        
        
    }

    deinit {
        WebSocketService.shared.disconnect()
    }
}
