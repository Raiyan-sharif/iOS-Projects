//
//  ViewController.swift
//  PIPApplication2
//
//  Created by Synesis Sqa on 10/5/25.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {

    // MARK: - Properties
    private var pipController: AVPictureInPictureController?
    private var videoCallView: UIView!
    private var localVideoView: UIView!
    private var remoteVideoView: UIView!
    private var pipButton: UIButton!
    
    // Sample video layer for demonstration
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPiPController()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoCallView.frame = view.bounds
        playerLayer?.frame = videoCallView.bounds
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .black
        
        // Main container for video call
        videoCallView = UIView()
        videoCallView.backgroundColor = .black
        view.addSubview(videoCallView)
        
        // Remote video view (typically the larger one)
        remoteVideoView = UIView()
        remoteVideoView.backgroundColor = .darkGray
        remoteVideoView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        videoCallView.addSubview(remoteVideoView)
        
        // Local video view (typically smaller, overlaid on remote)
        localVideoView = UIView()
        localVideoView.backgroundColor = .lightGray
        localVideoView.frame = CGRect(x: view.bounds.width - 150, y: 50, width: 120, height: 180)
        localVideoView.layer.cornerRadius = 12
        localVideoView.clipsToBounds = true
        videoCallView.addSubview(localVideoView)
        
        // PiP toggle button
        pipButton = UIButton(type: .system)
        pipButton.setTitle("Start PiP", for: .normal)
        pipButton.setTitleColor(.white, for: .normal)
        pipButton.backgroundColor = .systemBlue
        pipButton.layer.cornerRadius = 8
        pipButton.frame = CGRect(x: 20, y: view.bounds.height - 100, width: 120, height: 44)
        pipButton.addTarget(self, action: #selector(togglePiP), for: .touchUpInside)
        view.addSubview(pipButton)
        
        // For demonstration, we'll use a video player
        setupSampleVideoPlayer()
    }
    
    private func setupSampleVideoPlayer() {
        // This would be replaced with your actual video call implementation
        // For demonstration, we're using a video file
        guard let url = Bundle.main.url(forResource: "sample_video", withExtension: "mp4") else {
            // Replace with your video URL or capture session
            let sampleURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!
            player = AVPlayer(url: sampleURL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resizeAspectFill
            remoteVideoView.layer.addSublayer(playerLayer!)
            player?.play()
            return
        }
        
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        remoteVideoView.layer.addSublayer(playerLayer!)
        player?.play()
    }
    
    private func setupPiPController() {
        // Check if PiP is supported on this device
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            print("PiP is not supported on this device")
            pipButton.isEnabled = false
            return
        }
        
        // Create a PiP controller with the video layer
        guard let playerLayer = self.playerLayer else { return }
        
        pipController = AVPictureInPictureController(playerLayer: playerLayer)
        pipController?.delegate = self
        
        // Configure PiP behavior
        if #available(iOS 14.2, *) {
            pipController?.canStartPictureInPictureAutomaticallyFromInline = true
        }
    }
    
    // MARK: - Actions
    @objc private func togglePiP() {
        guard let pipController = pipController else { return }
        
        if pipController.isPictureInPictureActive {
            pipController.stopPictureInPicture()
        } else {
            pipController.startPictureInPicture()
        }
    }
    
    // MARK: - Custom Video Call Implementation
    
    // This is where you would implement your actual video call functionality
    // For a real implementation, you might use a framework like WebRTC, Twilio, Agora, etc.
    
    func startVideoCall() {
        // Initialize your video call SDK here
        // Setup camera capture
        // Connect to your signaling server
        // etc.
    }
    
    func endVideoCall() {
        // Clean up resources
        player?.pause()
        pipController?.stopPictureInPicture()
    }


}


// MARK: - AVPictureInPictureControllerDelegate
extension ViewController: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP will start")
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP did start")
        pipButton.setTitle("Stop PiP", for: .normal)
    }
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP will stop")
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP did stop")
        pipButton.setTitle("Start PiP", for: .normal)
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("Failed to start PiP: \(error.localizedDescription)")
    }
}


