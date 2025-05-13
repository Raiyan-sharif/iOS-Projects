//
//  ViewController.swift
//  PIPApplication
//
//  Created by Synesis Sqa on 8/5/25.
//
import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {

    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var pipController: AVPictureInPictureController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
        setupPiP()
        setupAudioSession()
    }

    func setupPlayer() {
        guard let url = URL(string: "https://www.youtube.com/watch?v=MJEcookWYUI") else {
            print("Invalid URL")
            return
        }

        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = view.bounds
        view.layer.addSublayer(playerLayer)

        player.play()
    }

    func setupPiP() {
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            print("PiP not supported")
            return
        }

        pipController = AVPictureInPictureController(playerLayer: playerLayer)
        pipController?.delegate = self
    }

    func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, options: [.allowBluetooth, .defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Failed to set audio session: \(error)")
        }
    }
    
    func startPiPIfPossible() {
        if let pipController = pipController, AVPictureInPictureController.isPictureInPictureSupported(), !pipController.isPictureInPictureActive {
            pipController.startPictureInPicture()
        }
    }

    @IBAction func startPiPButtonTapped(_ sender: UIButton) {
        if let pipController = pipController, !pipController.isPictureInPictureActive {
            pipController.startPictureInPicture()
        }
    }

    @IBAction func stopPiPButtonTapped(_ sender: UIButton) {
        if let pipController = pipController, pipController.isPictureInPictureActive {
            pipController.stopPictureInPicture()
        }
    }
}

extension ViewController: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerDidStartPictureInPicture(_ controller: AVPictureInPictureController) {
        print("✅ PiP started")
    }

    func pictureInPictureController(_ controller: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
        print("❌ PiP failed to start: \(error)")
    }
}
