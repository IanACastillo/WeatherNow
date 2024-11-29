//
//  WeatherStatusTableViewCell.swift
//  WeatherNow
//
//  Created by Ian Abraham Castillo Sanchez on 11/28/24.
//

import UIKit

class WeatherStatusTableViewCell: UITableViewCell {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let cityNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let coordinatesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let weatherInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(cityNameLabel)
        contentView.addSubview(coordinatesLabel)
        contentView.addSubview(weatherInfoLabel)

        NSLayoutConstraint.activate([
            // Icon
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),

            // City Name
            cityNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cityNameLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            cityNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Coordinates
            coordinatesLabel.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor, constant: 4),
            coordinatesLabel.leadingAnchor.constraint(equalTo: cityNameLabel.leadingAnchor),
            coordinatesLabel.trailingAnchor.constraint(equalTo: cityNameLabel.trailingAnchor),

            // Weather Info
            weatherInfoLabel.topAnchor.constraint(equalTo: coordinatesLabel.bottomAnchor, constant: 4),
            weatherInfoLabel.leadingAnchor.constraint(equalTo: cityNameLabel.leadingAnchor),
            weatherInfoLabel.trailingAnchor.constraint(equalTo: cityNameLabel.trailingAnchor),
            weatherInfoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    func configure(with location: Location, icon: UIImage?, temperature: String? = nil, feelsLike: String? = nil) {
        cityNameLabel.text = location.cityName
        coordinatesLabel.text = "Lat: \(location.latitude), Lon: \(location.longitude)"
        weatherInfoLabel.text = """
        Temperature: \(temperature ?? "--")°C
        Feels Like: \(feelsLike ?? "--")°C
        """
        iconImageView.image = icon
    }

    func setWeatherIcon(_ icon: UIImage?) {
        iconImageView.image = icon
    }

    func updateWeatherInfo(_ weatherInfo: String) {
        weatherInfoLabel.text = weatherInfo
    }
    
    func updateWeatherDetails(temperature: String, feelsLike: String) {
        weatherInfoLabel.text = """
        Temperature: \(temperature)°C
        Feels Like: \(feelsLike)°C
        """
    }
}
