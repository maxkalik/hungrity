//
//  ViewController.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/16/21.
//

import UIKit

final class VenuesViewController: UIViewController {

    var viewModel: VenuesViewModel? {
        didSet {
            viewModel?.viewDelegate = self
        }
    }

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 22)
        label.textColor = .gray
        label.sizeToFit()
        return label
    }()
    
    private var venuesTableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 60
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

        setupCommon()
        setupVenuesTableView()
        setupTitleLabel()
    }
    
    @objc private func refresh(sender: UIRefreshControl) {
        viewModel?.startRefreshing()
        sender.endRefreshing()
    }
}

// MARK: - Setup

private extension VenuesViewController {
    func setupCommon() {
        // navigationController?.title = "Hungrity"
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Hungrity"
        navigationItem.titleView = titleLabel
    }
    
    func setupVenuesTableView() {
        venuesTableView.delegate = self
        venuesTableView.dataSource = self
        venuesTableView.refreshControl = refreshControl
        view.addSubview(venuesTableView)
        setupVenuesTableViewConstrains()
        registerCell()
    }
    
    func registerCell() {
        venuesTableView.register(
            VenueTableViewCell.self,
            forCellReuseIdentifier: Constants.venueCellIdentifier
        )
    }
}

// MARK: - UITableViewDelegate

extension VenuesViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.row)
//    }
}

// MARK: - UITableViewDataSource

extension VenuesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.venuesCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.venueCellIdentifier,
            for: indexPath
        ) as? VenueTableViewCell {
            cell.viewModel = viewModel?.venues[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
}

// MARK: - VenuesViewModelViewDelegate

extension VenuesViewController: VenuesViewModelViewDelegate {
    func startLoading() {
        print("=== start loading")
    }
    
    func finishLoading() {
        print("=== finish loading")
        venuesTableView.reloadData()
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
