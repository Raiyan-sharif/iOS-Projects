//
//  AppCoordinator.swift
//  UIkitCoordinatorPattern
//

import UIKit

import UIKit

protocol Coordinator: AnyObject {
    func start()
}

class AppCoordinator: Coordinator {
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let homeVC = HomeViewController()
        homeVC.coordinator = self
        navigationController.pushViewController(homeVC, animated: false)
    }
    
    func showDetailScreen() {
        let detailVC = DetailViewController()
        detailVC.coordinator = self
        navigationController.pushViewController(detailVC, animated: true)
    }
}

