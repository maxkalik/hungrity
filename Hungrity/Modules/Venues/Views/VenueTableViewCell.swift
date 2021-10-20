//  Created by Maksim Kalik

import UIKit

final class VenueTableViewCell: UITableViewCell {
    
    var viewModel: VenueCellViewModel? {
        didSet {
            setupVenueImageView()
            setupFavoriteButton()
            setupTitleLabel()
            setupSubTitleLabel()
        }
    }
    
    private var imageCache = NSCache<NSString, UIImage>()

    private var venueImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private var imageViewSpinner: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    private var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .black
        return button
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return label
    }()
    
    private var subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .darkGray
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()

        venueImageView.image = nil
        favoriteButton.imageView?.image = nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCommon()
        setupImageViewSpinner()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension VenueTableViewCell {
    func setupCommon() {
        selectionStyle = .none
    }

    func setupVenueImageView() {
        imageViewSpinner.startAnimating()
        guard let imageUrl = viewModel?.imageUrl else { return }
        venueImageView.load(from: imageUrl, with: imageCache) { [weak self] data in
            if let image = data {
               self?.imageCache.setObject(image, forKey: imageUrl.absoluteString as NSString)
            }
            DispatchQueue.main.async {
                self?.imageViewSpinner.stopAnimating()
            }
        }
        contentView.addSubview(venueImageView)
        setupVenueImageViewConstrains()
    }
    
    func setupImageViewSpinner() {
        venueImageView.addSubview(imageViewSpinner)
        setupImageViewSpinnerConstrains()
    }
    
    func setupFavoriteButton() {
        updateFavoriteButtonIcon()
        favoriteButton.addTarget(self, action: #selector(favoriteButtonPressed), for: .touchUpInside)
        contentView.addSubview(favoriteButton)
        setupFavoriteButtonConstrains()
    }
    
    func setupTitleLabel() {
        titleLabel.text = viewModel?.title
        contentView.addSubview(titleLabel)
        setupTitleLabelConstrains()
    }
    
    func setupSubTitleLabel() {
        subTitleLabel.text = viewModel?.subTitle
        contentView.addSubview(subTitleLabel)
        setupSubTitleLabelConstrains()
    }
}

// MARK: - Interactions

private extension VenueTableViewCell {
    @objc func favoriteButtonPressed() {
        viewModel?.favoriteDidPress()
        updateFavoriteButtonIcon()
    }
    
    func updateFavoriteButtonIcon() {
        guard let imageName = viewModel?.favoriteButtonImageName else { return }
        let image = UIImage(icon: imageName)
        favoriteButton.setImage(image, for: .normal)
    }
}

// MARK: - Constrains

private extension VenueTableViewCell {

    func setupVenueImageViewConstrains() {
        venueImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            venueImageView.widthAnchor.constraint(equalToConstant: 48),
            venueImageView.heightAnchor.constraint(equalToConstant: 48),
            venueImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            venueImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
    }
    
    func setupImageViewSpinnerConstrains() {
        imageViewSpinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageViewSpinner.centerXAnchor.constraint(equalTo: venueImageView.centerXAnchor),
            imageViewSpinner.centerYAnchor.constraint(equalTo: venueImageView.centerYAnchor)
        ])
    }
    
    func setupFavoriteButtonConstrains() {
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            favoriteButton.widthAnchor.constraint(equalToConstant: 24),
            favoriteButton.heightAnchor.constraint(equalToConstant: 24),
            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -17)
        ])
    }

    func setupTitleLabelConstrains() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: venueImageView.trailingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -10),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    func setupSubTitleLabelConstrains() {
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: venueImageView.trailingAnchor, constant: 15),
            subTitleLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -10),
            subTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            subTitleLabel.heightAnchor.constraint(equalToConstant: 18),
        ])
    }
}
