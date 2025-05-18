//
//  AlertPushNotificationSwiftUIApp.swift
//  AlertPushNotificationSwiftUI
//
//  Created by Synesis Sqa on 14/5/25.
//

import SwiftUI
import UIKit
import UserNotifications


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerForNotifications()
        return true
    }
    
    func registerForNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) {
                success, error in
                if success {
                    print("Permission granted")
                } else {
                    print("Permission denied")
                }
            }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound])
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map{
            String(format: "%02.2hhx", $0)
        }.joined()
    }
    
}


@main
struct AlertPushNotificationSwiftUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
