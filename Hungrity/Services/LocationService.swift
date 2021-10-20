//  Created by Maksim Kalik

import UIKit

protocol LocationServiceDelegate: AnyObject {
    func locationDidUpdateCurrentCoordinate(_ coordinate: Coordinate)
}

protocol LocationServiceProtocol {
    var delegate: LocationServiceDelegate? { get set }
    
    func startGettingLocation()
    func getCurrentLocation()
}

class LocationService: LocationServiceProtocol {

    weak var delegate: LocationServiceDelegate?
    
    private var timer: Timer?
    private var requestCounter = 0
    private var currentDate: Date?
    
    init() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self, selector: #selector(appMovedToBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        notificationCenter.addObserver(
            self, selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func startGettingLocation() {
        guard timer == nil else { return }
        self.timer = Timer.scheduledTimer(
            timeInterval: Configuration.refreshDeadlineSeconds,
            target: self,
            selector: #selector(setCounter),
            userInfo: nil,
            repeats: true
        )
    }
 
    func getCurrentLocation() {
        let coordinates = Constants.coordinates
        let coordinate = coordinates[requestCounter]
        print("=== Get location number: \(requestCounter). Latitude: \(coordinate.lat), Longitude: \(coordinate.lon)")
        delegate?.locationDidUpdateCurrentCoordinate(Coordinate(latitude: coordinate.lat, longitude: coordinate.lon))
    }
}

private extension LocationService {
    @objc func appMovedToBackground() {
        print("=== App Moved to background")
        currentDate = Date()
    }
    
    @objc func appWillEnterForeground() {
        updateCounter()
        print("=== App Will Enter Foregroundd with updated request counter: \(requestCounter)")
    }

    @objc func setCounter() {
        let coordinates = Constants.coordinates
        requestCounter = requestCounter < coordinates.count - 1 ? requestCounter + 1 : 0
        getCurrentLocation()
    }
    
    private func updateCounter() {
        requestCounter = calculateRequests()
    }
    
    private func calculateRequests() -> Int {
        let backgroundSec = abs(Int(currentDate?.timeIntervalSince(Date()) ?? 0) % 60)
        
        let coordinatesCount = Constants.coordinates.count
        let backgroundRequests: Int = (backgroundSec / coordinatesCount) % coordinatesCount

        if (backgroundRequests + requestCounter) > coordinatesCount - 1 {
            return abs(backgroundRequests - requestCounter)
        } else {
            return backgroundRequests + requestCounter
        }
    }
}
