import Foundation

class NativeWebSocketManager {
    private var webSocketTask: URLSessionWebSocketTask?
    private let url: URL
    private let session: URLSession
    private var isStompConnected = false
    
    init(url: URL) {
        self.url = url
        self.session = URLSession(configuration: .default)
    }
    
    func connect() {
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        print("NativeWebSocket: Connecting to \(url)")
        isStompConnected = false
        receive()
        sendStompConnect()
    }
    
    func disconnect() {
        print("NativeWebSocket: Disconnecting")
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        isStompConnected = false
    }
    
    func send(text: String) {
        let message = URLSessionWebSocketTask.Message.string(text)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("NativeWebSocket: Send error: \(error)")
            } else {
                print("NativeWebSocket: Sent message: \(text)")
            }
        }
    }
    
    func sendStompConnect() {
        let connectFrame = "CONNECT\naccept-version:1.1,1.0\nhost:meet2.synesisit.info\nheart-beat:10000,10000\n\n\u{0000}"
        send(text: connectFrame)
    }
    
    func sendStompMessage(destination: String, body: String) {
        guard isStompConnected else {
            print("NativeWebSocket: Cannot send message, STOMP not connected")
            return
        }
        let contentLength = body.data(using: .utf8)?.count ?? body.count
        let sendFrame = "SEND\ndestination:\(destination)\ncontent-type:text/plain\ncontent-length:\(contentLength)\n\n\(body)\u{0000}"
        send(text: sendFrame)
    }
    
    private func receive() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("NativeWebSocket: Receive error: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("NativeWebSocket: Received text: \(text)")
                    self?.handleStompMessage(text)
                case .data(let data):
                    print("NativeWebSocket: Received data: \(data.count) bytes")
                @unknown default:
                    print("NativeWebSocket: Received unknown message")
                }
                // Continue receiving
                self?.receive()
            }
        }
    }
    
    private func handleStompMessage(_ message: String) {
        if message.hasPrefix("CONNECTED") {
            print("NativeWebSocket: STOMP connection established!")
            isStompConnected = true
        } else if message.hasPrefix("ERROR") {
            print("NativeWebSocket: STOMP error received: \(message)")
        } else if message.hasPrefix("MESSAGE") {
            print("NativeWebSocket: STOMP message received: \(message)")
        } else {
            print("NativeWebSocket: Received: \(message)")
        }
    }
} 