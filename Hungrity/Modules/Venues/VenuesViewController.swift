//  Created by Maksim Kalik

import UIKit

final class VenuesViewController: UIViewController {

    var viewModel: VenuesViewModel? {
        didSet {
            viewModel?.viewDelegate = self
        }
    }
    
    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .medium
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    private var centeredMessageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = .gray
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 22)
        label.textColor = .gray
        label.sizeToFit()
        return label
    }()
    
    private var favoritesBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem()
        return barButtonItem
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
        setupActivityIndicator()
        setupTitleLabel()
        setupRightBarButtonItem()
    }
}

// MARK: - Setup

private extension VenuesViewController {
    func setupCommon() {
        // navigationController?.title = "Hungrity"
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        setupActivityIndicatorConstrains()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = viewModel?.title
        navigationItem.titleView = titleLabel
    }
    
    private func setupRightBarButtonItem() {
        navigationItem.rightBarButtonItem = favoritesBarButtonItem
        favoritesBarButtonItem.target = self
        favoritesBarButtonItem.action = #selector(favoritesBarButtonItemPressed)
        updateFavoritesBarButtonItem()
    }
    
    func setupVenuesTableView() {
        venuesTableView.delegate = self
        venuesTableView.dataSource = self
        venuesTableView.refreshControl = refreshControl
        view.addSubview(venuesTableView)
        setupVenuesTableViewConstrains()
        registerCell()
    }
    
    func setupCenteredMessageLabel() {
        let isDescendant = centeredMessageLabel.isDescendant(of: view) == true
        if let venuesCount = viewModel?.venuesCount,
           venuesCount > 0 {
            if isDescendant == true {
                centeredMessageLabel.removeFromSuperview()
            }
        } else {
            if isDescendant == false {
                venuesTableView.addSubview(centeredMessageLabel)
                setupCenteredMessageLabelConstrains()
            }
        }
    }
    
    func registerCell() {
        venuesTableView.register(
            VenueTableViewCell.self,
            forCellReuseIdentifier: Constants.venueCellIdentifier
        )
    }
}

// MARK: - Interactions

private extension VenuesViewController {
    
    @objc func refresh() {
        viewModel?.startRefreshing()
    }
    
    @objc func favoritesBarButtonItemPressed() {
        viewModel?.favoritesDidPress()
        updateFavoritesBarButtonItem()
        venuesTableView.reloadData()
    }
    
    func updateFavoritesBarButtonItem() {
        guard let imageName = viewModel?.favoritesButtonImageName else { return }
        let image = UIImage(named: imageName)
        favoritesBarButtonItem.image = image
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
        if !refreshControl.isRefreshing {
            activityIndicator.startAnimating()
        }
    }
    
    func finishLoading() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        } else {
            activityIndicator.stopAnimating()
        }
        venuesTableView.reloadData()
    }
    
    func showErrorMessage(_ msg: String) {
        centeredMessageLabel.text = msg
        setupCenteredMessageLabel()
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
    
    func setupActivityIndicatorConstrains() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let top = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo: view.topAnchor, constant: top + 10),
            activityIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    func setupCenteredMessageLabelConstrains() {
        centeredMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centeredMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centeredMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
