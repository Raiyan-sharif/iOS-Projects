import Starscream
import Foundation

class WebSocketManager: WebSocketDelegate {
    var socket: WebSocket!
    private var isStompConnected = false
    
    init(url: URL) {
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        socket = WebSocket(request: request)
        socket.delegate = self
    }
    
    func connect() {
        print("Attempting to connect to WebSocket: \(socket.request.url?.absoluteString ?? "unknown URL")")
        socket.connect()
    }
    
    func disconnect() {
        print("Disconnecting WebSocket...")
        socket.disconnect()
    }
    
    // MARK: - WebSocketDelegate Methods
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("WebSocket connected with headers: \(headers)")
            
        case .disconnected(let reason, let code):
            print("WebSocket disconnected: \(reason) with code: \(code)")
            isStompConnected = false
            
        case .text(let string):
            print("Received text: \(string)")
            handleSockJSMessage(string)
            
        case .binary(let data):
            print("Received binary data: \(data.count) bytes")
            
        case .error(let error):
            print("WebSocket error: \(String(describing: error))")
            if let wsError = error as? WSError {
                print("Error details: code=\(wsError.code), reason=\(wsError.message)")
            }
            
        case .cancelled:
            print("WebSocket connection cancelled")
            
        case .ping, .pong:
            print("Received ping/pong")
            
        case .viabilityChanged(let isViable):
            print("WebSocket viability changed: \(isViable)")
            
        case .reconnectSuggested(let shouldReconnect):
            print("WebSocket reconnect suggested: \(shouldReconnect)")
            
        default:
            print("Received unknown event: \(event)")
        }
    }
    
    // Handle SockJS protocol messages
    private func handleSockJSMessage(_ message: String) {
        if message == "o" {
            print("SockJS connection opened, sending STOMP CONNECT frame...")
            sendStompConnect()
        } else if message.hasPrefix("a[") {
            // SockJS array message containing STOMP frames
            let stompMessage = extractStompFromSockJS(message)
            handleStompMessage(stompMessage)
        } else if message.hasPrefix("c[") {
            print("SockJS connection closed: \(message)")
        } else if message == "h" {
            print("SockJS heartbeat received")
        } else {
            print("Unknown SockJS message: \(message)")
        }
    }
    
    // Extract STOMP message from SockJS array format
    private func extractStompFromSockJS(_ sockjsMessage: String) -> String {
        // Remove 'a[' prefix and ']' suffix, then parse JSON array
        let jsonString = String(sockjsMessage.dropFirst(2).dropLast(1))
        if let data = jsonString.data(using: .utf8),
           let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [String],
           let firstMessage = jsonArray.first {
            return firstMessage
        }
        return ""
    }
    
    // Handle STOMP protocol messages
    private func handleStompMessage(_ message: String) {
        print("Processing STOMP message: \(message)")
        
        if message.hasPrefix("CONNECTED") {
            print("STOMP connection established!")
            isStompConnected = true
            
            // Subscribe to a destination if needed
            subscribeToDestination("/topic/messages")
            
            // Send a test message
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.sendStompMessage(destination: "/app/hello", body: "Hello from iOS!")
            }
            
        } else if message.hasPrefix("ERROR") {
            print("STOMP error received: \(message)")
        } else if message.hasPrefix("MESSAGE") {
            print("STOMP message received: \(message)")
        } else {
            print("Unknown STOMP frame: \(message)")
        }
    }
    
    // Send STOMP CONNECT frame via SockJS
    func sendStompConnect() {
        let connectFrame = "CONNECT\naccept-version:1.1,1.0\nhost:meet2.synesisit.info\nheart-beat:10000,10000\n\n\0"
        
        // Wrap in SockJS format: ["message"]
        let sockjsMessage = "[\"" + connectFrame.replacingOccurrences(of: "\"", with: "\\\"").replacingOccurrences(of: "\n", with: "\\n").replacingOccurrences(of: "\0", with: "\\u0000") + "\"]"
        
        print("Sending STOMP CONNECT via SockJS:\n\(sockjsMessage)")
        socket.write(string: sockjsMessage)
    }
    
    // Subscribe to a destination
    func subscribeToDestination(_ destination: String) {
        guard isStompConnected else {
            print("Cannot subscribe: STOMP not connected")
            return
        }
        
        let subscribeFrame = "SUBSCRIBE\nid:sub-1\ndestination:\(destination)\n\n\0"
        let sockjsMessage = "[\"" + subscribeFrame.replacingOccurrences(of: "\"", with: "\\\"").replacingOccurrences(of: "\n", with: "\\n").replacingOccurrences(of: "\0", with: "\\u0000") + "\"]"
        
        print("Subscribing to \(destination)")
        socket.write(string: sockjsMessage)
    }
    
    // Send STOMP message
    func sendStompMessage(destination: String, body: String) {
        guard isStompConnected else {
            print("Cannot send message: STOMP not connected")
            return
        }
        
        let sendFrame = "SEND\ndestination:\(destination)\ncontent-type:text/plain\n\n\(body)\0"
        let sockjsMessage = "[\"" + sendFrame.replacingOccurrences(of: "\"", with: "\\\"").replacingOccurrences(of: "\n", with: "\\n").replacingOccurrences(of: "\0", with: "\\u0000") + "\"]"
        
        print("Sending STOMP message to \(destination): \(body)")
        socket.write(string: sockjsMessage)
    }
}
