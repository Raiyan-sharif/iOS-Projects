//
//  NotificationViewController.swift
//  groupcall
//
//  Created by Raiyan Sharif on 14/7/25.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        preferredContentSize.height = 300
        let content = notification.request.content
        if let contentImage = content.userInfo["urlImageString"] as? String {
            if let urlImage = URL(string: contentImage) {
                URLSession.shared.dataTask(with: urlImage) { (data, _, error) in
                    guard let data = data else { return }
                    DispatchQueue.main.async {
                        self.label?.text = "String(data: data, encoding: .utf8)"
                    }
                }.resume()
            }
            
        }
        self.label?.text = notification.request.content.body
        
    }

}
