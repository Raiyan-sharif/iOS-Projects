//
//  AppDelegate.swift
//  VoipPushNotification
//
//  Created by Raiyan Sharif on 10/12/25.
//

import UIKit
import PushKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // Store the VoIP device token for background push notifications
    var voipDeviceToken: String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        self.registerForPushNotifications()
        self.voipRegistration()
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if granted {
                        print("Notifications allowed ✅")
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                    } else {
                        print("Notifications denied ❌")
                    }
                }

            
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ application: UIApplication,
                         didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

            let token = deviceToken.map { String(format: "%02x", $0) }.joined()
            print("📱 APNs Device Token:", token)

            // Send this token to your backend to send push alerts
        }

        func application(_ application: UIApplication,
                         didFailToRegisterForRemoteNotificationsWithError error: Error) {
            print("❌ Failed to register for APNs:", error.localizedDescription)
        }
    
    // Register for VoIP notifications
    func voipRegistration() {
        print("Starting VoIP push notification registration...")

        // Create a push registry object
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]

        print("VoIP push registry created and configured")
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

//MARK: - PKPushRegistryDelegate
extension AppDelegate : PKPushRegistryDelegate {
    
    // Handle updated push credentials
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print("pushRegistry:didUpdateCredentials:forType: called with type: \(type.rawValue)")
        print("Raw token: \(credentials.token)")

        // Format the device token for background push notifications
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        self.voipDeviceToken = deviceToken

        print("pushRegistry -> deviceToken :\(deviceToken)")
        print("VoIP push notification registration successful!")

        // Store token for background push notifications
        self.storeDeviceTokenForBackgroundNotifications(deviceToken)
    }

    // Store and prepare device token for background push notifications
    private func storeDeviceTokenForBackgroundNotifications(_ token: String) {
        // Save token to UserDefaults for persistence across app launches
        UserDefaults.standard.set(token, forKey: "voipDeviceToken")
        UserDefaults.standard.synchronize()

        // Log token for debugging
        print("📱 VoIP Device Token stored for background notifications: \(token)")

        // TODO: Send token to your push notification server
        // self.sendTokenToServer(token)
    }

    // Get the current VoIP device token (formatted for background notifications)
    func getVoipDeviceToken() -> String? {
        // Try to get from memory first, then from UserDefaults
        if let token = self.voipDeviceToken {
            return token
        }

        // Fallback to stored token
        return UserDefaults.standard.string(forKey: "voipDeviceToken")
    }

    // Send device token to your push notification server
    private func sendTokenToServer(_ token: String) {
        // TODO: Implement your server API call here
        // Example implementation:
        /*
        guard let url = URL(string: "https://your-server.com/api/register-device") else { return }

        let payload: [String: Any] = [
            "deviceToken": token,
            "deviceType": "ios",
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("❌ Failed to serialize token payload: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Failed to send token to server: \(error)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                print("✅ Device token successfully sent to server")
            } else {
                print("❌ Server returned error when sending token")
            }
        }.resume()
        */

        print("📤 TODO: Implement sendTokenToServer with your backend API")
        print("🔗 Token ready for server: \(token)")
    }
        
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("pushRegistry:didInvalidatePushTokenForType: \(type.rawValue)")
        print("VoIP push token was invalidated")

        // Clear the stored token
        self.voipDeviceToken = nil
        UserDefaults.standard.removeObject(forKey: "voipDeviceToken")
        UserDefaults.standard.synchronize()

        print("🗑️ VoIP device token cleared from storage")
    }

    // Handle incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("Received VoIP push notification with payload: \(payload.dictionaryPayload)")
        print("Payload type: \(payload.type.rawValue)")
        completion()
    }
}

