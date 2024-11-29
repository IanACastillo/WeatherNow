//
//  CurrentLocationWeatherViewController.swift
//  WeatherNow
//
//  Created by Ian Abraham Castillo Sanchez on 11/28/24.
//

import UIKit
import Combine

class CurrentLocationWeatherViewController: UIViewController {
    private let viewModel = CurrentLocationWeatherViewModel()
    private let weatherIconImageView = UIImageView()
    private let cityLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let feelsLikeLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchWeatherForCurrentLocation()
    }

    // MARK: - UI Setup
    private func setupUI() {
        setupGradientBackground()

        // Configure Weather Icon
        weatherIconImageView.contentMode = .scaleAspectFit
        weatherIconImageView.translatesAutoresizingMaskIntoConstraints = false

        // Configure Labels
        cityLabel.font = UIFont.boldSystemFont(ofSize: 24)
        cityLabel.textColor = .white
        cityLabel.textAlignment = .center
        cityLabel.translatesAutoresizingMaskIntoConstraints = false

        temperatureLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .center
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false

        feelsLikeLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        feelsLikeLabel.textColor = .white
        feelsLikeLabel.textAlignment = .center
        feelsLikeLabel.translatesAutoresizingMaskIntoConstraints = false

        descriptionLabel.font = UIFont.italicSystemFont(ofSize: 18)
        descriptionLabel.textColor = .white
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false

        // Add Subviews
        view.addSubview(weatherIconImageView)
        view.addSubview(cityLabel)
        view.addSubview(temperatureLabel)
        view.addSubview(feelsLikeLabel)
        view.addSubview(descriptionLabel)

        // Layout Constraints
        NSLayoutConstraint.activate([
            weatherIconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            weatherIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherIconImageView.heightAnchor.constraint(equalToConstant: 100),
            weatherIconImageView.widthAnchor.constraint(equalToConstant: 100),

            cityLabel.topAnchor.constraint(equalTo: weatherIconImageView.bottomAnchor, constant: 16),
            cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            temperatureLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 12),
            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            feelsLikeLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 8),
            feelsLikeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            descriptionLabel.topAnchor.constraint(equalTo: feelsLikeLabel.bottomAnchor, constant: 12),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemTeal.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: - ViewModel Binding
    private func bindViewModel() {
        // Bind weatherResponse to update UI dynamically
        viewModel.$weatherResponse
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                self?.updateWeatherUI(weatherInfo: response)
            }
            .store(in: &cancellables)

        // Bind weatherIcon to update dynamically
        viewModel.$weatherIcon
            .receive(on: DispatchQueue.main)
            .sink { [weak self] icon in
                self?.weatherIconImageView.image = icon ?? UIImage(systemName: "cloud.fill")
            }
            .store(in: &cancellables)

        // Handle Errors
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showAlert("Error", error)
            }
            .store(in: &cancellables)
    }

    // MARK: - Update UI
    private func updateWeatherUI(weatherInfo: WeatherResponse) {
        cityLabel.text = viewModel.cityName
        temperatureLabel.text = "Temperature: \(String(format: "%.1f", weatherInfo.main.temp))°C"
        feelsLikeLabel.text = "Feels Like: \(String(format: "%.1f", weatherInfo.main.feels_like))°C"
        descriptionLabel.text = weatherInfo.weather.first?.description.capitalized ?? "N/A"
    }

    // MARK: - Alert
    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
