//
//  AppDelegate.swift
//  WeatherNow
//
//  Created by Ian Abraham Castillo Sanchez on 11/28/24.
//

import UIKit
import CoreData
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private let locationManager = CLLocationManager() // Add a location manager
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Request location permissions
        requestLocationPermission()
        
        // Set up the TabBarController
        let tabBarController = UITabBarController()
        
        let locationRegistrationVC = UINavigationController(rootViewController: LocationRegistrationViewController())
        locationRegistrationVC.tabBarItem = UITabBarItem(title: "Register", image: UIImage(systemName: "plus.circle"), tag: 0)
        
        let weatherStatusVC = UINavigationController(rootViewController: WeatherStatusViewController())
        weatherStatusVC.tabBarItem = UITabBarItem(title: "Locations", image: UIImage(systemName: "list.bullet"), tag: 1)
        
        let currentLocationWeatherVC = UINavigationController(rootViewController: CurrentLocationWeatherViewController())
        currentLocationWeatherVC.tabBarItem = UITabBarItem(title: "Current Weather", image: UIImage(systemName: "location.circle"), tag: 2)
        
        tabBarController.viewControllers = [locationRegistrationVC, weatherStatusVC, currentLocationWeatherVC]
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    // MARK: - Request Location Permission
    
    private func requestLocationPermission() {
        // Check the current authorization status
        let authorizationStatus = locationManager.authorizationStatus
        
        switch authorizationStatus {
        case .notDetermined:
            // Request authorization when not determined
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            // Handle restricted/denied permissions (optional: alert user)
            showLocationPermissionDeniedAlert()
        case .authorizedWhenInUse, .authorizedAlways:
            // Permissions already granted
            print("Location permissions are already authorized.")
        @unknown default:
            break
        }
    }
    
    private func showLocationPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Permission Denied",
            message: "Please enable location permissions in Settings to use location features.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        // Show the alert once the app launches
        DispatchQueue.main.async {
            self.window?.rootViewController?.present(alert, animated: true)
        }
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Handle discarded scenes
    }
    
    // MARK: - Core Data stack
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WeatherNow")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
