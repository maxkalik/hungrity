//  Created by Maksim Kalik

import UIKit


extension UIImageView {
    
    typealias ImageLoadComplition = (_ data: UIImage?) -> Void
    
    func load(from url: URL, with cache: NSCache<NSString, UIImage>? = nil, complition: ImageLoadComplition? = nil) {
        if let chachedImage = cache?.object(forKey: url.absoluteString as NSString) {
            complition?(nil)
            DispatchQueue.main.async {
                self.image = chachedImage
            }
        } else {
            fetchImage(from: url, complition: complition)
        }
    }
    
    private func fetchImage(from url: URL, complition: ImageLoadComplition? = nil) {
        
        var activityIndicator = UIActivityIndicatorView(style: .medium)
        setup(&activityIndicator)
        activityIndicator.startAnimating()
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                complition?(image)
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    activityIndicator.removeFromSuperview()
                    self?.image = image
                }
            }
        }
    }
    
    private func setup(_ view: inout UIActivityIndicatorView) {
        view.hidesWhenStopped = true
        addSubview(view)
        setupConstrains(&view)
    }
    
    private func setupConstrains(_ view: inout UIActivityIndicatorView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
}
