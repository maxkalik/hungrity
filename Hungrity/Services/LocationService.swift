//
//  LocationManager.swift
//  Hungrity
//
//  Created by Maksim Kalik on 10/16/21.
//

import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func didUpdateCurrentCoordinate(_ coordinate: Coordinate)
    func didFailWithError(_ error: Error)
}

class LocationService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    weak var delegate: LocationManagerDelegate?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    func start() {
        
//        let status: CLAuthorizationStatus
        
//        if #available(iOS 14, *) {
//            status = locationManager.authorizationStatus
//        } else {
//            status = CLLocationManager.authorizationStatus()
//        }

        locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()

//        if status == .authorizedAlways {
//            locationManager.startUpdatingLocation()
//        } else {
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
  
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude

            let coordinate = Coordinate(latitude: latitude, longitude: longitude)
            print(coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        delegate?.didFailWithError(error)
    }
}
