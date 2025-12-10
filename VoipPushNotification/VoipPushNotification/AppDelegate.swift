//
//  AppDelegate.swift
//  VoipPushNotification
//
//  Created by Raiyan Sharif on 10/12/25.
//

import UIKit
import PushKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        self.registerForPushNotifications()
        self.voipRegistration()
        // Override point for customization after application launch.
        return true
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
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        print("pushRegistry -> deviceToken :\(deviceToken)")
        print("VoIP push notification registration successful!")
    }
        
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("pushRegistry:didInvalidatePushTokenForType: \(type.rawValue)")
        print("VoIP push token was invalidated")
    }

    // Handle incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("Received VoIP push notification with payload: \(payload.dictionaryPayload)")
        print("Payload type: \(payload.type.rawValue)")
        completion()
    }
}

