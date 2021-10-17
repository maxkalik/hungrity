//
//  ViewController.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/16/21.
//

import UIKit

class VenuesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel = VenuesViewModel()
        viewModel.viewDidLoad()
    }
}

