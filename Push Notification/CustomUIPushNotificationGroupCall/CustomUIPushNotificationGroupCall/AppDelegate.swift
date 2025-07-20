//
//  AppDelegate.swift
//  CustomUIPushNotificationGroupCall
//
//  Created by Raiyan Sharif on 14/7/25.
//

import UIKit
import UserNotifications
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        firebaseConfig()
        notificationCenter()
        registerNotificationCategories()
        application.registerForRemoteNotifications()
        Messaging.messaging().isAutoInitEnabled = true
        
        return true
    }
    
    func getCurrentUserId() -> String? {
        // TODO: Replace with your actual user ID retrieval logic
        return "raiyan.sharifatsynesisit.info"
    }
    
    func notificationCenter() {
        let notifications = UNUserNotificationCenter.current()
        notifications.delegate = self

       notifications.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            print(granted ? "Notification Permission Granted" : "Notification Permission Denied")
        }

        let snooz = UNNotificationAction(identifier: "Snooz", title: "Snooz", options: .foreground)
        let delete = UNNotificationAction(identifier: "Delete", title: "Delete", options: .destructive)
        let category = UNNotificationCategory(identifier: "myNotificationCategory", actions: [snooz, delete], intentIdentifiers: [], options: [])
        notifications.setNotificationCategories([category])
    }
    
    func firebaseConfig() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }
    
    private func registerNotificationCategories() {
        let joinAction = UNNotificationAction(
            identifier: "JOIN_CALL",
            title: "📞 Join Call",
            options: [.foreground]
        )
        
        let declineAction = UNNotificationAction(
            identifier: "DECLINE_CALL",
            title: "❌ Decline",
            options: [.destructive]
        )
        
        // One-to-one call category
        let oneToOneCategory = UNNotificationCategory(
            identifier: "ONE_TO_ONE_CALL",
            actions: [declineAction, joinAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Group call category
        let groupCallCategory = UNNotificationCategory(
            identifier: "GROUP_CALL",
            actions: [declineAction, joinAction],
            intentIdentifiers: [],
            options: []
        )
        
        let categories = [ oneToOneCategory, groupCallCategory]
        UNUserNotificationCenter.current().setNotificationCategories(Set(categories))
        print("Notification categories registered successfully")
        print("Registered categories: \(categories.map { $0.identifier })")
        
        // Verify categories were registered
        UNUserNotificationCenter.current().getNotificationCategories { categories in
            print("Current notification categories: \(categories.map { $0.identifier })")
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Silent push received: \(userInfo)")

        let content = UNMutableNotificationContent()
        content.categoryIdentifier = "myNotificationCategory"
        content.title = userInfo["title"] as? String ?? "Photos"
        content.body = userInfo["body"] as? String ?? "This is new picture"
        content.sound = .default
        content.userInfo = userInfo

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request)

        completionHandler(.newData)
    }


    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}


extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        if let userId = getCurrentUserId() {
            FcmTokenService.shared.ensureAndStoreFcmToken(userId: userId) { success in
                print(success ? "Token sent to backend after APNS setup" : "Failed to send token to backend")
            }
        }
        print("APNS device token set successfully")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    
    // Handle silent notifications (data-only) when app is in background or killed
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("Received silent remote notification: \(userInfo)")
//        handleNotificationData(userInfo: userInfo)
    }
    
    // MARK: - Helper Methods
    
//    private func handleNotificationData(userInfo: [AnyHashable: Any]) {
//        print("Handling notification data: \(userInfo)")
//        
//        // Check if this is a data-only notification (no visual notification)
//        let aps = userInfo["aps"] as? [String: Any]
//        let isSilentNotification = aps?["content-available"] as? Int == 1
//        
//        // Handle active meetings data
//        if let activeMeetingsRaw = userInfo["active_meetings"] {
//            print("Active meetings raw data: \(activeMeetingsRaw)")
//            
//            var activeMeetings: [Any] = []
//            
//            if let activeMeetingsArray = activeMeetingsRaw as? [Any] {
//                // If it's already an array, use it directly
//                activeMeetings = activeMeetingsArray
//                print("Active meetings is already an array")
//            } else if let activeMeetingsString = activeMeetingsRaw as? String {
//                // If it's a string, try to parse it as JSON
//                print("Active meetings is a string, parsing JSON...")
//                if let data = activeMeetingsString.data(using: .utf8),
//                   let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [Any] {
//                    activeMeetings = jsonArray
//                    print("Successfully parsed JSON string to array")
//                } else {
//                    print("Failed to parse JSON string")
//                }
//            }
//            
//            if !activeMeetings.isEmpty {
//                print("Active meetings: \(activeMeetings)")
//                
//                // Simple fix: Always use the last meeting in the array (most recent)
//                if let meetingData = activeMeetings.last as? [String: Any] {
//                    SharedDataManager.shared.saveMeetingData(meetingData)
//                    
//                    // Add to call history
//                    SharedDataManager.shared.addCallToHistory(meetingData)
//                }
//                
//                // Show notification for meetings
//                showMeetingNotification(for: userInfo)
//            }
//        }
//    }
}

