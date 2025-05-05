//
//  ViewController.swift
//  GitImage
//
//  Created by Synesis Sqa on 5/5/25.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        let callingGif = UIImage.gifImageWithName("calling_gif")
        imageView.image = callingGif
    }


}

