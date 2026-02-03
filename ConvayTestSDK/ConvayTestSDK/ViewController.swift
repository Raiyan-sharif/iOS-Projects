//
//  ViewController.swift
//  ConvayTestSDK
//
//  Created by Raiyan Sharif on 4/1/26.
//

import UIKit
import JitsiMeetSDK

class ViewController: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let jitsiMeetViewController = JitsiMeetView()
        
//        present(jitsiMeetViewController, animated: true)
        // Do any additional setup after loading the view.
    }


    @IBAction func startMeetingTapped(_ sender: UIButton) {
            
    }
    
    @IBAction func joinMeetingTapped(_ sender: UIButton) {
        let vc = MeetingViewController()
        present(vc, animated: true)
    }
    
    
}

