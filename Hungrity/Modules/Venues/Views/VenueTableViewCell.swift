//
//  VenueTableViewCell.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/19/21.
//

import UIKit

final class VenueTableViewCell: UITableViewCell {
    
    var viewModel: VenueCellViewModel?
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private var subTitleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private var venueImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private var favoriteButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCommon()
        setupTitleLabel()
        setupSubTitleLabel()
        setupVenueImageView()
        setupFavoriteButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension VenueTableViewCell {
    func setupCommon() {
        
    }
    
    func setupTitleLabel() {
        addSubview(titleLabel)
        setupTitleLabelConstrains()
    }
    
    func setupSubTitleLabel() {
        addSubview(subTitleLabel)
        setupSubTitleLabelConstrains()
    }
    
    func setupVenueImageView() {
        addSubview(venueImageView)
        setupVenueImageViewConstrains()
    }
    
    func setupFavoriteButton() {
        addSubview(favoriteButton)
        setupFavoriteButtonConstrains()
    }
}

// MARK: - Interactions

private extension VenueTableViewCell {
    
}

// MARK: - Constrains

private extension VenueTableViewCell {

    func setupTitleLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // venuesTableView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    func setupSubTitleLabelConstrains() {
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // venuesTableView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    func setupVenueImageViewConstrains() {
        venueImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // venuesTableView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    func setupFavoriteButtonConstrains() {
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            // venuesTableView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
}
