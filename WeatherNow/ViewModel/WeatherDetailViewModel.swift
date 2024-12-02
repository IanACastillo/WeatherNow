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
                    self.saveWeatherDetails(to: response)
                case .failure(let error):
                    self.loadStoredWeatherDetails()
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

    /// Save weather details to Core Data.
    private func saveWeatherDetails(to response: WeatherResponse) {
        let context = CoreDataManager.shared.context
        location.temperature = response.main.temp
        location.feelsLike = response.main.feels_like
        location.weatherDescription = response.weather.first?.description

        do {
            try context.save()
        } catch {
            print("Failed to save weather details: \(error.localizedDescription)")
        }
    }

    /// Load stored weather details from Core Data.
    private func loadStoredWeatherDetails() {
        // Ensure the structure aligns with the WeatherResponse model
        let storedMain = WeatherResponse.Main(temp: location.temperature, feels_like: location.feelsLike)
        let storedWeather = [WeatherResponse.Weather(description: location.weatherDescription ?? "N/A", icon: "")]

        // Construct the WeatherResponse
        let storedResponse = WeatherResponse(name: cityName, main: storedMain, weather: storedWeather)

        self.weatherResponse = storedResponse
    }
}
