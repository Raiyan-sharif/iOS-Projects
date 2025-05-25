//
//  ViewController.swift
//  websocketSwiftStompClient
//
//

import UIKit
import StompClientLib

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
        guard let url = URL(string: "wss://meet2.synesisit.info:8001/ws/") else {
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

        WebSocketService.shared.subscribeToRoom(roomId: "room123") { [weak self] message in
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


