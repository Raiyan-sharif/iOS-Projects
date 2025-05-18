import UIKit
import AVFoundation

class ViewController: UIViewController, YTPlayerViewDelegate {
    
    var playerView: YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerView = YTPlayerView()
        playerView.delegate = self
        playerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerView)
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        let playerVars: [String: Any] = [
            "autoplay": 1,
            "mute": 0,           // Ensure audio is not muted
            "controls": 0,       // Hide player controls
            "playsinline": 1,    // Play inline on iOS
            "rel": 0,            // No related videos
            "modestbranding": 1  // Minimal YouTube branding
        ]
        
        // Replace with your live stream video ID
        playerView.load(withVideoId: "4OiPOIljPB0", playerVars: playerVars)
        
        // Add observer for resuming playback after interruptions
        NotificationCenter.default.addObserver(self, selector: #selector(resumePlayback), name: NSNotification.Name("ResumePlayback"), object: nil)
        
        // Add observer for app entering foreground
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure player is ready when view appears
        playerView.playVideo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    @objc private func resumePlayback() {
        playerView.playVideo()
    }
    
    @objc private func appDidBecomeActive() {
        // Check player state and resume if needed
        playerView.playVideo()
    }
    
    // MARK: - YTPlayerViewDelegate
    
    func playerReady(_ playerView: YTPlayerView) {
        print("Player Ready")
        playerView.playVideo() // Ensure playback starts
    }
    
    func playerStateChanged(_ playerView: YTPlayerView, state: YTPlayerState) {
        print("Player state changed: \(state.rawValue)")
        switch state {
        case .buffering:
            print("Stream is buffering")
        case .ended:
            print("Stream ended, attempting to reload")
            // Reload the live stream if it ends unexpectedly
//            playerView.load(withVideoId: "YOUR_LIVE_STREAM_VIDEO_ID", playerVars: playerView.playerVars)
        case .unknown:
            print("Unknown state, checking connection")
        default:
            break
        }
    }
    
    func playerError(_ playerView: YTPlayerView, error: YTPlayerError) {
        print("Player error: \(error.rawValue)")
        // Attempt to reload on error
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.playerView.load(withVideoId: "YOUR_LIVE_STREAM_VIDEO_ID", playerVars: self.playerView.playerVars)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
