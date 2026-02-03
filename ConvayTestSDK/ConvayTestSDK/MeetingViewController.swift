//
//  MeetingViewController.swift
//  ConvayTestSDK
//
//  Created by Raiyan Sharif on 6/1/26.
//

import UIKit
import JitsiMeetSDK

class MeetingViewController: UIViewController, JitsiMeetViewDelegate {

    private var jitsiMeetView: JitsiMeetView!

    override func loadView() {
        jitsiMeetView = JitsiMeetView()
        jitsiMeetView.delegate = self
        view = jitsiMeetView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let options = JitsiMeetConferenceOptions.fromBuilder { builder in
            builder.serverURL = URL(string: "https://convay.com")
            builder.room = "https://synesis.convay.com/0000019b-97c4-8957-0000-00000001c8c3?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJzeW5lc2lzLmNvbnZheS5jb20iLCJpYXQiOjE3Njc3Nzc3OTgsImV4cCI6MTc2NzgyMDk5OCwiaXNzIjoiQTgxRkYiLCJuYmYiOjE3Njc3Nzc3OTgsInJvb20iOiIwMDAwMDE5Yi05N2M0LTg5NTctMDAwMC0wMDAwMDAwMWM4YzMiLCJjb250ZXh0Ijp7ImZlYXR1cmVzIjp7ImRlc2t0b3BhcHAiOiJ0cnVlIiwibGl2ZXN0cmVhbWluZyI6InRydWUiLCJ0cmFuc2NyaXB0aW9uIjoidHJ1ZSIsImNoYXQiOiJ0cnVlIiwicmVjb3JkaW5nIjoidHJ1ZSJ9LCJjb25maWciOnsiTUlDX09GRiI6dHJ1ZSwiQ0FNRVJBX09GRiI6dHJ1ZSwiSVNfSE9TVCI6dHJ1ZSwiTUFYX1BBUlRJQ0lQQU5UIjoxMjAwLCJNRUVUSU5HX0RVUkFUSU9OIjo4MCwiV0FJVElOR19ST09NIjpmYWxzZSwiQUxMX1BDUl9KT0lOIjpmYWxzZSwiSE9TVF9SRUNPUkRfU1RBUlRVUCI6ZmFsc2UsIkRJU19DSEFUIjpmYWxzZSwiTE9DS19NSU4iOnsic2xlY3RlZCI6ZmFsc2V9LCJBTExfUENSX1VOTVVURSI6dHJ1ZSwiSE9TVF9TQ1JfU0hSIjpmYWxzZSwiQUxMT1dfUkVOQU1FIjp0cnVlLCJFTlRSWV9MRUFWRV9TT1VORCI6dHJ1ZSwiUEFSVElDSVBBTlRfTE9HIjp0cnVlLCJESVNfUkNUTl9XQk5SIjp0cnVlLCJESVNfQ0hBVF9XQk5SIjp0cnVlLCJQTUkiOnRydWUsIkFVVE9fR0VOX0lEIjpmYWxzZSwiUEFTU1dPUkQiOnRydWUsIkFVVEhfVVNFUiI6ZmFsc2UsIkRPTUFJTl9BTExPVyI6ZmFsc2UsIkFMTE9XX0NPVU5UUlkiOmZhbHNlLCJJTlZJVEVfVVJMIjoiaHR0cHM6Ly9jb252YXkuY29tL20vai85MTIzOTk0NTQwMzgvcmFpeWFuP3B3ZD05MWQ0Mjc5YWM1M2RkZmQ5YjdlNjJiNzQ0MjQ3ZTBhZCIsIk1FRVRJTkdfUk9MRSI6Imhvc3QiLCJTRUNSRVQiOiI2MzQ5NTkiLCJBVVRPX0NMT1NFIjpmYWxzZSwiTUVFVElOR19JRCI6IjkxMjM5OTQ1NDAzOCIsIlVOSVFVRV9UUkFDS0lOR19JRCI6IjkzNTA3MzAzODcxMiIsIlBNSV9OTyI6IjkxMjM5OTQ1NDAzOCIsIk1FRVRJTkdfU1RBUlQiOjE3Njc3Nzc3OTYwMDZ9LCJ1c2VyIjp7ImJhY2tncm91bmRVcmwiOiIiLCJwYXJ0aWNpcGFudExvZ0lkIjoiZTgyMjVmOGUtN2QyZC00MWYzLWJmY2ItOTk2Yzk5NjEyNDg5IiwiYXZhdGFyIjoiaHR0cHM6Ly9jb252YXkuY29tL3NlcnZpY2VzL2ZpbGUtc2VydmljZS9maWxlLyIsInZpZGVvRGV2aWNlIjoiIiwicm9vbU5hbWUiOiIwMDAwMDE5Yi05N2M0LTg5NTctMDAwMC0wMDAwMDAwMWM4YzMiLCJtaWNyb3Bob25lRGV2aWNlIjoiIiwibmFtZSI6IlJhaXlhbiBTaGFyaWYiLCJpZCI6IjdjMGU1NWE5LWM0ZTYtNDk2Yi1hNWJhLTIzYjlmNjgxYjZiMSIsImNhdGVnb3J5IjoiaG9zdCIsImxhbmciOiJlbiIsImVtYWlsIjoicmFpeWFuLnNoYXJpZkBzeW5lc2lzaXQuaW5mbyIsImJhY2tncm91bmRJZCI6IiIsInNwZWFrZXJEZXZpY2UiOiIifX0sImF1ZCI6ImppdHNpIn0.OBsUqHK3asqB_yhoc3YdbY4PX656Wu6TE4VbezLBwRI"
            builder.setAudioOnly(true)
        }

        jitsiMeetView.join(options)
    }

    // MARK: - Delegate Methods

    func conferenceTerminated(_ data: [AnyHashable : Any]!) {
        dismiss(animated: true)
    }
}

