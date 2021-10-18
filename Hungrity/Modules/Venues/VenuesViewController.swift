//
//  ViewController.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/16/21.
//

import UIKit

class VenuesViewController: UIViewController {

    private var locationManager = LocationService()
    var viewModel: VenuesViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        viewModel?.viewDidLoad()
    }
}
