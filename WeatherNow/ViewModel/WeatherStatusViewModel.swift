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

    /// Fetch the weather icon for a given location, leveraging Combine.
    func fetchWeatherIcon(for location: Location) -> AnyPublisher<UIImage?, Never> {
        guard let cityName = location.cityName else {
            return Just(nil).eraseToAnyPublisher()
        }

        // Use cached icon if available
        if let cachedIcon = iconCache.object(forKey: cityName as NSString) {
            return Just(cachedIcon).eraseToAnyPublisher()
        }

        // Fetch weather data to get the icon code
        return Future<UIImage?, Never> { [weak self] promise in
            WeatherService.shared.fetchWeather(for: location.latitude, longitude: location.longitude) { result in
                switch result {
                case .success(let response):
                    if let iconCode = response.weather.first?.icon {
                        WeatherService.shared.fetchWeatherIcon(for: iconCode) { icon in
                            if let icon = icon {
                                self?.iconCache.setObject(icon, forKey: cityName as NSString) // Cache the icon
                            }
                            promise(.success(icon))
                        }
                    } else {
                        promise(.success(nil))
                    }
                case .failure:
                    promise(.success(nil))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// Fetch the weather details (temperature and feels like) for a location.
    func fetchWeatherDetails(for location: Location) -> AnyPublisher<(String, String), Never> {
        let cacheKey = NSString(string: location.cityName ?? "Unknown")

        // Check if weather details are cached
        if let cachedResponse = weatherCache.object(forKey: cacheKey) {
            let temperature = String(format: "%.1f", cachedResponse.main.temp)
            let feelsLike = String(format: "%.1f", cachedResponse.main.feels_like)
            return Just((temperature, feelsLike)).eraseToAnyPublisher()
        }

        // Fetch from WeatherService if not cached
        return Future<(String, String), Never> { [weak self] promise in
            WeatherService.shared.fetchWeather(for: location.latitude, longitude: location.longitude) { result in
                switch result {
                case .success(let response):
                    let temperature = String(format: "%.1f", response.main.temp)
                    let feelsLike = String(format: "%.1f", response.main.feels_like)
                    self?.weatherCache.setObject(response, forKey: cacheKey) // Cache the weather data
                    promise(.success((temperature, feelsLike)))
                case .failure:
                    promise(.success(("N/A", "N/A")))
                }
            }
        }
        .eraseToAnyPublisher()
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
