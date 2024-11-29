//
//  WeatherModels.swift
//  WeatherNow
//
//  Created by Ian Abraham Castillo Sanchez on 11/28/24.
//

import Foundation

class WeatherResponse: Codable {
    let name: String // City name
    let main: Main
    let weather: [Weather]

    struct Main: Codable {
        let temp: Double
        let feels_like: Double 
    }

    struct Weather: Codable {
        let description: String
        let icon: String
    }
}

struct MainWeather: Codable {
    let temp: Double
    let feels_like: Double
    let pressure: Int
    let humidity: Int
}

struct WeatherCondition: Codable {
    let description: String
    let icon: String
}

struct Coordinate: Codable {
    let lon: Double // Longitude
    let lat: Double // Latitude
}
