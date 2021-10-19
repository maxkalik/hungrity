//
//  MainCoordinator.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/18/21.
//

import Foundation
import UIKit

protocol AppCoordinator: Coordinator {
    
}

final class AppCoordinatorImplementation: AppCoordinator {
    private(set) var navigationController: UINavigationController
    private var dependencies = AppDependencies()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = VenuesViewController()
        viewController.viewModel = VenuesViewModelImplementation(dependencies: dependencies)
        navigationController.pushViewController(viewController, animated: true)
    }
}
