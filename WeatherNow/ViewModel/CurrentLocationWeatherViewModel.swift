//
//  CurrentLocationWeatherViewModel.swift
//  WeatherNow
//
//  Created by Ian Abraham Castillo Sanchez on 11/28/24.
//

import Foundation
import Combine
import CoreLocation
import UIKit

class CurrentLocationWeatherViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var cancellables = Set<AnyCancellable>()
    private let weatherCache = NSCache<NSString, WeatherResponse>() // Cache for weather data
    private let iconCache = NSCache<NSString, UIImage>() // Cache for weather icons
    private let locationManager = CLLocationManager()

    @Published var weatherResponse: WeatherResponse?
    @Published var weatherIcon: UIImage?
    @Published var errorMessage: String?
    @Published var locationPermissionDenied: Bool = false
    private var currentLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    /// Computed property to access the city name
    var cityName: String {
        weatherResponse?.name ?? "Unknown"
    }

    /// Request permission to access the user's location
    func requestLocationPermission() {
        let authorizationStatus = locationManager.authorizationStatus

        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            locationPermissionDenied = true
            errorMessage = "Location access denied. Please enable it in Settings."
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            errorMessage = "Unknown location authorization status."
        }
    }

    /// Fetch the weather for the user's current location.
    func fetchWeatherForCurrentLocation() {
        guard let location = currentLocation else {
            errorMessage = "Current location not available."
            return
        }

        fetchWeather(for: location)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] response in
                self?.weatherResponse = response
                if let iconCode = response.weather.first?.icon {
                    self?.fetchWeatherIcon(for: iconCode)
                }
            })
            .store(in: &cancellables)
    }

    /// Fetch the weather for a given location.
    private func fetchWeather(for location: CLLocation) -> AnyPublisher<WeatherResponse, WeatherServiceError> {
        let cacheKey = NSString(string: "\(location.coordinate.latitude),\(location.coordinate.longitude)")

        // Return cached response if available
        if let cachedResponse = weatherCache.object(forKey: cacheKey) {
            return Just(cachedResponse)
                .setFailureType(to: WeatherServiceError.self)
                .eraseToAnyPublisher()
        }

        // Fetch new weather data if not cached
        return Future<WeatherResponse, WeatherServiceError> { promise in
            WeatherService.shared.fetchWeather(for: location.coordinate.latitude, longitude: location.coordinate.longitude) { result in
                switch result {
                case .success(let response):
                    self.weatherCache.setObject(response, forKey: cacheKey) // Cache the result
                    promise(.success(response))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// Fetch and cache the weather icon.
    private func fetchWeatherIcon(for iconCode: String) {
        let cacheKey = NSString(string: iconCode)

        // Use cached icon if available
        if let cachedIcon = iconCache.object(forKey: cacheKey) {
            self.weatherIcon = cachedIcon
            return
        }

        // Fetch the icon if not cached
        WeatherService.shared.fetchWeatherIcon(for: iconCode) { [weak self] icon in
            guard let self = self else { return }
            if let icon = icon {
                self.iconCache.setObject(icon, forKey: cacheKey) // Cache the icon
            }
            DispatchQueue.main.async {
                self.weatherIcon = icon ?? UIImage(systemName: "cloud.fill")
            }
        }
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.currentLocation = location
        locationManager.stopUpdatingLocation() // Stop updates to conserve battery
        fetchWeatherForCurrentLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let authorizationStatus = manager.authorizationStatus

        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .restricted, .denied:
            locationPermissionDenied = true
            errorMessage = "Location access denied. Please enable it in Settings."
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            errorMessage = "Unknown location authorization status."
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Failed to fetch location: \(error.localizedDescription)"
    }
}
