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
        dependencies.locationService.coordinatorDelegate = self
    }
    
    func start() {
        let viewController = VenuesViewController()
        viewController.viewModel = VenuesViewModelImplementation(dependencies: dependencies)
        navigationController.pushViewController(viewController, animated: true)
    }
}

// MARK: - Alert

extension AppCoordinatorImplementation {
    
    // MARK: Show Alert
    func showAlert(_ alertModel: AlertModel, completion: (() -> Void)? = nil) {
        self.alert = UIAlertController(title: alertModel.title, message: alertModel.message, preferredStyle: .alert)
        if alertModel.okButtonTitle != nil {
            alert?.addAction(
                UIAlertAction(
                    title: alertModel.okButtonTitle,
                    style: .default,
                    handler: alertModel.okHandler
                )
            )
        }
        if alertModel.cancelHandler != nil {
            alert?.addAction(
                UIAlertAction(
                    title: alertModel.cancelButtonTitle,
                    style: .cancel,
                    handler: alertModel.cancelHandler
                )
            )
        }

        guard let alert = self.alert else { return }
        navigationController.present(alert, animated: true, completion: completion)
    }
    
    // MARK: Dismiss Alert
    func dismissAlert(completion: (() -> Void)? = nil) {
        self.alert?.dismiss(animated: true, completion: completion)
    }
}

// MARK: - LocationManagerCoordinatorDelegate

extension AppCoordinatorImplementation: LocationServiceCoordinatorDelegate {
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    func showLocationAlert() {
        let alert = AlertModel(
            title: "Cannot get your location",
            message: "This application needs to know your current location",
            okButtonTitle: "Dismiss",
            okHandler: { [weak self] _ in
                self?.dismissAlert(completion: nil)
            },
            cancelButtonTitle: "Settings",
            cancelHandler: { [weak self] _ in
                self?.openSettings()
            }
        )
        showAlert(alert)
    }

    func locationAuthStatusDidChange(_ isValidStatus: Bool) {
        if isValidStatus == false {
            showLocationAlert()
        } else {
            dismissAlert()
        }
    }
}
