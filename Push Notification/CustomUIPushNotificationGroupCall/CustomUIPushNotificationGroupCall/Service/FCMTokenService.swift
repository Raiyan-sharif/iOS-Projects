//  FcmTokenServices.swift
//  ConvayPushNotificationTest
//
//  Created by Raiyan Sharif on 4/7/25.
//

import Foundation
import FirebaseMessaging
import UserNotifications

class FcmTokenService {
    static let shared = FcmTokenService()
    private let storeTokenURL = "https://middletest.bcc.gov.bd:8001/store_fcm_token"
    private let updateTokenURL = "https://middletest.bcc.gov.bd:8001/update_fcm_token"

    private init() {}

    // Store FCM token
    func storeFcmToken(userId: String, fcmToken: String, completion: @escaping (Bool) -> Void) {
        let payload: [String: Any] = [
            "userId": userId,
            "fcmToken": fcmToken,
            "active": true
        ]
        guard let url = URL(string: storeTokenURL) else { completion(false); return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResp = response as? HTTPURLResponse, httpResp.statusCode == 200 {
                print("Successfully stored FCM token for user: \(userId)")
                completion(true)
            } else {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                print("Failed to store FCM token. Response: \(body)")
                completion(false)
            }
        }.resume()
    }

    // Update FCM token
    func updateFcmToken(userId: String, fcmToken: String, completion: @escaping (Bool) -> Void) {
        let payload: [String: Any] = [
            "userId": userId,
            "fcmToken": fcmToken,
            "active": true
        ]
        guard let url = URL(string: updateTokenURL) else { completion(false); return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResp = response as? HTTPURLResponse, httpResp.statusCode == 200 {
                print("Successfully updated FCM token for user: \(userId)")
                completion(true)
            } else {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
                print("Failed to update FCM token. Response: \(body)")
                completion(false)
            }
        }.resume()
    }

    // Ensure and store FCM token (like Android's ensureAndStoreFcmToken)
    func ensureAndStoreFcmToken(userId: String, completion: @escaping (Bool) -> Void) {
        Messaging.messaging().token { token, error in
            guard let token = token else {
                print("Failed to retrieve FCM token from Firebase: \(error?.localizedDescription ?? "Unknown error")")
                completion(false)
                return
            }
            print("FCM_TOKEN \(token)")
            self.storeFcmToken(userId: userId, fcmToken: token) { success in
                if success {
                    completion(true)
                } else {
                    self.updateFcmToken(userId: userId, fcmToken: token) { updateSuccess in
                        completion(updateSuccess)
                    }
                }
            }
        }
    }

    // Check if a valid FCM token exists
    func hasValidFcmToken(completion: @escaping (Bool) -> Void) {
        Messaging.messaging().token { token, error in
            completion(!(token?.isEmpty ?? true))
        }
    }
}

func registerNotificationCategories() {
    let joinAction = UNNotificationAction(identifier: "JOIN_CALL", title: "Join Call", options: [.foreground])
    let declineAction = UNNotificationAction(identifier: "DECLINE_CALL", title: "Decline", options: [.destructive])
    let category = UNNotificationCategory(identifier: "CALL_CATEGORY", actions: [declineAction, joinAction], intentIdentifiers: [], options: [])
    UNUserNotificationCenter.current().setNotificationCategories([category])
}

