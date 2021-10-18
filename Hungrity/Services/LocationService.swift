//
//  LocationManager.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/16/21.
//

import CoreLocation

protocol LocationServiceDelegate: AnyObject {
    func didUpdateCurrentCoordinate(_ coordinate: Coordinate)
    func didFailWithError(_ error: Error)
}

protocol LocationServiceProtocol: CLLocationManagerDelegate {
    var delegate: LocationServiceDelegate? { get set }

    func start()
}

class LocationService: NSObject, LocationServiceProtocol {

    private let locationManager = CLLocationManager()

    weak var delegate: LocationServiceDelegate?
    
    var currentCoordinate: Coordinate? {
        didSet {
            guard let coordinate = currentCoordinate else { return }
            delegate?.didUpdateCurrentCoordinate(coordinate)
        }
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    @objc private func getLocation() {
        startWhileUsingApp()
    }

    func start() {
        startWhileUsingApp()
    }
    
    func startWhileUsingApp() {
        if currentCoordinate != nil {
            currentCoordinate = nil
        }
        locationManager.startUpdatingLocation()
    }
    
    func startAlways() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
  
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude

            if currentCoordinate == nil {
                currentCoordinate = Coordinate(latitude: latitude, longitude: longitude)
            } else {
                locationManager.stopUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        delegate?.didFailWithError(error)
    }

    func validateLocationAuthorizationStatus() {
        
        let status: CLAuthorizationStatus
        
        if #available(iOS 14, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .notDetermined, .denied, .restricted:
            print("=== location not authorized")
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse:
            print("=== location authorized only while using app")
            return
        case .authorizedAlways:
            print("=== location authorized always")
            return
        default:
            break
        }
    }
}
