//
//  MeetingViewController.swift
//  TestProjectForSDK
//
//  Created by Raiyan Sharif on 7/1/26.
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
            builder.serverURL = URL(string: "https://convay.com/")
            builder.room = "https://synesis.convay.com/0000019b-9753-6d00-0000-00000001e399?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJzeW5lc2lzLmNvbnZheS5jb20iLCJpYXQiOjE3Njc3NzAzODYsImV4cCI6MTc2NzgxMzU4NiwiaXNzIjoiQTgxRkYiLCJuYmYiOjE3Njc3NzAzODYsIm1hdHJpeEFjY2Vzc1Rva2VuIjoic3l0X2MzVnphRzl0WVdGMFlYQndaR1YyTG1OdmJRX25pYktjRnVkZ0pReFFlU3lsU3BJXzJDZmZ4TCIsInJvb20iOiIwMDAwMDE5Yi05NzUzLTZkMDAtMDAwMC0wMDAwMDAwMWUzOTkiLCJjb250ZXh0Ijp7ImZlYXR1cmVzIjp7ImRlc2t0b3BhcHAiOiJ0cnVlIiwibGl2ZXN0cmVhbWluZyI6InRydWUiLCJ0cmFuc2NyaXB0aW9uIjoidHJ1ZSIsImNoYXQiOiJ0cnVlIiwicmVjb3JkaW5nIjoidHJ1ZSJ9LCJjb25maWciOnsiTUlDX09GRiI6dHJ1ZSwiQ0FNRVJBX09GRiI6dHJ1ZSwiSVNfSE9TVCI6dHJ1ZSwiTUFYX1BBUlRJQ0lQQU5UIjoxMjAwLCJNRUVUSU5HX0RVUkFUSU9OIjo4MCwiV0FJVElOR19ST09NIjpmYWxzZSwiQUxMX1BDUl9KT0lOIjp0cnVlLCJIT1NUX1JFQ09SRF9TVEFSVFVQIjpmYWxzZSwiRElTX0NIQVQiOmZhbHNlLCJMT0NLX01JTiI6eyJzbGVjdGVkIjpmYWxzZX0sIkFMTF9QQ1JfVU5NVVRFIjpmYWxzZSwiSE9TVF9TQ1JfU0hSIjpmYWxzZSwiQUxMT1dfUkVOQU1FIjp0cnVlLCJFTlRSWV9MRUFWRV9TT1VORCI6ZmFsc2UsIlBBUlRJQ0lQQU5UX0xPRyI6ZmFsc2UsIkRJU19SQ1ROX1dCTlIiOnRydWUsIkRJU19DSEFUX1dCTlIiOnRydWUsIlBNSSI6dHJ1ZSwiQVVUT19HRU5fSUQiOmZhbHNlLCJQQVNTV09SRCI6ZmFsc2UsIkFVVEhfVVNFUiI6ZmFsc2UsIkRPTUFJTl9BTExPVyI6ZmFsc2UsIkFMTE9XX0NPVU5UUlkiOmZhbHNlLCJJTlZJVEVfVVJMIjoiaHR0cHM6Ly9jb252YXkuY29tL20vai8zNTk5Nzc2OTIxMzYvc3VzaG9tYSIsIk1FRVRJTkdfUk9MRSI6Imhvc3QiLCJTRUNSRVQiOiI3Nzc3NzciLCJBVVRPX0NMT1NFIjpmYWxzZSwiTUVFVElOR19JRCI6IjM1OTk3NzY5MjEzNiIsIlVOSVFVRV9UUkFDS0lOR19JRCI6IjQzMjU4NzQyMzY1OCIsIlBNSV9OTyI6IjM1OTk3NzY5MjEzNiIsIk1FRVRJTkdfU1RBUlQiOjE3Njc3NzAzODQwMDh9LCJ1c2VyIjp7ImJhY2tncm91bmRVcmwiOiIiLCJwYXJ0aWNpcGFudExvZ0lkIjoiZDg4ZjFiYzUtNmY5ZC00NmVmLWFmYTEtNGMxM2JjN2I4YzJlIiwiYXZhdGFyIjoiaHR0cHM6Ly9jb252YXkuY29tL3NlcnZpY2VzL2ZpbGUtc2VydmljZS9maWxlL2Rvd25sb2FkRmlsZS9iMjhkNmY1NC00N2ZhLTQyOGItOGMxNC00N2MyMGMwYmM1M2QucG5nIiwidmlkZW9EZXZpY2UiOiIiLCJyb29tTmFtZSI6IjAwMDAwMTliLTk3NTMtNmQwMC0wMDAwLTAwMDAwMDAxZTM5OSIsIm1pY3JvcGhvbmVEZXZpY2UiOiIiLCJuYW1lIjoiVGFtYW5uYSBTdXNob21hIiwiaWQiOiJiZTg1Yzk2OS1jZTY5LTExZWQtOWE0Yy0wMjQyYWMxMzAwMDgiLCJjYXRlZ29yeSI6Imhvc3QiLCJsYW5nIjoiZW5nbGlzaCIsImVtYWlsIjoic3VzaG9tYUBhcHBkZXYuY29tIiwiYmFja2dyb3VuZElkIjoiIiwic3BlYWtlckRldmljZSI6IiJ9fSwiYXVkIjoiaml0c2kifQ.XcwwgPCJuH2ZiPHYhWv43ovyfjlar38P77s8LqZQrmI"
            builder.setAudioOnly(true)
        }

        jitsiMeetView.join(options)
    }

    // MARK: - Delegate Methods

    func conferenceTerminated(_ data: [AnyHashable : Any]!) {
        dismiss(animated: true)
    }
}
