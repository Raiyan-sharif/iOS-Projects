# Convay Meet iOS SDK

The Convay Meet iOS SDK provides the same user experience as the Convay Meet app, in a customizable way which you can embed in your apps.

> **Important**: iOS 13.0 or higher is required.

## Sample applications using the SDK

If you want to see how easy integrating the Convay Meet SDK into a native application is, take a look at the [sample applications repository](https://github.com/Synesis-IT-PLC/convay-meet-sdk-samples/tree/main/iOS).

## Usage

There are 3 ways to integrate the SDK into your project:

* Using Swift Package Manager (SPM) - Recommended
* Using CocoaPods
* Manual installation from GitHub Releases

### Using Swift Package Manager

The recommended way for using the SDK is by using Swift Package Manager.

#### Step 1: Add Package in Xcode

1. Open your project in Xcode
2. Go to **File** → **Add Package Dependencies...**
3. Enter the repository URL:
   ```
   https://github.com/Synesis-IT-PLC/convay-meet-ios-sdk-releases.git
   ```
4. Select the version you want to use (or use the latest version)
5. Click **Add Package**
6. Select the `ConvayMeetSDK` product and add it to your target
7. Click **Add Package**

The SDK and all its dependencies are automatically included. No additional setup required!

**Note**: Check [Releases](https://github.com/Synesis-IT-PLC/convay-meet-ios-sdk-releases/releases) for available versions.

#### Step 2: Configure Info.plist

Since the SDK requests camera and microphone access, make sure to include the required entries for `NSCameraUsageDescription` and `NSMicrophoneUsageDescription` in your `Info.plist` file:

```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera for video calls</string>

<key>NSMicrophoneUsageDescription</key>
<string>We need access to your microphone for audio calls</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to share images</string>
```

In order for app to properly work in the background, select the "audio" and "voip" background modes in your target's **Signing & Capabilities** tab.

Since the SDK shows and hides the status bar based on the conference state, you may want to set `UIViewControllerBasedStatusBarAppearance` to `NO` in your `Info.plist` file.

#### Step 3: Configure AppDelegate

Your `AppDelegate` needs to include the following setup for the SDK to work properly:

```swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setenv("OBJC_DISABLE_LOADING_WEAK_LIBRARIES", "1", 1)
        if window == nil {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        return true
    }
}
```

**Important:**
- The `setenv("OBJC_DISABLE_LOADING_WEAK_LIBRARIES", "1", 1)` call is required for the SDK to function correctly
- The `window` property must be declared and initialized if it's `nil`
- This setup is required regardless of whether you're using Scene-based or traditional window-based app lifecycle

### Using CocoaPods

The SDK can also be integrated using CocoaPods. In order to do so, add the `ConvayMeetSDK` dependency to your existing `Podfile` or create a new one following this example:

```ruby
platform :ios, '13.0'

target 'YourApp' do
  pod 'ConvayMeetSDK', :podspec => 'https://github.com/Synesis-IT-PLC/convay-meet-ios-sdk-releases/raw/main/ConvayMeetSDK.podspec'
end
```

Replace `YourApp` with your project and target names.

Then install the dependencies:

```bash
pod install
```

After installation, open your workspace:

```bash
open YourApp.xcworkspace
```

**Note**: Make sure to use the `.xcworkspace` file, not the `.xcodeproj` file when working with CocoaPods.

### Manual Installation from GitHub Releases

1. Download the XCFramework from the [GitHub Release](https://github.com/Synesis-IT-PLC/convay-meet-ios-sdk-releases/releases)
2. Extract the zip file
3. In Xcode, select your project in the Project Navigator
4. Select your app target
5. Go to **General** tab
6. Scroll to **Frameworks, Libraries, and Embedded Content**
7. Click the **+** button
8. Click **Add Other... → Add Files...**
9. Navigate to the extracted `ConvayMeetSDK.xcframework`
10. Click **Open**
11. Ensure **Embed & Sign** is selected

## API

ConvayMeet is an iOS framework which embodies the whole Convay Meet experience and makes it reusable by third-party apps.

To get started:

1. Add a `ConvayMeetView` to your app using a Storyboard or Interface Builder, for example.
2. Then, once the view has loaded, set the delegate in your controller and load the desired URL:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    let convayMeetView = ConvayMeetView()
    convayMeetView.delegate = self
    
    let options = ConvayMeetConferenceOptions.fromBuilder { (builder) in
        builder.serverURL = URL(string: "https://convay.com")
        builder.room = "test123"
        builder.audioOnly = false
    }
    
    convayMeetView.join(options)
}
```

### ConvayMeetView class

The `ConvayMeetView` class is the entry point to the SDK. It is a subclass of `UIView` which renders a full conference in the designated area.

#### delegate

Property to get/set the `ConvayMeetViewDelegate` on `ConvayMeetView`.

#### join(_ options: ConvayMeetConferenceOptions)

Joins the conference specified by the given options.

```swift
let options = ConvayMeetConferenceOptions.fromBuilder { (builder) in
    builder.serverURL = URL(string: "https://convay.com")
    builder.room = "test123testing"
    builder.audioOnly = false
    builder.audioMuted = false
    builder.videoMuted = false
    builder.setFeatureFlag("prejoinpage.enabled", withValue: false)
    builder.setFeatureFlag("chat.enabled", withValue: true)
    builder.setFeatureFlag("ios.screensharing.enabled", withBoolean: true)
}

convayMeetView.join(options)
```

#### leave()

Leaves the currently active conference.

#### hangUp()

The localParticipant leaves the current conference.

#### setAudioMuted(_ muted: Bool)

Sets the state of the localParticipant audio muted according to the `muted` parameter.

#### setVideoMuted(_ muted: Bool)

Sets the state of the localParticipant video muted according to the `muted` parameter.

#### sendEndpointTextMessage(_ message: String, to participantId: String?)

Sends a message via the data channel to one particular participant or to all of them. If the `participantId` param is `nil`, the message will be sent to all the participants in the conference.

In order to get the participantId, the `PARTICIPANT_JOINED` event should be listened for, which `data` includes the id and this should be stored somehow.

#### toggleScreenShare(_ enabled: Bool)

Sets the state of the localParticipant screen sharing according to the `enabled` parameter.

#### openChat(to participantId: String?)

Opens the chat dialog. If `participantId` contains a valid participantId, the private chat with that particular participant will be opened.

#### sendChatMessage(_ message: String, to participantId: String?)

Sends a chat message to one particular participant or to all of them. If the `participantId` param is `nil`, the message will be sent to all the participants in the conference.

In order to get the participantId, the `PARTICIPANT_JOINED` event should be listened for, which `data` includes the id and this should be stored somehow.

#### closeChat()

Closes the chat dialog.

#### retrieveParticipantsInfo(_ completionHandler: @escaping ([AnyHashable : Any]) -> Void)

Retrieves the participants information in the completionHandler sent as parameter.

### ConvayMeetViewDelegate

The `ConvayMeetViewDelegate` protocol allows you to respond to conference events.

#### conferenceWillJoin(_ data: [AnyHashable : Any]!)

Called when the conference is about to join.

#### conferenceJoined(_ data: [AnyHashable : Any]!)

Called when the conference has successfully joined.

```swift
func conferenceJoined(_ data: [AnyHashable : Any]!) {
    print("Conference joined - Data: \(String(describing: data))")
}
```

#### conferenceTerminated(_ data: [AnyHashable : Any]!)

Called when the conference has terminated.

```swift
func conferenceTerminated(_ data: [AnyHashable : Any]!) {
    print("Conference terminated")
    dismiss(animated: true)
}
```

#### ready(toClose data: [AnyHashable : Any]!)

Called when the SDK is ready to close. This is a good place to clean up the view.

```swift
func ready(toClose data: [AnyHashable : Any]!) {
    UIView.animate(withDuration: 0.3, animations: {
        self.convayMeetView?.alpha = 0
    }) { _ in
        self.convayMeetView?.removeFromSuperview()
        self.convayMeetView = nil
        self.pipViewCoordinator = nil
    }
}
```

#### enterPicture(inPicture data: [AnyHashable : Any]!)

Called when the user enters picture-in-picture mode.

```swift
func enterPicture(inPicture data: [AnyHashable : Any]!) {
    pipViewCoordinator?.enterPictureInPicture()
}
```

### Picture-in-Picture

The SDK supports Picture-in-Picture (PiP) functionality through the `PiPViewCoordinator` class.

#### Setting up PiP

```swift
import UIKit
import ConvayMeetSDK

class ConferenceViewController: UIViewController, ConvayMeetViewDelegate {
    
    var convayMeetView: ConvayMeetView!
    var pipViewCoordinator: PiPViewCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and configure the view
        convayMeetView = ConvayMeetView()
        convayMeetView.delegate = self
        
        // Add to view hierarchy
        view.addSubview(convayMeetView)
        convayMeetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            convayMeetView.topAnchor.constraint(equalTo: view.topAnchor),
            convayMeetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            convayMeetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            convayMeetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Setup PiP coordinator
        pipViewCoordinator = PiPViewCoordinator(withView: convayMeetView)
        
        // Join conference
        let options = ConvayMeetConferenceOptions.fromBuilder { (builder) in
            builder.serverURL = URL(string: "https://convay.com")
            builder.room = roomName
        }
        
        convayMeetView.join(options)
    }
    
    func enterPicture(inPicture data: [AnyHashable : Any]!) {
        pipViewCoordinator?.enterPictureInPicture()
    }
}
```

**Important Notes:**
- `PiPViewCoordinator` doesn't have `configureAsStickyView()`, `show()`, or `hide()` methods
- Add the `ConvayMeetView` directly to your view hierarchy using Auto Layout
- Use `UIView.animate` for show/hide animations
- Use `enterPictureInPicture()` method for PiP functionality

### Generating Meeting Room URL from API

**Important:** Meeting room URLs must be generated from the Convay Meeting API. You cannot use arbitrary room names.

**Step 1:** Call Start Meeting or Join Meeting API:
```
POST https://convay.com/services/vcmeetingsettings/meeting/calender/start-meeting?type=instant
Authorization: Bearer {authToken}
```

**Step 2:** Get response with `token` and `calendarId`:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "calendarId": "1234567890"
}
```

**Step 3:** Construct meeting room URL:
```
{meetingPanelBaseUrl}/{calendarId}?jwt={token}
```

Example roomName: `https://mergemeet.convay.com/0000019b-79db-e96c-0000-000000040688?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...`

### Conference Options

#### Basic Configuration

```swift
let options = ConvayMeetConferenceOptions.fromBuilder { (builder) in
    builder.serverURL = URL(string: "https://convay.com")
    builder.room = roomName
    builder.subject = "My Meeting"
}
```

#### Using Token Authentication

```swift
let options = ConvayMeetConferenceOptions.fromBuilder { (builder) in
    builder.token = "your-jwt-token-here"
    builder.serverURL = URL(string: "https://convay.com")
    builder.room = roomName
}
```

#### Using Meeting Link

```swift
let options = ConvayMeetConferenceOptions.fromBuilder { (builder) in
    builder.meetingLink = "https://convay.com/m/j/meeting-id"
    builder.authToken = "your-auth-token-here"
}
```

#### Feature Flags

Control which features are enabled:

```swift
builder.setFeatureFlag("prejoinpage.enabled", withValue: false)
builder.setFeatureFlag("chat.enabled", withValue: true)
builder.setFeatureFlag("invite.enabled", withValue: true)
builder.setFeatureFlag("recording.enabled", withValue: false)
builder.setFeatureFlag("live-streaming.enabled", withValue: false)
builder.setFeatureFlag("pip.enabled", withValue: true)
builder.setFeatureFlag("ios.screensharing.enabled", withBoolean: true)
```

#### User Information

```swift
let userInfo = ConvayMeetUserInfo(displayName: "John Doe",
                                andEmail: "john@example.com",
                                andAvatar: URL(string: "https://example.com/avatar.png"))
builder.userInfo = userInfo
```

#### Audio/Video Settings

```swift
builder.audioOnly = false
builder.audioMuted = false
builder.videoMuted = false
```

### Universal / Deep Linking

In order to support Universal / deep linking, `ConvayMeet` offers class methods that your app's delegate should call in order for the app to follow those links.

If these functions return `false` it means the URL wasn't handled by the SDK. This is useful when the host application uses other SDKs which also use linking.

```swift
func application(_ app: UIApplication, 
                open url: URL, 
                options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return ConvayMeet.sharedInstance().application(app, open: url, options: options)
}

func application(_ application: UIApplication, 
                continue userActivity: NSUserActivity, 
                restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    return ConvayMeet.sharedInstance().application(application, 
                                                   continue: userActivity, 
                                                   restorationHandler: restorationHandler)
}
```

## Screen Sharing Integration

The SDK supports iOS screen sharing through a Broadcast Upload Extension. This allows users to share their screen during a conference.

### Creating the Broadcast Upload Extension

1. In Xcode, go to **File** → **New** → **Target...**
2. Select **Broadcast Upload Extension** (without UI)
3. Name it (e.g., "BroadcastExtension")
4. Update deployment info to run in iOS 14 or newer
5. Make sure both the app and the extension are added to the same App Group

### Setting up the Socket Connection

The extension needs to communicate with the SDK through a socket connection. You'll need to:

1. Add both the app and the extension to the same App Group
2. Add the app group id value to the app's `Info.plist` for the `RTCAppGroupIdentifier` key
3. Add a new key `RTCScreenSharingExtension` to the app's `Info.plist` with the extension's `Bundle Identifier` as the value

### Sample Implementation

The extension needs to handle video buffers and manage the connection. You'll need to create the following files in your Broadcast Upload Extension target:

#### Atomic.swift

This file provides thread-safe atomic operations using a property wrapper:

```swift
import Foundation

@propertyWrapper
struct Atomic<Value> {

    private var value: Value
    private let lock = NSLock()

    init(wrappedValue value: Value) {
        self.value = value
    }

    var wrappedValue: Value {
      get { return load() }
      set { store(newValue: newValue) }
    }

    func load() -> Value {
        lock.lock()
        defer { lock.unlock() }
        return value
    }

    mutating func store(newValue: Value) {
        lock.lock()
        defer { lock.unlock() }
        value = newValue
    }
}
```

#### DarwinNotificationCenter.swift

This file provides system-wide notifications for communication between the app and extension:

```swift
/*
 * Copyright @ 2021-present 8x8, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

enum DarwinNotification: String {
    case broadcastStarted = "iOS_BroadcastStarted"
    case broadcastStopped = "iOS_BroadcastStopped"
}

class DarwinNotificationCenter {
    
    static var shared = DarwinNotificationCenter()
    
    private var notificationCenter: CFNotificationCenter
    
    init() {
        notificationCenter = CFNotificationCenterGetDarwinNotifyCenter()
    }
    
    func postNotification(_ name: DarwinNotification) {
        CFNotificationCenterPostNotification(notificationCenter, CFNotificationName(rawValue: name.rawValue as CFString), nil, nil, true)
    }
}
```

#### SocketConnection.swift

This file manages the socket connection between the extension and the app:

```swift
/*
 * Copyright @ 2021-present 8x8, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation

class SocketConnection: NSObject {
    var didOpen: (() -> Void)?
    var didClose: ((Error?) -> Void)?
    var streamHasSpaceAvailable: (() -> Void)?

    private let filePath: String
    private var socketHandle: Int32 = -1
    private var address: sockaddr_un?

    private var inputStream: InputStream?
    private var outputStream: OutputStream?
    
    private var networkQueue: DispatchQueue?
    private var shouldKeepRunning = false

    init?(filePath path: String) {
        filePath = path
        socketHandle = Darwin.socket(AF_UNIX, SOCK_STREAM, 0)

        guard socketHandle != -1 else {
            print("failure: create socket")
            return nil
        }
    }

    func open() -> Bool {
        print("open socket connection")

        guard FileManager.default.fileExists(atPath: filePath) else {
            print("failure: socket file missing")
            return false
        }
      
        guard setupAddress() == true else {
            return false
        }
        
        guard connectSocket() == true else {
            return false
        }

        setupStreams()
        
        inputStream?.open()
        outputStream?.open()

        return true
    }

    func close() {
        unscheduleStreams()

        inputStream?.delegate = nil
        outputStream?.delegate = nil

        inputStream?.close()
        outputStream?.close()
        
        inputStream = nil
        outputStream = nil
    }

    func writeToStream(buffer: UnsafePointer<UInt8>, maxLength length: Int) -> Int {
        return outputStream?.write(buffer, maxLength: length) ?? 0
    }
}

extension SocketConnection: StreamDelegate {

    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .openCompleted:
            print("client stream open completed")
            if aStream == outputStream {
                didOpen?()
            }
        case .hasBytesAvailable:
            if aStream == inputStream {
                var buffer: UInt8 = 0
                let numberOfBytesRead = inputStream?.read(&buffer, maxLength: 1)
                if numberOfBytesRead == 0 && aStream.streamStatus == .atEnd {
                    print("server socket closed")
                    close()
                    notifyDidClose(error: nil)
                }
            }
        case .hasSpaceAvailable:
            if aStream == outputStream {
                streamHasSpaceAvailable?()
            }
        case .errorOccurred:
            print("client stream error occured: \(String(describing: aStream.streamError))")
            close()
            notifyDidClose(error: aStream.streamError)

        default:
            break
        }
    }
}

private extension SocketConnection {
  
    func setupAddress() -> Bool {
        var addr = sockaddr_un()
        guard filePath.count < MemoryLayout.size(ofValue: addr.sun_path) else {
            print("failure: fd path is too long")
            return false
        }

        _ = withUnsafeMutablePointer(to: &addr.sun_path.0) { ptr in
            filePath.withCString {
                strncpy(ptr, $0, filePath.count)
            }
        }
        
        address = addr
        return true
    }

    func connectSocket() -> Bool {
        guard var addr = address else {
            return false
        }
        
        let status = withUnsafePointer(to: &addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                Darwin.connect(socketHandle, $0, socklen_t(MemoryLayout<sockaddr_un>.size))
            }
        }

        guard status == noErr else {
            print("failure: \(status)")
            return false
        }
        
        return true
    }

    func setupStreams() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

        CFStreamCreatePairWithSocket(kCFAllocatorDefault, socketHandle, &readStream, &writeStream)

        inputStream = readStream?.takeRetainedValue()
        inputStream?.delegate = self
        inputStream?.setProperty(kCFBooleanTrue, forKey: Stream.PropertyKey(kCFStreamPropertyShouldCloseNativeSocket as String))

        outputStream = writeStream?.takeRetainedValue()
        outputStream?.delegate = self
        outputStream?.setProperty(kCFBooleanTrue, forKey: Stream.PropertyKey(kCFStreamPropertyShouldCloseNativeSocket as String))

        scheduleStreams()
    }
  
    func scheduleStreams() {
        shouldKeepRunning = true
        
        networkQueue = DispatchQueue.global(qos: .userInitiated)
        networkQueue?.async { [weak self] in
            self?.inputStream?.schedule(in: .current, forMode: .common)
            self?.outputStream?.schedule(in: .current, forMode: .common)
            
            var isRunning = false
                        
            repeat {
                isRunning = self?.shouldKeepRunning ?? false && RunLoop.current.run(mode: .default, before: .distantFuture)
            } while (isRunning)
        }
    }
    
    func unscheduleStreams() {
        networkQueue?.sync { [weak self] in
            self?.inputStream?.remove(from: .current, forMode: .common)
            self?.outputStream?.remove(from: .current, forMode: .common)
        }
        
        shouldKeepRunning = false
    }
    
    func notifyDidClose(error: Error?) {
        if didClose != nil {
            didClose?(error)
        }
    }
}
```

#### SampleUploader.swift

This file handles video frame encoding and sending:

```swift
/*
 * Copyright @ 2021-present 8x8, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import ReplayKit

private enum Constants {
    static let bufferMaxLength = 10240
}

class SampleUploader {
    
    private static var imageContext = CIContext(options: nil)
    
    @Atomic private var isReady: Bool = false
    private var connection: SocketConnection
  
    private var dataToSend: Data?
    private var byteIndex = 0
  
    private let serialQueue: DispatchQueue
    
    init(connection: SocketConnection) {
        self.connection = connection
        self.serialQueue = DispatchQueue(label: "com.synesisit.convay.broadcast.sampleUploader")
      
        setupConnection()
    }
  
    @discardableResult func send(sample buffer: CMSampleBuffer) -> Bool {
        guard isReady == true else {
            return false
        }
        
        isReady = false

        dataToSend = prepare(sample: buffer)
        byteIndex = 0

        serialQueue.async { [weak self] in
            self?.sendDataChunk()
        }
        
        return true
    }
}

private extension SampleUploader {
    
    func setupConnection() {
        connection.didOpen = { [weak self] in
            self?.isReady = true
        }
        connection.streamHasSpaceAvailable = { [weak self] in
            self?.serialQueue.async {
                self?.isReady = !(self?.sendDataChunk() ?? true)
            }
        }
    }
    
    @discardableResult func sendDataChunk() -> Bool {
        guard let dataToSend = dataToSend else {
            return false
        }
      
        var bytesLeft = dataToSend.count - byteIndex
        var length = bytesLeft > Constants.bufferMaxLength ? Constants.bufferMaxLength : bytesLeft

        length = dataToSend[byteIndex..<(byteIndex + length)].withUnsafeBytes {
            guard let ptr = $0.bindMemory(to: UInt8.self).baseAddress else {
                return 0
            }
          
            return connection.writeToStream(buffer: ptr, maxLength: length)
        }

        if length > 0 {
            byteIndex += length
            bytesLeft -= length

            if bytesLeft == 0 {
                self.dataToSend = nil
                byteIndex = 0
            }
        } else {
            print("writeBufferToStream failure")
        }
      
        return true
    }
    
    func prepare(sample buffer: CMSampleBuffer) -> Data? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(buffer) else {
            print("image buffer not available")
            return nil
        }
        
        CVPixelBufferLockBaseAddress(imageBuffer, .readOnly)
        
        let scaleFactor = 2.0
        let width = CVPixelBufferGetWidth(imageBuffer)/Int(scaleFactor)
        let height = CVPixelBufferGetHeight(imageBuffer)/Int(scaleFactor)
        let orientation = CMGetAttachment(buffer, key: RPVideoSampleOrientationKey as CFString, attachmentModeOut: nil)?.uintValue ?? 0
                                    
        let scaleTransform = CGAffineTransform(scaleX: CGFloat(1.0/scaleFactor), y: CGFloat(1.0/scaleFactor))
        let bufferData = self.jpegData(from: imageBuffer, scale: scaleTransform)
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, .readOnly)
        
        guard let messageData = bufferData else {
            print("corrupted image buffer")
            return nil
        }
              
        let httpResponse = CFHTTPMessageCreateResponse(nil, 200, nil, kCFHTTPVersion1_1).takeRetainedValue()
        CFHTTPMessageSetHeaderFieldValue(httpResponse, "Content-Length" as CFString, String(messageData.count) as CFString)
        CFHTTPMessageSetHeaderFieldValue(httpResponse, "Buffer-Width" as CFString, String(width) as CFString)
        CFHTTPMessageSetHeaderFieldValue(httpResponse, "Buffer-Height" as CFString, String(height) as CFString)
        CFHTTPMessageSetHeaderFieldValue(httpResponse, "Buffer-Orientation" as CFString, String(orientation) as CFString)
        
        CFHTTPMessageSetBody(httpResponse, messageData as CFData)
        
        let serializedMessage = CFHTTPMessageCopySerializedMessage(httpResponse)?.takeRetainedValue() as Data?
      
        return serializedMessage
    }
    
    func jpegData(from buffer: CVPixelBuffer, scale scaleTransform: CGAffineTransform) -> Data? {
        var image = CIImage(cvPixelBuffer: buffer)
        image = image.transformed(by: scaleTransform)
        
        guard let colorSpace = image.colorSpace else {
            return nil
        }
      
        let options: [CIImageRepresentationOption: Float] = [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption: 1.0]
        let imageData = SampleUploader.imageContext.jpegRepresentation(of: image, colorSpace: colorSpace, options: options)
      
        return imageData
    }
}
```

#### SampleHandler.swift

This is the main extension handler that coordinates everything:

```swift
/*
 * Copyright @ 2021-present 8x8, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import ReplayKit

private enum Constants {
    // IMPORTANT: Replace "YOUR_APPGROUP.appgroup" with your actual App Group identifier
    // The App Group ID value that the app and the broadcast extension targets are setup with. It differs for each app.
    // Example: "group.com.yourcompany.yourapp.appgroup"
    static let appGroupIdentifier = "YOUR_APPGROUP.appgroup"
}

class SampleHandler: RPBroadcastSampleHandler {
    
    private var clientConnection: SocketConnection?
    private var uploader: SampleUploader?
    
    private var frameCount: Int = 0
    
    var socketFilePath: String {
      let sharedContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier)
        
        return sharedContainer?.appendingPathComponent("rtc_SSFD").path ?? ""
    }
    
    override init() {
      super.init()
        if let connection = SocketConnection(filePath: socketFilePath) {
          clientConnection = connection
          setupConnection()
          
          uploader = SampleUploader(connection: connection)
        }
    }

    override func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        print("broadcast started")
        
        frameCount = 0
        
        DarwinNotificationCenter.shared.postNotification(.broadcastStarted)
        openConnection()
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
        DarwinNotificationCenter.shared.postNotification(.broadcastStopped)
        clientConnection?.close()
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            // very simple mechanism for adjusting frame rate by using every third frame
            frameCount += 1
            if frameCount % 3 == 0 {
                uploader?.send(sample: sampleBuffer)
            }
        default:
            break
        }
    }
}

private extension SampleHandler {
  
    func setupConnection() {
        clientConnection?.didClose = { [weak self] error in
            print("client connection did close \(String(describing: error))")
          
            if let error = error {
                self?.finishBroadcastWithError(error)
            } else {
                // the displayed failure message is more user friendly when using NSError instead of Error
                let JMScreenSharingStopped = 10001
                let customError = NSError(domain: RPRecordingErrorDomain, code: JMScreenSharingStopped, userInfo: [NSLocalizedDescriptionKey: "Screen sharing stopped"])
                self?.finishBroadcastWithError(customError)
            }
        }
    }
    
    func openConnection() {
        let queue = DispatchQueue(label: "broadcast.connectTimer")
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now(), repeating: .milliseconds(100), leeway: .milliseconds(500))
        timer.setEventHandler { [weak self] in
            guard self?.clientConnection?.open() == true else {
                return
            }
            
            timer.cancel()
        }
        
        timer.resume()
    }
}
```

**Important Notes:**
- **REQUIRED**: You must replace `"YOUR_APPGROUP.appgroup"` in the `Constants` enum with your actual App Group identifier. This must match the App Group you configured in your Xcode project for both the main app and the Broadcast Upload Extension. Example: `"group.com.yourcompany.yourapp.appgroup"`
- Make sure all these files are added to your Broadcast Upload Extension target
- The `SampleUploader` uses the `@Atomic` property wrapper from `Atomic.swift`
- The App Group identifier must be the same in both your main app and the Broadcast Upload Extension

### Enabling Screen Sharing

Enable screen sharing in your conference options:

```swift
let options = ConvayMeetConferenceOptions.fromBuilder { (builder) in
    builder.setFeatureFlag("ios.screensharing.enabled", withBoolean: true)
    // ... other options
}
```

**Important:** Make sure `voip` is added to `UIBackgroundModes` in your app's `Info.plist` for screen sharing to work when the app is in the background.

## Debugging

### Console Logging

If you choose `Console` app for debugging, please be sure that you select:
- **Action** (tab) → **Include Info Messages**
- **Action** (tab) → **Include Debug Messages**

In the Search filter please type `ConvayMeetSDK`, press Return key and replace `ANY` with `Category`. This will show you all the real time logs related to our SDK.

### Common Issues

#### Package not found
- Ensure you're using the correct repository URL: `https://github.com/Synesis-IT-PLC/convay-meet-ios-sdk-releases.git`
- Check your internet connection
- Try cleaning the build folder (Cmd+Shift+K) and rebuilding
- In Xcode, go to **File** → **Packages** → **Reset Package Caches**

#### Framework not found
- Ensure the package is properly added to your target
- Check that "Embed & Sign" is selected in Frameworks, Libraries, and Embedded Content
- Clean build folder (Cmd+Shift+K) and rebuild
- Try resetting package caches in Xcode

#### Build errors
- Ensure you're using Xcode 12.0 or later
- Check that your deployment target is iOS 13.0 or later
- Clean build folder and derived data
- Try resetting package caches

#### Conference not joining
- Verify server URL is correct
- Check network permissions
- Ensure room name is valid
- Verify token is valid and not expired
- Check console logs for detailed error messages

#### PiPViewCoordinator methods not found
- `PiPViewCoordinator` doesn't have `configureAsStickyView()`, `show()`, or `hide()` methods
- Add the `ConvayMeetView` directly to your view hierarchy using Auto Layout
- Use `UIView.animate` for show/hide animations
- Use `enterPictureInPicture()` method for PiP functionality

## Requirements

- **iOS**: 13.0 or later
- **Xcode**: 12.0 or later
- **Swift**: 5.0 or later

## Notes

- The SDK includes a pre-bundled JavaScript bundle, so you don't need Metro bundler running
- The SDK is built in release mode by default
- All React Native dependencies are included in the SDK
- The SDK uses XCFramework format for universal binary support (iOS device + simulator)
- This is a **public repository** - no authentication required for SPM installation

## Releases

See [Releases](https://github.com/Synesis-IT-PLC/convay-meet-ios-sdk-releases/releases) for all available versions.

## License

Apache License 2.0

## Support

For issues and questions, please contact the development team or refer to the main project documentation.
