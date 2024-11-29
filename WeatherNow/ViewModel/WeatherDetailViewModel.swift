//
//  WeatherDetailViewModel.swift
//  WeatherNow
//
//  Created by Ian Abraham Castillo Sanchez on 11/28/24.
//

import Combine
import UIKit

class WeatherDetailViewModel: ObservableObject {
    private let location: Location
    private var cancellables = Set<AnyCancellable>()
    private let weatherCache = NSCache<NSString, WeatherResponse>() // Cache for weather data
    private let iconCache = NSCache<NSString, UIImage>() // Cache for weather icons

    @Published var weatherResponse: WeatherResponse?
    @Published var weatherIcon: UIImage?
    var onError: ((String) -> Void)?

    init(location: Location) {
        self.location = location
    }

    /// Expose the city name for the UI
    var cityName: String {
        location.cityName ?? "Unknown"
    }

    /// Fetch weather data with caching logic.
    func fetchWeather() {
        let cacheKey = NSString(string: cityName)

        // Check the cache for weather data
        if let cachedResponse = weatherCache.object(forKey: cacheKey) {
            updateWeatherUI(with: cachedResponse)
            fetchWeatherIcon(for: cachedResponse.weather.first?.icon)
            return
        }

        // Fetch weather data if not in cache
        WeatherService.shared.fetchWeather(for: location.latitude, longitude: location.longitude) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.weatherCache.setObject(response, forKey: cacheKey) // Cache the result
                    self.updateWeatherUI(with: response)
                    self.fetchWeatherIcon(for: response.weather.first?.icon)
                case .failure(let error):
                    self.onError?(error.localizedDescription)
                }
            }
        }
    }

    /// Fetch and cache the weather icon.
    private func fetchWeatherIcon(for iconCode: String?) {
        guard let iconCode = iconCode else {
            self.weatherIcon = UIImage(systemName: "cloud.fill")
            return
        }

        // Check the cache for the icon
        if let cachedIcon = iconCache.object(forKey: iconCode as NSString) {
            self.weatherIcon = cachedIcon
            return
        }

        // Fetch the icon if not in cache
        WeatherService.shared.fetchWeatherIcon(for: iconCode) { [weak self] icon in
            guard let self = self else { return }
            if let icon = icon {
                self.iconCache.setObject(icon, forKey: iconCode as NSString) // Cache the icon
            }
            self.weatherIcon = icon ?? UIImage(systemName: "cloud.fill")
        }
    }

    /// Update the UI with weather information.
    /// - Parameter response: The weather response to use for the UI.
    private func updateWeatherUI(with response: WeatherResponse) {
        self.weatherResponse = response
    }
}
