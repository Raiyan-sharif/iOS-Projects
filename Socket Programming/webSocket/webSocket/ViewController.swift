//
//  ViewController.swift
//  webSocket
//
//  Created by Synesis Sqa on 29/4/25.
//

import UIKit

class ViewController: UIViewController, URLSessionWebSocketDelegate {
    
    private var webSocket: URLSessionWebSocketTask?
    
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        webSocket = session.webSocketTask(with: URL(string: "wss://s14558.blr1.piesocket.com/v3/1?api_key=eoR6VXNt1VL96y8Nw3iJdyYYJkD6wPgJm6BfdwWh&notify_self=1")!)
        
        webSocket?.resume()
        
        closeButton.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.center = view.center
    }
    
    func ping() {
        webSocket?.sendPing{ error in
            print("Ping error \(String(describing: error))")
        }
        
    }
    
    func send(){
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.webSocket?.send(.string("Send new Message \(Int.random(in: 0 ... 1000))"), completionHandler: { error in
                if let error = error {
                    print("Sending Error \(error)")
                }
                else{
                    self?.send()
                }
            })
        }
    }
    @objc func close() {
        webSocket?.cancel(with: .goingAway, reason: "Demo ended".data(using: .utf8))
    }
    func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .failure(let error):
                print("Sending Error : \(error)")
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Got Data : \(data)")
                case .string(let messageString):
                    print("Message Received \(messageString)")
                    
                @unknown default:
                break
                    
                }
                self?.receive()
                
            }
            
        })
        
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Did Connect to socket")
        ping()
        receive()
        send()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Did close socket")
    }


}

