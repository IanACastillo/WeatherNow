//
//  LocationRegistrationViewModel.swift
//  WeatherNow
//
//  Created by Ian Abraham Castillo Sanchez on 11/28/24.
//

import Combine
import Foundation

class LocationRegistrationViewModel {
    // Publisher for location updates
    static let locationAdded = PassthroughSubject<Location, Never>()

    func registerLocation(cityName: String, latitude: Double, longitude: Double, completion: @escaping (Bool, String) -> Void) {
        guard !cityName.isEmpty else {
            completion(false, "City name cannot be empty.")
            return
        }

        let location = Location(context: CoreDataManager.shared.context)
        location.id = UUID()
        location.cityName = cityName
        location.latitude = latitude
        location.longitude = longitude
        location.registrationDate = Date()

        do {
            try CoreDataManager.shared.context.save()
            completion(true, "Location registered successfully!")
            LocationRegistrationViewModel.locationAdded.send(location) // Emit the new location
        } catch {
            completion(false, "Failed to save location: \(error.localizedDescription)")
        }
    }
}
