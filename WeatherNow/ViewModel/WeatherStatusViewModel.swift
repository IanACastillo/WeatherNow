//
//  WeatherStatusViewModel.swift
//  WeatherNow
//
//  Created by Ian Abraham Castillo Sanchez on 11/28/24.
//

import Combine
import CoreData
import UIKit

class WeatherStatusViewModel: ObservableObject {
    @Published private(set) var locations: [Location] = [] // Published for UI updates
    private var cancellables = Set<AnyCancellable>()
    private var uniqueCityNames = Set<String>() // Track unique city names
    private let iconCache = NSCache<NSString, UIImage>() // Cache for weather icons
    private let weatherCache = NSCache<NSString, WeatherResponse>() // Cache for weather details

    init() {
        fetchLocations()
        subscribeToLocationUpdates()
    }

    var numberOfLocations: Int {
        locations.count
    }

    func location(at index: Int) -> Location {
        locations[index]
    }

    /// Fetch locations from Core Data, ensuring uniqueness by `cityName`.
    func fetchLocations() {
        let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
        do {
            let fetchedLocations = try CoreDataManager.shared.context.fetch(fetchRequest)

            // Deduplicate by cityName and update `locations`
            locations = fetchedLocations.filter { location in
                if let cityName = location.cityName {
                    return uniqueCityNames.insert(cityName).inserted
                }
                return false
            }.sorted { ($0.cityName ?? "") < ($1.cityName ?? "") }
        } catch {
            print("Failed to fetch locations: \(error.localizedDescription)")
        }
    }

    /// Fetch weather details for a specific location and save to Core Data.
    func fetchWeatherDetails(for location: Location) -> AnyPublisher<(Double, Double, String, UIImage?), Never> {
        let cacheKey = NSString(string: location.cityName ?? "Unknown")

        // Check cached weather data
        if let cachedResponse = weatherCache.object(forKey: cacheKey) {
            let temperature = cachedResponse.main.temp
            let feelsLike = cachedResponse.main.feels_like
            let description = cachedResponse.weather.first?.description ?? "N/A"

            return fetchWeatherIcon(for: cachedResponse.weather.first?.icon)
                .map { icon in
                    (temperature, feelsLike, description, icon ?? UIImage(systemName: "cloud.fill"))
                }
                .eraseToAnyPublisher()
        }

        // Fetch new weather data if not cached
        return Future<(Double, Double, String, UIImage?), Never> { [weak self] promise in
            WeatherService.shared.fetchWeather(for: location.latitude, longitude: location.longitude) { result in
                switch result {
                case .success(let response):
                    let temperature = response.main.temp
                    let feelsLike = response.main.feels_like
                    let description = response.weather.first?.description ?? "N/A"
                    self?.weatherCache.setObject(response, forKey: cacheKey) // Cache weather response

                    self?.saveWeatherDetails(to: location, temperature: temperature, feelsLike: feelsLike, description: description)

                    self?.fetchWeatherIcon(for: response.weather.first?.icon)
                        .sink { icon in
                            promise(.success((temperature, feelsLike, description, icon ?? UIImage(systemName: "cloud.fill"))))
                        }
                        .store(in: &self!.cancellables)
                case .failure:
                    let storedData = self?.loadStoredWeatherDetails(for: location)
                    promise(.success(storedData ?? (0.0, 0.0, "N/A", UIImage(systemName: "cloud.fill"))))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// Fetch weather icon for a given icon code.
    private func fetchWeatherIcon(for iconCode: String?) -> AnyPublisher<UIImage?, Never> {
        guard let iconCode = iconCode else {
            return Just(UIImage(systemName: "cloud.fill")).eraseToAnyPublisher()
        }

        let cacheKey = NSString(string: iconCode)

        // Use cached icon if available
        if let cachedIcon = iconCache.object(forKey: cacheKey) {
            return Just(cachedIcon).eraseToAnyPublisher()
        }

        // Fetch icon from network
        return Future<UIImage?, Never> { [weak self] promise in
            WeatherService.shared.fetchWeatherIcon(for: iconCode) { icon in
                if let icon = icon {
                    self?.iconCache.setObject(icon, forKey: cacheKey) // Cache the icon
                }
                promise(.success(icon ?? UIImage(systemName: "cloud.fill")))
            }
        }
        .eraseToAnyPublisher()
    }

    /// Save weather details to Core Data.
    private func saveWeatherDetails(to location: Location, temperature: Double, feelsLike: Double, description: String) {
        let context = CoreDataManager.shared.context
        location.temperature = temperature
        location.feelsLike = feelsLike
        location.weatherDescription = description

        do {
            try context.save()
        } catch {
            print("Failed to save weather details: \(error.localizedDescription)")
        }
    }

    /// Load stored weather details from Core Data.
    private func loadStoredWeatherDetails(for location: Location) -> (Double, Double, String, UIImage?) {
        let temperature = location.temperature
        let feelsLike = location.feelsLike
        let description = location.weatherDescription ?? "N/A"
        return (temperature, feelsLike, description, UIImage(systemName: "cloud.fill")) // Placeholder for offline
    }

    /// Subscribes to updates from `LocationRegistrationViewModel`, filtering duplicates by `cityName`.
    private func subscribeToLocationUpdates() {
        LocationRegistrationViewModel.locationAdded
            .sink { [weak self] newLocation in
                guard let self = self else { return }

                if let cityName = newLocation.cityName, self.uniqueCityNames.insert(cityName).inserted {
                    self.locations.append(newLocation)
                    self.locations.sort { ($0.cityName ?? "") < ($1.cityName ?? "") }
                }
            }
            .store(in: &cancellables)
    }
}
