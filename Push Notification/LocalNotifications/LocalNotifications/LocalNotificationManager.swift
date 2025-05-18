//
//  LocalNotificationManager.swift
//  LocalNotifications
//
//  Created by Raiyan Sharif on 13/5/25.
//

import Foundation
import NotificationCenter

@MainActor
class LocalNotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    @Published var isGranted: Bool = false
    @Published var pendingRequest: [UNNotificationRequest] = []
    
    override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        await getPendingRequeest()
        return [.sound, .banner]
    }
    
    func requestAuthorization() async throws {
        try await notificationCenter.requestAuthorization(options: [.sound, .badge, .alert])
        await getCurrentSetting()
    }
    
    func getCurrentSetting () async {
        let currentSettings = await notificationCenter.notificationSettings()
        
        isGranted = currentSettings.authorizationStatus == .authorized
        
        print(isGranted)
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString){
            if UIApplication.shared.canOpenURL(url) {
                Task{
                    print(url)
                    await UIApplication.shared.open(url)
                }
            }
            
        }
    }
    
    func schedule(localNotification: LocalNotification) async {
        let content = UNMutableNotificationContent()
        content.title = localNotification.title
        content.body = localNotification.body
        content.sound = UNNotificationSound.default
        var trigger: UNNotificationTrigger
        if localNotification.scheduleType == .time{
            guard let timeInterval = localNotification.timeInterval else { return }
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: localNotification.repeats)
            
        } else {
            guard let dateComponents = localNotification.dateComponents else { return }
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: localNotification.repeats)
        }
        let request = UNNotificationRequest(identifier: localNotification.identifier, content: content, trigger: trigger)
        try? await notificationCenter.add(request)
        await getPendingRequeest()
    }
    
    func getPendingRequeest() async {
        pendingRequest = await notificationCenter.pendingNotificationRequests()
        print("Pending Request Count: \(pendingRequest.count)")
    }
    
    func removeRequest(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        if let index = pendingRequest.firstIndex(where: { $0.identifier == identifier }) {
            pendingRequest.remove(at: index)
            print("Pending \(pendingRequest.count)")
        }
    }
    
    func clearAllRequests() {
        notificationCenter.removeAllPendingNotificationRequests()
        pendingRequest.removeAll()
    }
    
}


