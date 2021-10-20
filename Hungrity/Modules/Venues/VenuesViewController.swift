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
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = .systemBackground.withAlphaComponent(0.8)
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
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
    
    private var favoritesBarButtonItem = UIBarButtonItem()
    
    private var venuesTableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
        return tableView
    }()
    
    private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCommon()
        setupVenuesTableView()
        setupTitleLabel()
        setupLeftBarActivityIndicatorItem()
        setupRightBarButtonItem()
        viewModel?.viewDidLoad()
    }
}

// MARK: - Setup

private extension VenuesViewController {
    func setupCommon() {

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
    
    private func setupLeftBarActivityIndicatorItem() {
        let leftBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }
    
    func setupVenuesTableView() {
        venuesTableView.dataSource = self
        venuesTableView.refreshControl = refreshControl
        view.addSubview(venuesTableView)
        setupVenuesTableViewConstrains()
        registerCell()
    }
    
    func setupCenteredMessageLabel() {
        let isDescendant = centeredMessageLabel.isDescendant(of: view)
        if isDescendant == false {
            venuesTableView.addSubview(centeredMessageLabel)
            setupCenteredMessageLabelConstrains()
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
        let image = UIImage(icon: imageName)
        favoritesBarButtonItem.image = image
    }
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
        ) as? VenueTableViewCell, let viewModel = viewModel?.venues[indexPath.row] {
            cell.viewModel = viewModel
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
        hideSpinners()
        hideCenteredMessage()
        venuesTableView.reloadData()
    }
    
    func showCenteredMessage(_ msg: String) {
        centeredMessageLabel.text = msg
        setupCenteredMessageLabel()
    }
    
    private func hideSpinners() {
        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    private func hideCenteredMessage() {
        if viewModel?.venues.isEmpty == false && centeredMessageLabel.isDescendant(of: view) == true {
            centeredMessageLabel.removeFromSuperview()
        }
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

    func setupCenteredMessageLabelConstrains() {
        centeredMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centeredMessageLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
            centeredMessageLabel.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
}
