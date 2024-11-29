//
//  SceneDelegate.swift
//  WeatherNow
//
//  Created by Ian Abraham Castillo Sanchez on 11/28/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Initialize the Tab Bar Controller
        let tabBarController = UITabBarController()

        // Create ViewControllers
        let locationRegistrationVC = UINavigationController(rootViewController: LocationRegistrationViewController())
        locationRegistrationVC.tabBarItem = UITabBarItem(
            title: "Register",
            image: UIImage(systemName: "plus.circle"),
            tag: 0
        )

        let weatherStatusVC = UINavigationController(rootViewController: WeatherStatusViewController())
        weatherStatusVC.tabBarItem = UITabBarItem(
            title: "Locations",
            image: UIImage(systemName: "list.bullet"),
            tag: 1
        )

        let currentLocationWeatherVC = UINavigationController(rootViewController: CurrentLocationWeatherViewController())
        currentLocationWeatherVC.tabBarItem = UITabBarItem(
            title: "Current Weather",
            image: UIImage(systemName: "location.circle"),
            tag: 2
        )

        // Add ViewControllers to Tab Bar
        tabBarController.viewControllers = [
            locationRegistrationVC,
            weatherStatusVC,
            currentLocationWeatherVC
        ]

        // Customize the Tab Bar appearance
        customizeTabBarAppearance(tabBarController.tabBar)

        // Set Tab Bar as Root View Controller
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = tabBarController
        self.window = window
        window.makeKeyAndVisible()
    }

    func customizeTabBarAppearance(_ tabBar: UITabBar) {
        // Set background color
        tabBar.barTintColor = UIColor(white: 0.1, alpha: 0.9) // Dark translucent background
        tabBar.isTranslucent = true

        // Set selected and unselected item colors
        tabBar.tintColor = .white // Selected item color
        tabBar.unselectedItemTintColor = UIColor(white: 0.7, alpha: 1.0) // Unselected item color

        // Add shadow to the tab bar
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.layer.shadowRadius = 4

        // Customize tab bar item font
        let appearance = UITabBarItem.appearance()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium)
        ]
        appearance.setTitleTextAttributes(attributes, for: .normal)
    }
}
