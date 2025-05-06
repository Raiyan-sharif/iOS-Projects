//
//  DeatailViewController.swift
//  UIkitCoordinatorPattern
//

import UIKit

class DetailViewController: UIViewController {
    weak var coordinator: AppCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Detail"
        
        // Create label
        let label = UILabel()
        label.text = "Detail Screen"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        // Create back button
        let button = UIButton(type: .system)
        button.setTitle("Go Back", for: .normal)
        button.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20)
        ])
    }
    
    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
}

