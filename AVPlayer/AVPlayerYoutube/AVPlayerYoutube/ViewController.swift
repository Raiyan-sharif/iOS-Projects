//
//  ViewController.swift
//  AVPlayerYoutube
//
import UIKit
import AVFoundation

class ViewController: UIViewController, YTPlayerViewDelegate {
    
    var playerView: YTPlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerView = YTPlayerView(frame: view.bounds)
        playerView.delegate = self
        view.addSubview(playerView)
        playerView.isUserInteractionEnabled = false

        let playerVars: [String: Any] = [
            "autoplay": 1,
               "mute": 0,           // 🔑 REQUIRED on iOS
               "controls": 0,
               "playsinline": 1,
               "rel": 0,
               "modestbranding": 1
        ]
//        playerView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            playerView.heightAnchor.constraint(equalToConstant: 300) // 👈 Increase height here
//        ])
        playerView.load(withVideoId: "7HgbcTqxoN4", playerVars: playerVars)
    }
    
    // MARK: - YTPlayerViewDelegate
    
    func playerReady(_ playerView: YTPlayerView) {
        print("Player Ready")
        // Optionally start playback here or it's auto playing
    }
    
    func playerStateChanged(_ playerView: YTPlayerView, state: YTPlayerState) {
        print("Player state changed: \(state.rawValue)")
    }
    
    func playerError(_ playerView: YTPlayerView, error: YTPlayerError) {
        print("Player error: \(error.rawValue)")
    }
}
