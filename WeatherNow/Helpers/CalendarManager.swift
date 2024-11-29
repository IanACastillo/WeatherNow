//
//  CalendarManager.swift
//  WeatherNow
//
//  Created by Ian Abraham Castillo Sanchez on 11/28/24.
//

import EventKit

class CalendarManager {
    static let shared = CalendarManager()
    private let eventStore = EKEventStore()

    /// Requests calendar access for adding events.
    /// - Parameter completion: Completion handler with a boolean indicating access granted or denied.
    func requestAccess(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, _ in
                completion(granted)
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, _ in
                completion(granted)
            }
        }
    }

    /// Adds a weather reminder for the specified city name and date to the user's calendar.
    /// - Parameters:
    ///   - cityName: The name of the city for which the weather reminder is being added.
    ///   - date: The date and time for the reminder.
    func addWeatherReminder(for cityName: String, date: Date) {
        requestAccess { [weak self] granted in
            guard granted else {
                print("Calendar access denied.")
                return
            }
            guard let self = self else { return }

            let event = EKEvent(eventStore: self.eventStore)
            event.title = "Check Weather for \(cityName)"
            event.startDate = date
            event.endDate = date.addingTimeInterval(3600) // 1-hour duration
            event.calendar = self.eventStore.defaultCalendarForNewEvents

            do {
                try self.eventStore.save(event, span: .thisEvent)
                print("Event added to calendar.")
            } catch {
                print("Error adding calendar event: \(error)")
            }
        }
    }
}
