//
//  ViewController.swift
//  websocketStarscream
//
//  Created by Synesis Sqa on 22/5/25.
//

import UIKit
import Starscream


class ViewController: UIViewController {
    // Comment out the Starscream manager
    // var webSocketManager: WebSocketManager?
    var nativeWebSocketManager: NativeWebSocketManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let websocketUrl = URL(string: "wss://meet2.synesisit.info:8001/ws/424242/gzgagaasdfghjk/websocket?userId=raiyan.sharif@synesisit.info")!
        // Uncomment to use Starscream
        // webSocketManager = WebSocketManager(url: websocketUrl)
        // webSocketManager?.connect()
        // Use native WebSocket
        nativeWebSocketManager = NativeWebSocketManager(url: websocketUrl)
        nativeWebSocketManager?.connect()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // webSocketManager?.disconnect()
        nativeWebSocketManager?.disconnect()
    }
    @IBAction func sendMessageTapped(_ sender: Any) {
        // webSocketManager?.sendStompMessage(destination: "/app/chat", body: "Hello from iOS app!")
        nativeWebSocketManager?.sendStompMessage(destination: "/app/chat", body: "Hello from iOS app!")
    }
}
//class ViewController: UIViewController {
////    private let webSocketService = WebSocketService.shared
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let websocketUrl = URL(string: "wss://meet2.synesisit.info:8001/ws/424242/gzgagaasdfghjk/websocket?userId=dohil38518atdmener.com")!
//        let webSocketManager = WebSocketManager(url: websocketUrl)
//        webSocketManager.connect()
//        
//        // Configure the service
////        let config = WebSocketConfig(
////            url: "wss://meet2.synesisit.info:8001/ws",
////            userId: "raiyan.sharifatsynesisit.info",
////            debug: true
////        )
////        
////        webSocketService.configure(with: config)
////        
////        webSocketService.connect()
////        
////        // Subscribe to call notifications
////        NotificationCenter.default.addObserver(
////            self,
////            selector: #selector(handleCallNotification(_:)),
////            name: NSNotification.Name("CallNotificationReceived"),
////            object: nil
////        )
////        
////        // Subscribe to a room
////        webSocketService.subscribeToRoom("giIHoqCnTIYhiSfcjj")
//    }
//    
////    @objc private func handleCallNotification(_ notification: Notification) {
////        if let callNotification = notification.object as? CallNotification {
////            print("Received call notification: \(callNotification)")
////        }
////    }
////    
////    @IBAction func sendCallNotification(_ sender: UIButton) {
////        webSocketService.sendCallNotification(
////            roomId: "giIHoqCnTIYhiSfcjj",
////            callName: "Test Call",
////            type: .call,
////            status: .start
////        )
////    }
////    
////    deinit {
////        webSocketService.disconnect()
////        NotificationCenter.default.removeObserver(self)
////    }
//}
////class ViewController: UIViewController {
////    var socket: WebSocket!
////    var isConnected = false
////    let server = WebSocketServer()
////    
////    override func viewDidLoad() {
////        super.viewDidLoad()
//        //https://echo.websocket.org
////        var request = URLRequest(url: URL(string: "wss://meet2.synesisit.info:8001/ws")!) //https://localhost:8080
////        request.timeoutInterval = 5
////        socket = WebSocket(request: request)
////        socket.delegate = self
////        socket.connect()
////        let config = WebSocketConfig(
////            url: "https://meet2.synesisit.info:8001/ws", // Replace with actual endpoint
////            userId: "raiyan.sharifatsynesisit.info",
////            accessToken: "eyJhbGciOiJIUzUxMiJ9.eyJhY2Nlc3NfdG9rZW4iOiJzeXRfY21GcGVXRnVMbk5vWVhKcFptRjBjM2x1WlhOcGMybDBMbWx1Wm04X1R6TU1tTnVYZlFYdFFqdnBvbEx4XzBDbU9kRiIsInN1YiI6IjI5MTY3MWY5LTlmMjQtNGY0NC1iZGUyLThmNDA5NzI4MzczZSIsImRhdGEiOnsiZmVhdHVyZXMiOlsiQ2hhdCJdLCJ1c2VyX2VtYWlsIjoicmFpeWFuLnNoYXJpZkBzeW5lc2lzaXQuaW5mbyIsImxpY2Vuc2VfbmFtZSI6Ikhvc3QiLCJyb2xlIjoiT3duZXIiLCJvcmdhbml6YXRpb25faWQiOiIyZDgwMjNjMy00MTU2LTQ1YWMtOTNmYy04NDgzMTZlZGFlYzAiLCJvcmdhbml6YXRpb25fbmFtZSI6IlJhaXlhbidzIE9yZ2FuaXphdGlvbiIsIklEIjoiMjkxNjcxZjktOWYyNC00ZjQ0LWJkZTItOGY0MDk3MjgzNzNlIiwidmFuaXR5X3VybCI6bnVsbCwiZGlzcGxheV9uYW1lIjoiUmFpeWFuIFNoYXJpZiIsIm9yZ2FuaXphdGlvbl9sb2dvIjpudWxsfSwiZGV2aWNlX2lkIjoiVFdSU0JGUUdTTyIsInVzZXJfaWQiOiJAcmFpeWFuLnNoYXJpZmF0c3luZXNpc2l0LmluZm86bWF0cml4b3AuY29udmF5LmNvbSIsIndlbGxfa25vd24iOm51bGwsInBlcm1pc3Npb24iOnsidmlld19ncm91cCI6dHJ1ZSwiYWRkX3JvbGUiOnRydWUsInZpZXdfb3JnYW5pemF0aW9uIjp0cnVlLCJlZGl0X3VzZXIiOnRydWUsImVkaXRfb3JnYW5pemF0aW9uIjp0cnVlLCJlZGl0X2dyb3VwIjp0cnVlLCJkZWxldGVfcm9sZSI6dHJ1ZSwidmlld19yb2xlIjp0cnVlLCJlZGl0X3JvbGUiOnRydWUsInZpZXdfbWVldGluZyI6dHJ1ZSwiYWRkX3dyb3VwIjp0cnVlLCJ2aWV3X2Rhc2hib2FyZCI6dHJ1ZSwidmlld191c2VyIjp0cnVlLCJkZWxldGVfdXNlciI6dHJ1ZSwiYWRkX3VzZXIiOnRydWUsImRlbGV0ZV9ncm91cCI6dHJ1ZX0sImV4cCI6MTc1MDY2NTM1OSwiaWF0IjoxNzQ4MDczMzU5LCJob21lX3NlcnZlciI6Im1hdHJpeG9wLmNvbnZheS5jb20ifQ .7 pN3Y_fHfeawvy8rEdaX9Hy4oPKELvQ_8sytXnSMoWZkAnRY4TOLosD0dfsoMIIESRRrpjl1hwDMjsocTC3fYA",
////            reconnectDelay: 5.0,
////            heartbeatIncoming: 4.0,
////            heartbeatOutgoing: 4.0,
////            debug: true
////        )
////        WebSocketService.initialize(with: config)
////        do{
////            try WebSocketService.shared.connect()
////        }catch  {
////            
////        }
////        WebSocketService.shared.subscribeToRoom(roomId: "giIHoqCnTIYhiSfcjj")
////        WebSocketService.shared.sendCallNotification(
////            roomId: "giIHoqCnTIYhiSfcjj",
////            callName: "Public 1",
////            type: MessageType.notification.rawValue,
////            status: CallStatus.start.rawValue
////        )
//        
//        
////    }
//    
//    // MARK: - WebSocketDelegate
////    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
////        switch event {
////        case .connected(let headers):
////            isConnected = true
////            print("websocket is connected: \(headers)")
////        case .disconnected(let reason, let code):
////            isConnected = false
////            print("websocket is disconnected: \(reason) with code: \(code)")
////        case .text(let string):
////            print("Received text: \(string)")
////        case .binary(let data):
////            print("Received data: \(data.count)")
////        case .ping(_):
////            break
////        case .pong(_):
////            break
////        case .viabilityChanged(_):
////            break
////        case .reconnectSuggested(_):
////            break
////        case .cancelled:
////            isConnected = false
////        case .error(let error):
////            isConnected = false
////            handleError(error)
////        case .peerClosed:
////            break
////        }
////    }
////    
////    func handleError(_ error: Error?) {
////        if let e = error as? WSError {
////            print("websocket encountered an error: \(e.message)")
////        } else if let e = error {
////            print("websocket encountered an error: \(e.localizedDescription)")
////        } else {
////            print("websocket encountered an error")
////        }
////    }
//
////    @IBAction func stopWebsocket(_ sender: Any) {
////        if isConnected {
////                    socket.disconnect()
////                } else {
////                    socket.connect()
////                }
////        
////    }
////    @IBAction func writeMessage(_ sender: Any) {
////        socket.write(string: "hello there!")
////    }
////    
////}
////
