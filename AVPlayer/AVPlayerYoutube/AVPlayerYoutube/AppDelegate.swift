//
//  AppDelegate.swift
//  AVPlayerYoutube
//
//  Created by Synesis Sqa on 18/5/25.
//

import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure audio session for background playback
        configureAudioSession()
        
        // Add observer for audio interruptions
        NotificationCenter.default.addObserver(self, selector: #selector(handleAudioInterruption), name: AVAudioSession.interruptionNotification, object: nil)
        
        return true
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    
    @objc private func handleAudioInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            print("Audio interruption began")
            // Pause the player if needed (optional, as YouTube player may handle this)
        case .ended:
            print("Audio interruption ended")
            // Reactivate audio session
            configureAudioSession()
            // Notify ViewController to resume playback if needed
            NotificationCenter.default.post(name: NSNotification.Name("ResumePlayback"), object: nil)
        @unknown default:
            break
        }
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
