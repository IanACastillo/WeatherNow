//
//  NotificationManager.swift
//  WeatherNow
//
//  Created by Ian Abraham Castillo Sanchez on 11/28/24.
//

import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            } else if granted {
                print("Notification access granted.")
            } else {
                print("Notification access denied.")
            }
        }
    }

    func sendNotification(for location: Location, change: String) {
        let content = UNMutableNotificationContent()
        content.title = "Weather Alert"
        content.body = "Significant weather change detected in \(location.cityName ?? "Unknown City"): \(change)"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func detectWeatherChange(location: Location, newWeather: String) {
        let oldWeather = location.cachedWeather ?? "Unknown"
        if oldWeather != newWeather {
            location.cachedWeather = newWeather
            CoreDataManager.shared.saveContext()
            sendNotification(for: location, change: "\(oldWeather) → \(newWeather)")
        }
    }
}
