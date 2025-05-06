//
//  HomeViewController.swift
//  UIkitCoordinatorPattern
//

import UIKit


protocol HomeViewControllerDelegate: AnyObject {
    func homeViewControllerDidTapGoToDetail(_ controller: HomeViewController)
}

class HomeViewController: UIViewController {
    weak var coordinator: AppCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Home"
        
        // Create button
        let button = UIButton(type: .system)
        button.setTitle("Go to Detail", for: .normal)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        
        // Center button
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func didTapButton() {
        coordinator?.showDetailScreen()
    }
}

