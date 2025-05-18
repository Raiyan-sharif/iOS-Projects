//
//  YTPlayerView.swift
//  AVPlayerYoutube
//

import WebKit
import UIKit

protocol YTPlayerViewDelegate: AnyObject {
    func playerReady(_ playerView: YTPlayerView)
    func playerStateChanged(_ playerView: YTPlayerView, state: YTPlayerState)
    func playerError(_ playerView: YTPlayerView, error: YTPlayerError)
}

enum YTPlayerState: String {
    case unstarted = "-1"
    case ended = "0"
    case playing = "1"
    case paused = "2"
    case buffering = "3"
    case cued = "5"
    case unknown = "unknown"
}

enum YTPlayerError: String {
    case invalidParam = "2"
    case html5Error = "5"
    case videoNotFound = "100"
    case notEmbeddable = "101"
    case sameAsNotEmbeddable = "150"
    case unknown = "unknown"
}

class YTPlayerView: UIView, WKScriptMessageHandler {
    
    private var webView: WKWebView!
    weak var delegate: YTPlayerViewDelegate?
    
    private var initialVideoId: String = ""
    private var playerVars: [String: Any] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWebView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWebView()
    }

    private func setupWebView() {
        let contentController = WKUserContentController()
        contentController.add(self, name: "onYouTubeIframeAPIReady")
        contentController.add(self, name: "onReady")
        contentController.add(self, name: "onStateChange")
        contentController.add(self, name: "onError")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        webView = WKWebView(frame: bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(webView)

        loadHTML()
    }

    private func loadHTML() {
            let htmlString = """
            <!DOCTYPE html>
            <html>
            <body style="margin:0">
            <div id="player"></div>
            <script>
            var tag = document.createElement('script');
            tag.src = "https://www.youtube.com/iframe_api";
            var firstScriptTag = document.getElementsByTagName('script')[0];
            firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

            var player;
            function onYouTubeIframeAPIReady() {
                window.webkit.messageHandlers.onYouTubeIframeAPIReady.postMessage('');
            }

            function onPlayerReady(event) {
                window.webkit.messageHandlers.onReady.postMessage('');
                event.target.playVideo(); // Autoplay live stream
            }

            function onPlayerStateChange(event) {
                window.webkit.messageHandlers.onStateChange.postMessage(event.data.toString());
            }

            function onPlayerError(event) {
                window.webkit.messageHandlers.onError.postMessage(event.data.toString());
            }
            </script>
            </body>
            </html>
            """
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
        
        func load(withVideoId videoId: String, playerVars: [String: Any] = [:]) {
            // Ensure playerVars are suitable for live streams
            var updatedPlayerVars = playerVars
            updatedPlayerVars["autoplay"] = 1
            updatedPlayerVars["controls"] = 0
            updatedPlayerVars["playsinline"] = 1
            updatedPlayerVars["modestbranding"] = 1
            updatedPlayerVars["rel"] = 0
            // Remove start/end parameters if present, as they don't apply to live streams
            updatedPlayerVars.removeValue(forKey: "start")
            updatedPlayerVars.removeValue(forKey: "end")
            
            self.initialVideoId = videoId
            self.playerVars = updatedPlayerVars
            loadHTML()
        }

    // MARK: - JavaScript Communication

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
        case "onYouTubeIframeAPIReady":
            injectPlayer(videoId: initialVideoId, playerVars: playerVars)
        case "onReady":
            delegate?.playerReady(self)
        case "onStateChange":
            let state = YTPlayerState(rawValue: message.body as? String ?? "") ?? .unknown
            delegate?.playerStateChanged(self, state: state)
        case "onError":
            let error = YTPlayerError(rawValue: message.body as? String ?? "") ?? .unknown
            delegate?.playerError(self, error: error)
        default:
            break
        }
    }

    // MARK: - Player API

    // New load function that accepts playerVars dictionary
//    func load(withVideoId videoId: String, playerVars: [String: Any] = [:]) {
//        self.initialVideoId = videoId
//        self.playerVars = playerVars
//        loadHTML()
//    }
//    
    private func injectPlayer(videoId: String, playerVars: [String: Any]) {
        // Convert playerVars dictionary to JSON string
        guard let playerVarsData = try? JSONSerialization.data(withJSONObject: playerVars, options: []),
              let playerVarsJSON = String(data: playerVarsData, encoding: .utf8) else {
            print("Failed to serialize playerVars")
            return
        }
        
        let js = """
        player = new YT.Player('player', {
            height: '100%',
            width: '100%',
            videoId: '\(videoId)',
            playerVars: \(playerVarsJSON),
            events: {
                'onReady': onPlayerReady,
                'onStateChange': onPlayerStateChange,
                'onError': onPlayerError
            }
        });
        """
        webView.evaluateJavaScript(js, completionHandler: nil)
    }

    func playVideo() {
        webView.evaluateJavaScript("player.playVideo();", completionHandler: nil)
    }

    func pauseVideo() {
        webView.evaluateJavaScript("player.pauseVideo();", completionHandler: nil)
    }

    func stopVideo() {
        webView.evaluateJavaScript("player.stopVideo();", completionHandler: nil)
    }

    func seekTo(seconds: Float, allowSeekAhead: Bool) {
        let js = "player.seekTo(\(seconds), \(allowSeekAhead));"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
}


//import WebKit
//import UIKit
//
//protocol YTPlayerViewDelegate: AnyObject {
//    func playerReady(_ playerView: YTPlayerView)
//    func playerStateChanged(_ playerView: YTPlayerView, state: YTPlayerState)
//    func playerError(_ playerView: YTPlayerView, error: YTPlayerError)
//}
//
//enum YTPlayerState: String {
//    case unstarted = "-1"
//    case ended = "0"
//    case playing = "1"
//    case paused = "2"
//    case buffering = "3"
//    case cued = "5"
//    case unknown = "unknown"
//}
//
//enum YTPlayerError: String {
//    case invalidParam = "2"
//    case html5Error = "5"
//    case videoNotFound = "100"
//    case notEmbeddable = "101"
//    case sameAsNotEmbeddable = "150"
//    case unknown = "unknown"
//}
//
//class YTPlayerView: UIView, WKScriptMessageHandler {
//
//    private var webView: WKWebView!
//    weak var delegate: YTPlayerViewDelegate?
//    var initialVideoId: String = ""
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupWebView()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupWebView()
//    }
//
//    private func setupWebView() {
//        let contentController = WKUserContentController()
//        contentController.add(self, name: "onYouTubeIframeAPIReady")
//        contentController.add(self, name: "onReady")
//        contentController.add(self, name: "onStateChange")
//        contentController.add(self, name: "onError")
//
//        let config = WKWebViewConfiguration()
//        config.userContentController = contentController
//
//        webView = WKWebView(frame: bounds, configuration: config)
//        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        addSubview(webView)
//
//        loadHTML()
//    }
//
//    private func loadHTML() {
//        let htmlString = """
//        <!DOCTYPE html>
//        <html>
//        <body>
//        <div id="player"></div>
//        <script>
//        var tag = document.createElement('script');
//        tag.src = "https://www.youtube.com/iframe_api";
//        var firstScriptTag = document.getElementsByTagName('script')[0];
//        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
//
//        var player;
//        function onYouTubeIframeAPIReady() {
//            window.webkit.messageHandlers.onYouTubeIframeAPIReady.postMessage('');
//        }
//
//        function onPlayerReady(event) {
//            window.webkit.messageHandlers.onReady.postMessage('');
//        }
//
//        function onPlayerStateChange(event) {
//            window.webkit.messageHandlers.onStateChange.postMessage(event.data.toString());
//        }
//
//        function onPlayerError(event) {
//            window.webkit.messageHandlers.onError.postMessage(event.data.toString());
//        }
//        </script>
//        </body>
//        </html>
//        """
//        webView.loadHTMLString(htmlString, baseURL: nil)
//    }
//
//    // MARK: - JavaScript Communication
//
//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        switch message.name {
//        case "onYouTubeIframeAPIReady":
//            injectPlayer(videoId: "\(initialVideoId)") // sample video
//        case "onReady":
//            delegate?.playerReady(self)
//        case "onStateChange":
//            let state = YTPlayerState(rawValue: message.body as? String ?? "") ?? .unknown
//            delegate?.playerStateChanged(self, state: state)
//        case "onError":
//            let error = YTPlayerError(rawValue: message.body as? String ?? "") ?? .unknown
//            delegate?.playerError(self, error: error)
//        default:
//            break
//        }
//    }
//
//    // MARK: - Player API
//
//    func injectPlayer(videoId: String) {
//        let js = """
//        player = new YT.Player('player', {
//            height: '100%',
//            width: '100%',
//            videoId: '\(videoId)',
//            events: {
//                'onReady': onPlayerReady,
//                'onStateChange': onPlayerStateChange,
//                'onError': onPlayerError
//            }
//        });
//        """
//        webView.evaluateJavaScript(js, completionHandler: nil)
//    }
//
//    func playVideo() {
//        webView.evaluateJavaScript("player.playVideo();", completionHandler: nil)
//    }
//
//    func pauseVideo() {
//        webView.evaluateJavaScript("player.pauseVideo();", completionHandler: nil)
//    }
//
//    func stopVideo() {
//        webView.evaluateJavaScript("player.stopVideo();", completionHandler: nil)
//    }
//
//    func seekTo(seconds: Float, allowSeekAhead: Bool) {
//        let js = "player.seekTo(\(seconds), \(allowSeekAhead));"
//        webView.evaluateJavaScript(js, completionHandler: nil)
//    }
//}
//
//
