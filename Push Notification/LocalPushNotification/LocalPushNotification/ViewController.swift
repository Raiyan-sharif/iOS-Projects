//
//  ViewController.swift
//  LocalPushNotification
//
//  Created by Synesis Sqa on 27/4/25.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkForPermission()
    }
    
    func checkForPermission() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                self.dispactchNotification()
            case .notDetermined:
                notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
                    if granted {
                        self.dispactchNotification()
                    }
                }
            case .denied:
                return
//            case .provisional:
//                return
//            case .ephemeral:
//                return
            default:
                return
            }
           
        }
    }
    
    func scheduleNotificationWithActions() {
        let content = UNMutableNotificationContent()
        content.title = "Meeting Reminder"
        content.body = "Your meeting starts in 10 minutes!"
        content.sound = UNNotificationSound.default

        let action1 = UNNotificationAction(identifier: "snoozeAction", title: "Snooze", options: [])
        let action2 = UNNotificationAction(identifier: "cancelAction", title: "Cancel", options: [.destructive])

        let category = UNNotificationCategory(identifier: "meetingCategory", actions: [action1, action2], intentIdentifiers: [], options: [])

        UNUserNotificationCenter.current().setNotificationCategories([category])

        content.categoryIdentifier = "meetingCategory"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)

        let request = UNNotificationRequest(identifier: "meetingNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification with actions scheduled successfully")
            }
        }
    }
    
    func dispactchNotification() {
        let identifier = "my_morning-notification"
        let title = "Time to work out!"
        let body = "Let have a exercise session"
        let hour = 10
        let minutes = 51
        let isDaily = true
        
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.body = body
        content.sound = .default
        
        let calendar = Calendar.current
        var dateComponents = DateComponents(calendar: calendar, timeZone: .current)
//        print(Calendar.current)
        dateComponents.hour = hour
        dateComponents.minute = minutes
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isDaily)
        let trigger2 = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled successfully")
                }
            }
        
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "snoozeAction":
            // Handle snooze action
            break
        case "cancelAction":
            // Handle cancel action
            break
        default:
            // Handle default action
            break
        }

        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Handle foreground presentation options
        completionHandler([.alert, .sound, .badge])
    }
}

