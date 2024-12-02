//
//  WeatherStatusViewController.swift
//  WeatherNow
//
//  Created by Ian Abraham Castillo Sanchez on 11/28/24.
//

import UIKit
import Combine

class WeatherStatusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let tableView = UITableView()
    private let viewModel = WeatherStatusViewModel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    func setupUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WeatherStatusTableViewCell.self, forCellReuseIdentifier: "WeatherStatusCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func bindViewModel() {
        viewModel.$locations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfLocations
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherStatusCell", for: indexPath) as? WeatherStatusTableViewCell else {
            return UITableViewCell()
        }

        let location = viewModel.location(at: indexPath.row)

        // Configure the cell with placeholder data
        cell.configure(
            with: location,
            icon: UIImage(systemName: "cloud"),
            temperature: "--",
            feelsLike: "--"
        )

        // Fetch and update the weather details dynamically
        viewModel.fetchWeatherDetails(for: location)
            .receive(on: DispatchQueue.main)
            .sink { temperature, feelsLike, description, icon in
                let temperatureText = String(format: "%.1f", temperature) // Cast temperature to String
                let feelsLikeText = String(format: "%.1f", feelsLike)     // Cast feelsLike to String
                
                cell.updateWeatherDetails(temperature: temperatureText, feelsLike: feelsLikeText)
                cell.setWeatherIcon(icon)
            }
            .store(in: &cancellables)

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = viewModel.location(at: indexPath.row)
        let detailVC = WeatherDetailViewController(location: location)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
