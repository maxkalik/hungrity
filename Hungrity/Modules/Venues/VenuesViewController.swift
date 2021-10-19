//
//  ViewController.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/16/21.
//

import UIKit

final class VenuesViewController: UIViewController {

    var viewModel: VenuesViewModel?
    
    private var venuesTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.layer.borderColor = UIColor.red.cgColor
        tableView.layer.borderWidth = 2
        
        return tableView
    }()
    
    private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewDidLoad()

        setupVenuesTableView()
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        viewModel?.startRefreshing()
        sender.endRefreshing()
    }
}

// MARK: - Setup

private extension VenuesViewController {
    func setupVenuesTableView() {
        venuesTableView.delegate = self
        venuesTableView.dataSource = self
        venuesTableView.refreshControl = refreshControl
        view.addSubview(venuesTableView)
        setupVenuesTableViewConstrains()
    }
}

extension VenuesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
}

extension VenuesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.venuesCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = UITableViewCell()
//        cell.contentView
    }
}

// MARK: - Constrains

private extension VenuesViewController {
    func setupVenuesTableViewConstrains() {
        venuesTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            venuesTableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            venuesTableView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
}
