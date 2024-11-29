//
//  WeatherService.swift
//  WeatherNow
//
//  Created by Ian Abraham Castillo Sanchez on 11/28/24.
//

import Foundation
import UIKit

class WeatherService {
    // Singleton instance
    static let shared = WeatherService()

    // API Key
    private let apiKey = "9e0a4044f5f861ae058d4eb859725a0c"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    private let iconBaseURL = "https://openweathermap.org/img/wn/"

    /// Fetches weather data for the given latitude and longitude.
    /// - Parameters:
    ///   - latitude: Latitude of the location.
    ///   - longitude: Longitude of the location.
    ///   - completion: Closure with the `WeatherResponse` object or an error message.
    func fetchWeather(for latitude: Double, longitude: Double, completion: @escaping (Result<WeatherResponse, WeatherServiceError>) -> Void) {
        // Construct the URL
        guard let url = constructURL(latitude: latitude, longitude: longitude) else {
            completion(.failure(.invalidURL))
            return
        }

        // Perform the network request
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle network error
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }

            // Verify response and data
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidResponse))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            // Decode the JSON response
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(.success(weatherResponse))
            } catch {
                completion(.failure(.decodingError(error.localizedDescription)))
            }
        }.resume()
    }

    /// Constructs the URL for fetching weather data.
    /// - Parameters:
    ///   - latitude: Latitude of the location.
    ///   - longitude: Longitude of the location.
    /// - Returns: A valid `URL` or `nil` if the URL couldn't be constructed.
    private func constructURL(latitude: Double, longitude: Double) -> URL? {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "lat", value: "\(latitude)"),
            URLQueryItem(name: "lon", value: "\(longitude)"),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        return components?.url
    }
    
    /// Downloads the weather icon for a given icon code.
    func fetchWeatherIcon(for iconCode: String, completion: @escaping (UIImage?) -> Void) {
        let iconURLString = "\(iconBaseURL)\(iconCode)@2x.png"
        guard let url = URL(string: iconURLString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            completion(UIImage(data: data))
        }.resume()
    }
}

/// Custom error types for the WeatherService.
enum WeatherServiceError: Error {
    case invalidURL
    case networkError(String)
    case invalidResponse
    case noData
    case decodingError(String)

    /// Provides user-friendly error messages.
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .networkError(let message):
            return "Network error occurred: \(message)"
        case .invalidResponse:
            return "The server response was invalid."
        case .noData:
            return "No data was received from the server."
        case .decodingError(let message):
            return "Failed to decode the response: \(message)"
        }
    }
}
