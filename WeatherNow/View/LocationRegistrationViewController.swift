//
//  LocationRegistrationViewController.swift
//  WeatherNow
//
//  Created by Ian Abraham Castillo Sanchez on 11/28/24.
//

import UIKit
import CoreLocation

class LocationRegistrationViewController: UIViewController {
    private let viewModel = LocationRegistrationViewModel()
    private let geocoder = CLGeocoder() // Geocoder for converting city name to coordinates

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Register a Location"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let cityNameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter City Name"
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
        textField.layer.cornerRadius = 8
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.2
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)
        textField.layer.shadowRadius = 4
        textField.font = UIFont.systemFont(ofSize: 18)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(12)
        return textField
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register Location", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.systemBlue
        button.layer.cornerRadius = 8
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // Correctly add the button action here
        registerButton.addTarget(self, action: #selector(registerLocation), for: .touchUpInside)
    }

    private func setupUI() {
        // Set up gradient background
        setupGradientBackground()

        // Add title, text field, and button to a stack view
        let stackView = UIStackView(arrangedSubviews: [titleLabel, cityNameField, registerButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            cityNameField.heightAnchor.constraint(equalToConstant: 50),
            registerButton.heightAnchor.constraint(equalToConstant: 50)
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

    @objc private func registerLocation() {
        guard let cityName = cityNameField.text, !cityName.isEmpty else {
            showAlert("Invalid Input", "City name cannot be empty.")
            return
        }

        // Use Geocoder to fetch latitude and longitude
        geocoder.geocodeAddressString(cityName) { [weak self] placemarks, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert("Geocoding Error", "Unable to find location: \(error.localizedDescription)")
                }
                return
            }

            guard let location = placemarks?.first?.location else {
                DispatchQueue.main.async {
                    self.showAlert("Error", "No matching location found.")
                }
                return
            }

            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude

            self.viewModel.registerLocation(cityName: cityName, latitude: latitude, longitude: longitude) { success, message in
                DispatchQueue.main.async {
                    self.showAlert(success ? "Success" : "Error", message)
                }
            }
        }
    }

    private func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// Add padding to the UITextField
private extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
