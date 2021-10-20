//  Created by Maksim Kalik

import Foundation
import UIKit

protocol AppCoordinator: Coordinator {
    
}

final class AppCoordinatorImplementation: AppCoordinator {
    
    private var alert: UIAlertController?
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
