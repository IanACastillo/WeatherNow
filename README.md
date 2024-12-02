# WeatherNow 🌤️

**WeatherNow** is a weather tracking application that allows users to register cities, view weather details, and access current weather conditions for their location. The app supports offline functionality, caching, and provides placeholder icons when no network is available.

---

## 🌟 Features

- **Register Cities**: Save and manage your favorite cities for quick weather updates.
- **Current Location Weather**: View real-time weather updates for your current location.
- **Offline Support**: Displays the last fetched weather data when offline.
- **Dynamic UI Updates**: Seamless UI updates using Combine.
- **Caching**: Stores weather details and icons for efficient loading.
- **Placeholder Icons**: Ensures a consistent UI with default icons during network issues.

---

## 🚀 Setup Steps

### Prerequisites

1. **Xcode**: Install Xcode 14.0 or later.
2. **iOS Simulator or Device**: The app supports iOS 14.0 and above.
3. **API Key**: Obtain an API key from [OpenWeather](https://openweathermap.org/) to fetch weather data.

---

### Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/WeatherNow.git
   cd WeatherNow

2. **Configure API Key

To connect to the OpenWeather API, you’ll need to add your API key to the project:

- **Step 1**: Locate the file `WeatherService.swift` in the **Services** folder of the project.

- **Step 2**: Replace `YOUR_API_KEY_HERE` with your actual API key:
  ```swift
  private let apiKey = "YOUR_API_KEY_HERE"


## 💻 Testing Without Internet

The app includes robust offline functionality to ensure a seamless user experience, even without an active internet connection:

- **Cached Data Display**: If the app has been run with an internet connection previously, it will display the last known weather details for each city, including:
  - Temperature
  - Feels-like temperature
  - Weather description

- **Default Weather Icon**: For offline sessions, a cloud icon is displayed as a placeholder for weather conditions.

### Steps to Test Offline Functionality

1. Run the app with an active internet connection.
2. Add one or more cities to fetch their weather data.
3. Exit the app and turn off the internet on your device or simulator.
4. Relaunch the app and verify:
   - Cached weather details are displayed for the previously added cities.
   - The default cloud icon appears as a placeholder for weather conditions.

---

## ✨ Features

- **Weather for Multiple Cities**: 
  - Add cities and track their weather information.
  - Displays the latest weather details, including temperature, feels-like temperature, and description.

- **Offline Support**:
  - Displays cached weather details when there’s no internet connection.
  - Ensures the app remains functional without requiring constant network access.

- **Dynamic Weather Icons**:
  - Fetches and displays weather condition icons dynamically based on the latest data.
  - Caches icons for efficient use and offline compatibility.

- **Current Location Support**:
  - Fetches weather information for your current GPS location.
  - Prompts for location permissions upon first use.

- **User-Friendly Interface**:
  - Clean, modern design for easy navigation.
  - Dynamic updates and smooth transitions for a better user experience.
