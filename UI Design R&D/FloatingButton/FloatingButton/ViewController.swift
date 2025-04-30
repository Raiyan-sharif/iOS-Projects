//
//  ViewController.swift
//  FloatingButton
//
//  Created by Synesis Sqa on 29/4/25.
//

import UIKit

class ViewController: UIViewController {
    
    private let floatingButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        
        button.backgroundColor = .systemPink
        
        let image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        
        // Corner Radius
//        button.layer.masksToBounds = true
        button.layer.cornerRadius = 30
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.addSubview(floatingButton)
        
        floatingButton.addTarget(self, action: #selector(didTapFloatingButton), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        floatingButton.frame = CGRect(x: view.frame.size.width/2 - 30, y: view.frame.size.height - 60 - 8 - view.safeAreaInsets.bottom, width: 60, height: 60)
    }
    
    @objc func didTapFloatingButton() {
        let alert = UIAlertController(title: "Add Something", message: "Floating Button Tapped", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dissmiss", style: .cancel, handler: nil))
        present(alert, animated: true)
        
    }


}

