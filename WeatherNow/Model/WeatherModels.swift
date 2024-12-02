//
//  WeatherModels.swift
//  WeatherNow
//
//  Created by Ian Abraham Castillo Sanchez on 11/28/24.
//

import Foundation

/// Represents the weather response from the API
class WeatherResponse: Codable {
    let name: String // City name
    let main: Main
    let weather: [Weather]

    init(name: String, main: Main, weather: [Weather]) {
        self.name = name
        self.main = main
        self.weather = weather
    }

    /// Main weather details (temperature, feels like, etc.)
    class Main: Codable {
        let temp: Double
        let feels_like: Double
        let pressure: Int?
        let humidity: Int?

        init(temp: Double, feels_like: Double, pressure: Int? = nil, humidity: Int? = nil) {
            self.temp = temp
            self.feels_like = feels_like
            self.pressure = pressure
            self.humidity = humidity
        }
    }

    /// Weather conditions (description and icon)
    struct Weather: Codable {
        let description: String
        let icon: String

        init(description: String, icon: String) {
            self.description = description
            self.icon = icon
        }
    }

    /// Coordinate information (optional if needed in the future)
    struct Coordinate: Codable {
        let lon: Double // Longitude
        let lat: Double // Latitude

        init(lon: Double, lat: Double) {
            self.lon = lon
            self.lat = lat
        }
    }
}
