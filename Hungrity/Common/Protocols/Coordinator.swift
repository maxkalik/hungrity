//
//  Coordinator.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/18/21.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}
