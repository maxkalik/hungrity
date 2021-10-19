//
//  LocationManager.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/16/21.
//

import CoreLocation

protocol LocationServiceCoordinatorDelegate: AnyObject {
    func locationAuthStatusDidChange(_ isValidStatus: Bool)
}

protocol LocationServiceDelegate: AnyObject {
    func locationDidUpdateCurrentCoordinate(_ coordinate: Coordinate)
    func locationDidFailWithError(_ error: Error)
}

protocol LocationServiceProtocol: CLLocationManagerDelegate {
    var delegate: LocationServiceDelegate? { get set }
    var coordinatorDelegate: LocationServiceCoordinatorDelegate? { get set }

    func getLocation()
}

class LocationService: NSObject, LocationServiceProtocol {

    private let locationManager = CLLocationManager()

    weak var delegate: LocationServiceDelegate?
    weak var coordinatorDelegate: LocationServiceCoordinatorDelegate?
    
    var currentCoordinate: Coordinate? {
        didSet {
            guard let coordinate = currentCoordinate else { return }
            delegate?.locationDidUpdateCurrentCoordinate(coordinate)
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }

    func getLocation() {
        if currentCoordinate != nil {
            currentCoordinate = nil
        }
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
  
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude

            if currentCoordinate == nil {
                print("LOCATION SERVICE - Location Has Been Updated")
                currentCoordinate = Coordinate(latitude: latitude, longitude: longitude)
            } else {
                print("LOCATION SERVICE - Stoped Updating Location")
                locationManager.stopUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        delegate?.locationDidFailWithError(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let isValidStatus = status == .authorizedAlways || status == .authorizedWhenInUse
        self.coordinatorDelegate?.locationAuthStatusDidChange(isValidStatus)

        if isValidStatus == true {
            getLocation()
        }
    }
}
