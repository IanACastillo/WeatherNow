//
//  LocationManager.swift
//  WeatherNow
//
//  Created by Ian Abraham Castillo Sanchez on 11/28/24.
//

import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private let locationSubject = PassthroughSubject<CLLocation?, Never>()

    @Published var currentLocation: CLLocation?
    @Published var locationPermissionDenied = false
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    /// Requests location permission
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Start updating location
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    /// Stop updating location
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    /// Publisher to provide location updates
    var locationPublisher: AnyPublisher<CLLocation?, Never> {
        locationSubject.eraseToAnyPublisher()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationPermissionDenied = false
            startUpdatingLocation()
        case .denied, .restricted:
            locationPermissionDenied = true
            locationSubject.send(nil)
        case .notDetermined:
            requestLocationPermission()
        @unknown default:
            locationPermissionDenied = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            locationSubject.send(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error.localizedDescription)")
        locationSubject.send(nil)
    }
}
